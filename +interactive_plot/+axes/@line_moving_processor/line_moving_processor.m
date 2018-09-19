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
        
        mouse_man
        fig_handle
        xy_positions    %interactive_plot.xy_positions
        options
        
        axes_handles
        %Cell array. These must be ordered from top to bottom.
        
        line_handles
        
        line_y_positions
        %The y positions of all the lines.
        %This includes the outer lines ...
        
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
        function obj = line_moving_processor(shared,xy_positions)
            %
            %   Inputs:
            %   ------
            %   -axes_handles: cell array of the handles to the axes in the
            %   figure (must be in order from top to bottom!)
            
            handles = shared.handles;
            render_params = shared.render_params;
            
            obj.mouse_man = shared.mouse_manager;
            obj.xy_positions = xy_positions;
            obj.options = shared.options;
            
            obj.line_thickness = render_params.line_thickness;
            obj.gap_thickness = render_params.gap_thickness;
            
            obj.fig_handle = handles.fig_handle;
            
            obj.axes_handles = handles.axes_handles;
            
            axes_tops = xy_positions.axes_tops;
            axes_bottoms = xy_positions.axes_bottoms;
            
            h__initLines(obj,axes_tops,axes_bottoms)

            temp = obj.axes_handles{1}.Position;
            obj.TOP_BOUNDARY = temp(2) + temp(4);
            
            temp = obj.axes_handles{end}.Position;
            obj.BOTTOM_BOUNDARY = temp(2);
            
        end
        %In other files
        %--------------
        %   moveLine(obj, id)
        
        function renderLines(obj,ids)
            if nargin == 1
                ids = obj.clump_ids;
            end
            n_lines = length(ids);
            for k = 1:n_lines
                idx = ids(k);
                line_to_move = obj.line_handles{idx};
                line_to_move.Position(2) = obj.line_y_positions(idx);
            end
        end
        function resizePlots(obj,new_line_y_positions)
            %
            %   resize is based on updated y_positions.
            %
            %   resizePlots(obj,*new_line_y_positions)
            %
            %   Normally this is called after moving the lines with 
            %   the mouse. It can also be called with a second input
            %   to resize the plots based on the axes
            %
            %   Example
            %   --------
            %   %This will evenly space all axes
            %   old_y = obj.line_y_positions;
            %   new_y = linspace(old_y(1),old_y(end),length(old_y));
            
            if nargin == 2
                obj.line_y_positions = new_line_y_positions;
                move_lines = true;
            else
                move_lines = false;
            end
            
            tops = obj.line_y_positions(1:end-1) - 0.5*obj.line_thickness;
            bottoms = obj.line_y_positions(2:end) + 0.5*obj.line_thickness;
            
            obj.xy_positions.updateAxesTopAndBottoms(tops,bottoms);  
            
            if move_lines
               obj.renderLines(1:length(obj.line_y_positions)); 
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
            
            %Note that moveLine is in a different file
            obj.mouse_man.setMouseMotionFunction(@()obj.moveLine(id));
            
            obj.mouse_man.setMouseUpFunction(@obj.releaseLineMoving);
        end
        function releaseLineMoving(obj)
            obj.resizePlots();
            obj.mouse_man.initDefaultState();
        end
        function cb_outerLineClicked(obj)
            %Use different logic for an outer line versus an inner line
            %
            %Don't allow outerline moving by dragging an inner line
            %
            %Focus on inner lines first
        end
    end
end


function h__initLines(obj,ax_tops,ax_bottoms)

n_axes = length(obj.axes_handles);

obj.line_handles = cell(1, n_axes+1);
obj.line_y_positions = zeros(1, n_axes+1);

%Top line
%----------------
obj.line_handles{1} = h__createLine(obj,ax_tops(1) + obj.line_thickness/2,1);

for k = 2:(length(obj.line_handles) - 1)
    % there will be a 1 pixel gap between the axes. plot the
    % line at the middle so that the moveable line overlaps
    % just 1 pixel on top of the axes line
    
    temp = (ax_bottoms(k-1) + ax_tops(k))/2;
    obj.line_handles{k} =  h__createLine(obj,temp, k);
    
    %JAH: Eventually we could do a mouse-over driven
            %callback which would allow us to expand the effect size of the
            %line
    %set(obj.line_handles{k}, 'ButtonDownFcn', @(~,~) obj.cb_innerLineClicked(k));
end

%Bottom line
%-------------------
% create the bottom line 1 pixel down
obj.line_handles{end} = h__createLine(obj,ax_bottoms(end)- obj.line_thickness/2, length(obj.line_handles));

end


function h = h__createLine(obj, y_pos, id)
n_line_handles = length(obj.line_handles);
colors = interactive_plot.sl.plot.color.getEvenlySpacedColors(n_line_handles);
h = annotation(obj.fig_handle,...
    'rectangle', [0, y_pos - obj.line_thickness/2, 1, obj.line_thickness],...
    'FaceColor', colors(id,:),...
    'EdgeColor',colors(id,:));
obj.line_y_positions(id) = y_pos;
end