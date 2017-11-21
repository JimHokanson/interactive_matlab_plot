classdef line_moving_processor < handle
    %
    %   Class:
    %   interactive_plot.line_moving_processor
    %
    %   Main code in:
    %   interactive_plot.line_moving_processor.moveLine
    %
    %   Design:
    %     - each plot gets 2 lines to move, except for the top and bottom
    %     - moving the lines moves placeholders (need to render lines on 
    %       the figs at their locations)
    %     - releasing the line stops the movement and changes the axes
    %     - lines push, but don't pull

    
    properties
        parent
        fig_handle
        axes_handles
        line_handles
        
        y_positions
        % the y positions of all the lines
        
        clump_ids
        % clump_ids must always be sorted
        
        line_thickness
        gap_thickness
        
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
            obj.line_thickness = parent.line_thickness;
            obj.gap_thickness = parent.gap_thickness;
            
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
            
            %JAH: It would be better to push all line creation into the
            %method with submethods for inner and outer
            %[x,y,w,h]
            obj.line_handles{1} = obj.createLine(y_high(1) + obj.line_thickness/2,1);
            
            for k = 2:(length(obj.line_handles) - 1)
                % there will be a 1 pixel gap between the axes. plot the
                % line at the middle so that the moveable line overlaps
                % just 1 pixel on top of the axes line
                
                temp = (y_low(k-1) + y_high(k))/2;
                obj.line_handles{k} =  obj.createLine(temp, k);
            end
            
            % create the bottom line 1 pixel down
            obj.line_handles{end} = obj.createLine(y_low(end)- obj.line_thickness/2, length(obj.line_handles));
            
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
            %
            %   resize is based on updated y_positions.

            for k = 1:length(obj.axes_handles)
                top = obj.y_positions(k) - obj.line_thickness/2;
                bottom = obj.y_positions(k+1) + obj.line_thickness/2;
                height = top - bottom;
                
                %JAH: ???? - not sure what this means?
                %TODO: build in logic so there is no overlap with the
                %lines!!!!!!!
                
                ax = obj.axes_handles{k};
   
                %Update bottom and height simultaneously
                p = ax.Position;
                p(2) = bottom;
                p(4) = height;
                ax.Position = p;
            end
        end
        function cb_innerLineClicked(obj, id)
            %
            %   Line clicked so:
            %   - initialize mouse-movement callback
            %   - initialize grouping
            %   
            
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
            n_line_handles = length(obj.line_handles);
            colors = sl.plot.color.getEvenlySpacedColors(n_line_handles);
            h = annotation(...
                'rectangle', [0, y_pos - obj.line_thickness/2, 1, obj.line_thickness],...
                'FaceColor', colors(id,:),...
                'EdgeColor',colors(id,:));
            obj.y_positions(id) = y_pos;
        end
    end
end

