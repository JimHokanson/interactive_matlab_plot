classdef comments < handle
    %
    %   Class:
    %   interactive_plot.comments
    %
    %   Improvements
    %   ------------
    %   1) Start the line render at the edge of the text - this can be very
    %   complicated since it could span multiple axes
    %   2) Change pointer when over the text box
    
    
    %{
    
    - DONE move comment
    - delete comment
    
    - edit comment
    - DONE ylim text adjust
    - DONE no string no comment
    - DONE hit return to add comment
        
    %}
    
    properties
        fig_handle
        axes_handles
        
        h_lines %One line handle per axes
        
        bottom_axes %Handle to the axes on the bottom (for text placement)
        y_top_axes
        y_bottom_axes
        
        mouse_man
                
        %Comment Data
        %--------------
        strings
        times
        h_text
        is_valid %NYI, when a comment is deleted, mark it as invalid
        
        n_comments = 0
        
        %Callbacks
        %----------------
        selected_line_I
        h_line_temp
        
        ylim_listener
    end
    
    methods
        function obj = comments(shared)
            obj.fig_handle = shared.handles.fig_handle;
            obj.axes_handles = shared.handles.axes_handles;
            obj.bottom_axes = obj.axes_handles{end};
            obj.mouse_man = shared.mouse_manager;
            
            h_top = obj.axes_handles{1};
            p_top = get(h_top,'Position');
            obj.y_top_axes = p_top(2)+p_top(4);
            p_bottom = get(obj.bottom_axes,'Position');
            obj.y_bottom_axes = p_bottom(2);
            
            obj.strings = cell(1,100);
            obj.h_text = cell(1,100);
            obj.times = zeros(1,100);
            
            obj.ylim_listener = addlistener(obj.bottom_axes, 'YLim', ...
                'PostSet', @(~,~) obj.ylimChanged);
            
            n_axes = length(obj.axes_handles);
            temp = cell(1,n_axes);
            for i = 1:n_axes
                h_axes = obj.axes_handles{i};
                temp{i} = line(h_axes,[NaN NaN],[NaN NaN],...
                    'Color',0.5*ones(1,4),'YLimInclude','off');
            end
            
            obj.h_lines = temp;
        end
        function commentSelected(obj,I)
            
            obj.selected_line_I = I;
            
            x = interactive_plot.utils.getCurrentMousePoint(obj.fig_handle);
            y_line = [obj.y_bottom_axes obj.y_top_axes];
            obj.h_line_temp = annotation('line',[x x],y_line,'Color','r');
            
            obj.mouse_man.setMouseMotionFunction(@obj.movingComment);
            obj.mouse_man.setMouseUpFunction(@obj.mouseUp);
        end
        function movingComment(obj)
            h = obj.h_text{obj.selected_line_I};
            set(h,'Color','r')
            x = interactive_plot.utils.getCurrentMousePoint(obj.fig_handle);
            set(obj.h_line_temp,'X',[x x]);
        end
        function mouseUp(obj)
            h = obj.h_text{obj.selected_line_I};
            
            %Update time based on mouse
            %------------------------------------
            x_line = get(obj.h_line_temp,'X');
            new_time = interactive_plot.utils.translateXFromFigToAxes(...
                obj.bottom_axes,x_line(1));
                    
            obj.times(obj.selected_line_I) = new_time;
            
            %Move tet and reset text color
            %--------------------------------------
            set(h,'Color','k')
            obj.h_text{obj.selected_line_I}.Position(1) = new_time;
            
            delete(obj.h_line_temp);
            
            obj.mouse_man.initDefaultState();    
            
            obj.renderComments();
        end
        function addComments(obj,times,strings)
            %NYI
            %   - intended for loading from disk
        end
        function addComment(obj,time,str)
            if isempty(str)
                return
            end
            
            I = obj.n_comments + 1;
            
            if I > length(obj.times)
            	%TODO: Handle overflow resizing - both original and sorted arrays
            end
            
            obj.strings{I} = str;
            obj.times(I) = time;
            ylim = get(obj.bottom_axes,'YLim');
            display_string = sprintf(' %d) %s',I,str);
            obj.h_text{I} = text(obj.bottom_axes,time,ylim(1),display_string,...
                'Rotation',90,'UserData',I,'BackgroundColor',[1 1 1 0.2],...
                'ButtonDownFcn',@(~,~)obj.commentSelected(I));
            
            obj.n_comments = I;
            obj.renderComments();
        end
        function ylimChanged(obj)
            ylim = get(obj.bottom_axes,'YLim');
            for i = 1:obj.n_comments
                obj.h_text{i}.Position(2) = ylim(1);
            end
        end
        function renderComments(obj)
            if obj.n_comments > 0
                
                %Line Editing
                %-------------------------------------------
                x = obj.times(1:obj.n_comments);
                x_line = NaN(1,3*length(x));
                y1 = -1e9;
                y2 = 1e9;
                y_line = NaN(1,3*length(x));
                
                x_line(1:3:end) = x;
                x_line(2:3:end) = x;
                y_line(1:3:end) = y1;
                y_line(2:3:end) = y2;
                
                
                n_axes = length(obj.axes_handles);
                for i = 1:n_axes
                    h_line = obj.h_lines{i};
                    set(h_line,'XData',x_line);
                    set(h_line,'YData',y_line);
                end
            end
        end
    end
    
end

