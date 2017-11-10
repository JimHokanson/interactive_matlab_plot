classdef line_moving_processor
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
        
        y_positions % the y positions of all the lines
        
        inches_per_pixel
                
        TOP_BOUNDARY = 0.9
        BOTTOM_BOUNDARY = 0.1
        
        POINT_SIZE = 1/72 %inches
        LINE_THICKNESS = 3 %pixels
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

            set(obj.fig_handle, 'Units', 'pixels');
            %   Setup lines here
            n_axes = length(obj.axes_handles);
            obj.line_handles = cell(1, n_axes + 1);
            
            % get all of the y limits of the axes
            y_low = zeros(n_axes,1);
            y_high = zeros(n_axes,1);
            
            for k = 1:n_axes
                cur_ax = obj.axes_handles{k};
                set(cur_ax,'units', 'pixels');
                cur_pos = cur_ax.Position;
                %position is [x,y, width, length]
                y_low(k) = cur_pos(2);
                y_high(k) = y_low(k) + cur_pos(4);
            end

            % Line width, specified as a positive value in point units. One point equals 1/72 inch.
            % let's set this to be 3 pixels
            set(obj.fig_handle,'Units', 'pixels');
            height_in_pixels = obj.fig_handle.Position(4);
            
            set(obj.fig_handle, 'Units','Inches');
            height_in_inches = obj.fig_handle.Position(4);
            
            obj.inches_per_pixel = height_in_inches/height_in_pixels;
            
            %LINE_THICKNESS is in pixels
            %obj.POINT_SIZE is in inches
            % need to convert to line width
            line_width_in_point_units = obj.LINE_THICKNESS*obj.inches_per_pixel/obj.POINT_SIZE;
                  
            set(obj.fig_handle, 'Units', 'pixels');
            fig_width = obj.fig_handle.Position(3);
            
            createLine = @(y_pos) annotation('line', 'Units', 'pixels', 'LineWidth', line_width_in_point_units, 'X', [0, fig_width], 'Y', [y_pos, y_pos]);

           % lines will be created so that they do not overlap with the
            % axes lines (axes lines are evidently 1 pixel).
            %
            % create the top line
            
            % linewidth goes out from center. go up 1 pixels so that a
            % 3-wide line does not overlap beyond the line of the axes into
            % the plot
            obj.line_handles{1} = createLine(y_high(1)+1);
            
            for k = 2:(length(obj.line_handles) - 1)
                % there will be a 1 pixel gap between the axes. plot the
                % line at the middle so that the moveable line overlaps 
                % just 1 pixel on top of the axes line
                
                temp = (y_low(k-1) + y_high(k))/2;
                obj.line_handles{k} =  createLine(temp);
            end
            
            % create the bottom line 1 pixel down
            obj.line_handles{end} = createLine(y_low(end)-1);

            % set the callback functions for the inner lines
            for k = 2:(n_lines - 1)
                set(obj.line_handles{k}, 'ButtonDownFcn', @(~,~) obj.cb_innerLineClicked(k));
            end
            
        end
        function moveLine(obj, id)
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_y_pos = cur_mouse_coords(2);
            
            
            line_to_move = obj.line_handles{id};
            line_to_move.Position(2) = cur_y_pos;
 
        end
        function resizePlots(obj)
            for k = 1:length(obj.axes_handles)
                top = obj.y_positions(k);
                bottom = obj.y_line_positions(k+1);
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
            %Put code here
            obj.parent.mouse_manager.initializeLineMoving(id);
        end
        function cb_outerLineMoved(obj)
            %Use different logic for an outer line versus an inner line
            %
            %Don't allow outerline moving by dragging an inner line
            %
            %Focus on inner lines first
        end
    end
end

