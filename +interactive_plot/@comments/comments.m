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
    
    - move comment
    - delete comment
    
    - edit comment
    - ylim text adjust
    - no string no comment
    
    clf
    ax(1) = subplot(2,1,1);
    plot(1:100)
    ax(2) = subplot(2,1,2);
    plot(1:100)
    h = text(50,1,'THis is a test of the plotting system I think','Rotation',90);
    
    %Vertical Lines
    %
    %x  x  NaN
    %y1 y2 NaN 
    
    x = 5:5:90;
    y1 = 0;
    y2 = 100;
    
    x_line = NaN(1,3*length(x));
    y_line = NaN(1,3*length(x));
    
    x_line(1:3:end) = x;
    x_line(2:3:end) = x;
    y_line(1:3:end) = y1;
    y_line(2:3:end) = y2;
    
    line(x_line,y_line,'Color','k')
    
    
    %}
    
    properties
        axes_handles
        h_lines
        bottom_axes
        mouse_man
        
        sorted_ids
        sorted_times
        
        %Unsorted
        %--------------
        strings
        h_text
        times
        is_valid %NYI, when a comment is deleted, mark it as invalid
        
        n_comments = 0
        n_visible = 0
        
        ylim_listener
    end
    
    methods
        function obj = comments(shared)
            obj.axes_handles = shared.handles.axes_handles;
            obj.bottom_axes = obj.axes_handles{end};
            obj.mouse_man = shared.mouse_manager;
            
            
            
            obj.strings = cell(1,100);
            obj.sorted_ids = zeros(1,100);
            obj.h_text = cell(1,100);
            
            %TODO: We need to initialize with the most negative time
            %possible ...
            obj.sorted_times = zeros(1,100);
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
            disp(I);
            %mouse action manager - claim
        end
        function movingComment(obj)
        end
        function mouseUp(obj)
            
        end
        function addComment(obj,time,str)
            %TODO: Handle resizing - both original and sorted
            I = obj.n_comments + 1;
            obj.strings{I} = str;
            obj.times(I) = time;
            ylim = get(obj.bottom_axes,'YLim');
            display_string = sprintf(' %d) %s',I,str);
            obj.h_text{I} = text(obj.bottom_axes,time,ylim(1),display_string,...
                'Rotation',90,'UserData',I,'BackgroundColor',[1 1 1 0.2],...
                'ButtonDownFcn',@(~,~)obj.commentSelected(I));
            
            if I == 1
                obj.sorted_ids(1) = 1;
                obj.sorted_times(1) = time;
            else
                if time > obj.sorted_times(I-1)
                    %Add at the end
                    obj.sorted_ids(I) = I;
                    obj.sorted_times(I) = time;
                else
                    I2 = find(time > obj.sorted_times,1);
                    start_move = I2+1;
                    end_move = obj.n_comments;
                    obj.sorted_ids(start_move+1:end_move+1) = obj.sorted_ids(start_move:end_move);
                    obj.sorted_times(start_move+1:end_move+1) = obj.sorted_times(start_move:end_move);
                    obj.sorted_ids(I2) = I;
                    obj.sorted_times(I2) = time;
                end
            end
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
% % % % %             p = get(obj.bottom_axes,'Position');
% % % % %             xlim = get(obj.bottom_axes,'xlim');
            if obj.n_comments > 0
                
                
% % % %                 %Should we just always render everything?????
% % % %                 %=> Need to render text
% % % %                 I1 = find(obj.sorted_times >= xlim(1),1);
% % % %                 I2 = find(obj.sorted_times <=  xlim(2),1,'last');
% % % %                 
% % % %                 if ~isempty(I1) && ~isempty(I2) && I1 <= I2
% % % %                     
% % % %                     sort_use = obj.sorted_ids(I1:I2);
% % % %                     strings_plot = obj.strings{sort_use};
% % % %                 end
                
                
                %This can be sped up if we have done a previous search ...
                %Find all comments in time range
                
                
                
                
                %Line Editing
                %-------------------------------------------
                x = obj.sorted_times(1:obj.n_comments);
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
%         function updateSortInfo(obj,I,is_new)
%             %From
%             %- adding
%             %- moving
%             time = obj.times(I);
%             
%             if is_new
%                 if time > obj.sorted_times(
%             else
%                 
%                 end
%             
%             I2 = find(time > obj.sorted_times,1);
%             
%             if obj.n_comments == I2
%                 %Adding at the end
%                 obj.sorted_ids(I2)
%             else
%                 
%             end
%         end
    end
    
end

