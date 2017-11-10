classdef line_moving_processor < handle
    %
    %   Class:
    %   interactive_plot.line_moving_processor
    
    %{
    Design:
    - each plot gets 2 lines to move, except for the top and bottom
    - moving the lines moves placeholders (need to render lines on the figs
    at their locations)
    - releasing the line stops the movement and changes the axes
    - lines push, but don't pull
    
    Steps
    -----------------------------
    
    
    Line Behavior
    -----------------------------
    1) Axis resize:
 

    TODO:
    1)
    
    %}
    
    properties
        parent
        fig_handle
        axes_handles
        line_handles
        
        y_positions
        % the y positions of all the lines
        
        clump_ids
        % clump_ids must always be sorted
        
        THICKNESS = 0.003;
        
        % we will not allow the lines to exceed these
        % boundaries
        TOP_BOUNDARY 
        BOTTOM_BOUNDARY 
        
    end
    
    methods
        function obj = line_moving_processor(parent)
            %
            %   Inputs:
            %   ------
            %   -axes_handles: cell array of the handles to the axes in the
            %   figure (must be in order from top to bottom!)
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            obj.axes_handles = parent.axes_handles;
            
            set(obj.fig_handle, 'Units', 'normalized');
            %   Setup lines here
            n_axes = length(obj.axes_handles);
            obj.line_handles = cell(1, n_axes + 1);
            
            % get all of the y limits of the axes
            y_low = zeros(n_axes,1);
            y_high = zeros(n_axes,1);
            
            for k = 1:n_axes
                cur_ax = obj.axes_handles{k};
                cur_pos = cur_ax.Position;
                %position is [x,y, width, length]
                y_low(k) = cur_pos(2);
                y_high(k) = y_low(k) + cur_pos(4);
            end
            
            %[x,y,w,h]
            obj.line_handles{1} = obj.createLine(y_high(1) + obj.THICKNESS/2,1);
            
            for k = 2:(length(obj.line_handles) - 1)
                % there will be a 1 pixel gap between the axes. plot the
                % line at the middle so that the moveable line overlaps
                % just 1 pixel on top of the axes line
                
                temp = (y_low(k-1) + y_high(k))/2;
                obj.line_handles{k} =  obj.createLine(temp, k);
            end
            
            % create the bottom line 1 pixel down
            obj.line_handles{end} = obj.createLine(y_low(end)- obj.THICKNESS/2, length(obj.line_handles));
            
            % set the callback functions for the inner lines
            for k = 2:(length(obj.line_handles) - 1)
                set(obj.line_handles{k}, 'ButtonDownFcn', @(~,~) obj.cb_innerLineClicked(k));
            end
            
            temp = obj.axes_handles{1}.Position;
            obj.TOP_BOUNDARY = temp(2) + temp(4);
            
            temp = obj.axes_handles{end}.Position;
            obj.BOTTOM_BOUNDARY = temp(2);
            
        end
        % function moveLine(obj, id)
        function renderLines(obj)
            n_lines_in_clump = length(obj.clump_ids);
            for k = 1:n_lines_in_clump
                idx = obj.clump_ids(k);
                line_to_move = obj.line_handles{idx};
                line_to_move.Position(2) = obj.y_positions(idx);
            end
        end
        function resizePlots(obj)
            for k = 1:length(obj.axes_handles)
                top = obj.y_positions(k) - obj.THICKNESS/2;
                bottom = obj.y_positions(k+1) + obj.THICKNESS/2;
                height = top - bottom;
                
                %TODO: build in logic so there is no overlap with the
                %lines!!!!!!!
                
                ax = obj.axes_handles{k};
                x = ax.Position(1); %bottom left corner of plot
                w = ax.Position(3); %width of the plot from x (left to right)
                set(ax, 'Position', [x, bottom, w, height]);
            end
        end
        function cb_innerLineClicked(obj, id)
            % When you first click a line, the clump is only that line
            obj.clump_ids = id;
            obj.parent.mouse_manager.initializeLineMoving(id);
        end
        function cb_outerLineClicked(obj)
            %Use different logic for an outer line versus an inner line
            %
            %Don't allow outerline moving by dragging an inner line
            %
            %Focus on inner lines first
        end
    end
    methods (Hidden)
        function h = createLine(obj, y_pos, id)
            h = annotation('rectangle', [0, y_pos - obj.THICKNESS/2, 1, obj.THICKNESS], 'FaceColor', 'k');
            obj.y_positions(id) = y_pos;
        end
    end
end

