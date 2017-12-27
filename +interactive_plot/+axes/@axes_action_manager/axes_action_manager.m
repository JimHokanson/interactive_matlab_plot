classdef axes_action_manager < handle
    %
    %   Class:
    %   interactive_plot.axes_action_manager
    %
    %
    %   See Also:
    %   interactive_plot.mouse_manager
    
    properties
        line_moving_processor
        rhs_disp
        x_disp
        mouse_man   %interactive_plot.mouse_manager
        eventz      %interative_plot.eventz
        h_fig
        axes_handles
        line_handles
        xy_positions %interactive_plot.axes.axes_position_info
        
        settings     %interactive_plot.settings
        axes_props
        
        
        cur_action = 1
        %- 1) h_zoom - horizontal zoom
        %- 2) v_zoom - vertical zoom
        %- 3) u_zoom - unrestricted zoom
        %- 4) data_select
        %       - custom callbacks
        %       - plotting selections overlayed
        %- 5) measure_x
        %- 6) measure_y - draw vertical line and show how tall the line is
        %- 7) y average - this would be a horizontal select
        
        
        last_calibration
        
        %Fill out when clicked
        %--------------------------------------------
        selected_axes_I
        selected_axes %matlab.graphics.axis.Axes
        selected_line
        
        x_start_position
        y_start_position
        %--------------------------------------------
        
        %Data selection results
        %--------------------------------------------
        x_clicked %When a single point is time has been clicked
        %This value may be empty ...
        %
        selected_data %interactive_plot.data_selection
        %Only valid after data selection
        
        h_fig_rect
        h_fig_line
        h_axes_rect
        h_axes_line
        
        
        % keep track of this for resetting the zoom on double click
        % this gets updated the first time the horizontal zoom is used
        % before zoom changes.
        initial_x_ranges = [] %[xmin, xmax]
        x_zoom_axes_idx = [];
        % this will be a bit more complicated for the yzoom case because we
        % will have to keep track of which plot was zoomed on
        % initial_y_range is a matrix where each row corresponds to an axes
        % in order and each column corresponds to the initial y ranges
        
        initial_y_ranges = [];
        y_zoom_axes_idx = [];
        
        h_init_tic
        
    end
    
    methods
        function obj = axes_action_manager(shared,xy_positions)
            %
            %   obj = interactive_plot.axes_action_manager()
            
            handles = shared.handles;
            
            obj.settings = shared.session.settings;
            obj.h_fig = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            obj.line_handles = handles.line_handles;
            obj.mouse_man = shared.mouse_manager;
            obj.eventz = shared.eventz;
            obj.xy_positions = xy_positions;
            obj.axes_props = obj.settings.axes_props;
            
            c = uicontextmenu;
            uimenu(c,'Label','data select','Callback',@(~,~)obj.setActiveAction(4));
            uimenu(c,'Label','horizontal zoom','Callback',@(~,~)obj.setActiveAction(1));
            uimenu(c,'Label','vertical zoom','Callback',@(~,~)obj.setActiveAction(2));
            uimenu(c,'Label','unrestriced zoom','Callback',@(~,~)obj.setActiveAction(3));
            uimenu(c,'Label','measure x','Callback',@(~,~)obj.setActiveAction(5));
            uimenu(c,'Label','measure y','Callback',@(~,~)obj.setActiveAction(6));
            uimenu(c,'Label','y average','Callback',@(~,~)obj.setActiveAction(7));
            
            n_axes = length(obj.axes_handles);
            for i = 1:n_axes
                cur_axes = obj.axes_handles{i};
                cur_axes.UIContextMenu = c;
            end
            
            obj.setActiveAction(4);
        end
        function linkObjects(obj,rhs_disp,x_disp)
            %Called after initialization to add extra constructed objects
            %for later use
            obj.rhs_disp = rhs_disp;
            obj.x_disp = x_disp;
        end
        function setActiveAction(obj, selected_value)
            
            obj.clearDataSelection();
            
            % update this for the double click zoom reset
            if ~isequal(obj.cur_action, selected_value)
                
                obj.x_zoom_axes_idx = [];
                obj.y_zoom_axes_idx = [];
                
                obj.initial_x_ranges = zeros(length(obj.axes_handles), 2);
                % [left1, right1 ...
                %  left2, right2]
                
                %[bottom1, top1
                % bottom2, top2
                % etc...       ]
                obj.initial_y_ranges = zeros(length(obj.axes_handles), 2);
            end
            
            obj.cur_action = selected_value;
        end
        function ptr = getMousePointerAndAction(obj,x,y,is_action)
            %Should be called by the mouse_motion_callback_manager as
            %the 'default' action when over the axes (or lines)
            %
            %    - cursor update ...
            %    - set mouse down action ...
            
            %https://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
            
            [I,is_line] = obj.xy_positions.getActiveAxes(x,y);
            
            if is_line
                ptr = 20;
            else
                ptr = obj.cur_action + 20;
            end
            
            if is_action
                %For now we are not worrying about line actions
                %since I think line callbacks will handle lines
                DBL_CLICK_TIME = 0.5;
                
                if is_line
                    %Do we want to clear in this case as well?
                    obj.line_moving_processor.cb_innerLineClicked(I);
                    return
                end
                
                obj.clearDataSelection();
                
                obj.selected_axes_I = I;
                obj.selected_axes = obj.axes_handles{I};
                obj.selected_line = obj.line_handles{I};
                
                obj.x_start_position = x;
                obj.y_start_position = y;
                
                switch obj.cur_action
                    case 1
                        if obj.mouse_man.time_since_last_mouse_down < DBL_CLICK_TIME
                            obj.resetZoom();
                        else
                            obj.initHZoom();
                        end
                    case 2
                        if obj.mouse_man.time_since_last_mouse_down < DBL_CLICK_TIME
                            obj.resetZoom();
                        else
                            obj.initYZoom();
                        end
                    case 3
                        if obj.mouse_man.time_since_last_mouse_down < DBL_CLICK_TIME
                            obj.resetZoom();
                        else
                            obj.initUZoom();
                        end
                    case 4
                        obj.initDataSelect();
                    case 5
                        obj.initMeasureX();
                    case 6
                        obj.initMeasureY();
                    case 7
                        obj.initAverageY();
                end
                
            end
        end
    end
    
    %Data Selection ===========================================
    methods
        function calibrateData(obj)
            %
            %   This is currently exposed via a toolbar button. It requires
            %   that data has been selected.
            
            %TODO: Rescale ylim following calibration
            %
            %- This gets tricky if we are calibrating on already calibrated
            %  data.
            

            
            
            if ~isempty(obj.selected_data)
                if length(obj.selected_line) ~= 1
                    %We could prompt which line we want ...
                    error('Currently only able to calibrate for 1 line per plot')
                end
                calibration = interactive_plot.calibration.createCalibration(...
                    obj.selected_data,obj.selected_line);
                if isempty(calibration)
                    return
                end
                
                obj.settings.setCalibration(calibration,obj.selected_axes_I);
            else
                error('Unable to calibrate without selected data')
            end
        end
        function clearDataSelection(obj)
            
            obj.selected_data = [];
            obj.x_clicked = [];
            if ~isempty(obj.h_axes_rect)
                delete(obj.h_axes_rect);
                obj.h_axes_rect = [];
            end
            if ~isempty(obj.h_axes_line)
                delete(obj.h_axes_line);
                obj.h_axes_line = [];
            end
        end
        function initDataSelect(obj)
            obj.h_init_tic = tic;
            obj.mouse_man.setMouseMotionFunction(@obj.dataSelectMove);
            obj.mouse_man.setMouseUpFunction(@obj.dataSelectMouseUp);
            
            h__drawInitialRectFromMouse(obj,'r')
        end
        function dataSelectMove(obj)
            %
            %   Update the rectangle drawing ...
            
            h__redrawRectangle(obj)
        end
        function dataSelectMouseUp(obj)
            %Do we want anything width based? (i.e. too small a rectangle?
            %so make it a line instead?)
            MIN_RECT_TIME = 0.5;
            %Not sure how high we can go ...
            Y_MAX = 1e9;
            
            elapsed_time = toc(obj.h_init_tic);
            
            p_new = h__translateRectangle(obj.selected_axes,obj.h_fig_rect);
            %If too quick, draw a line
            if elapsed_time < MIN_RECT_TIME
                x = p_new(1);
                obj.x_clicked = x;
                obj.h_axes_line = line([x x],[-Y_MAX Y_MAX],'YLimInclude','off','Linewidth',2,'Color','k');
            else
                
                %TODO: Expose this in render params
                %Note that the 4th element is an alpha value (transparency)
                obj.h_axes_rect = rectangle(...
                    'Position',p_new,...
                    'EdgeColor',[0 0 0 0],'FaceColor',[0.1 0.1 0.1 0.1]);
                
                obj.selected_data = interactive_plot.data_selection.fromPosition(p_new);
            end
            
            %Delete the figure based rectangle, keeping the axes based rectangle
            delete(obj.h_fig_rect);
            obj.mouse_man.initDefaultState();
        end
    end
    
    %Zoom
    %======================================================================
    methods
        function resetZoom(obj)
            % called on the double click to reset the zoom to what it was
            % before the current click-and-drag zoom option was selected
            % TODO: document this better
            
            switch obj.cur_action
                case 1
                    % hzoom
                    x_lims = obj.initial_x_ranges(obj.selected_axes_I,:);
                    if ~isequal(x_lims, [0,0])
                        set(obj.selected_axes, 'XLim', x_lims);
                    end
                case 2
                    %yzoom
                    y_lims = obj.initial_y_ranges(obj.selected_axes_I,:);
                    if ~isequal(y_lims, [0,0])
                        set(obj.selected_axes, 'YLim', y_lims);
                    end
                case 3
                    %uzoom
                    x_lims = obj.initial_x_ranges(obj.selected_axes_I,:);
                    if ~isequal(x_lims, [0,0])
                        set(obj.selected_axes, 'XLim', x_lims);
                    end
                    y_lims = obj.initial_y_ranges(obj.selected_axes_I,:);
                    if ~isequal(y_lims, [0,0])
                        set(obj.selected_axes, 'YLim', y_lims);
                    end
                otherwise
                    error('Code error, unexpected case')
            end
        end
        function initHZoom(obj)
            % TODO: need to limit behavior to stay inside the axes
            %   allow esc press to cancel
            %
            %
            % initiates the horizontal zoom function
            % 1) change the callbacks on the mouse manager
            %   -motion , up (this class needs to own these)
            % 2) need to get the initial position
            % 3) create the line at the proper x0,y0
            
            if isequal(obj.initial_x_ranges(obj.selected_axes_I, :), [0,0])
                obj.initial_x_ranges(obj.selected_axes_I,:) = obj.selected_axes.XLim;
            end
            
            obj.mouse_man.setMouseMotionFunction(@obj.runHZoom);
            obj.mouse_man.setMouseUpFunction(@obj.endHzoom);
            
            h__drawInitialLineFromMouse(obj)
        end
        function runHZoom(obj)
            x = h__getConstrainedPoint(obj);
            
            set(obj.h_fig_line, 'X', [obj.x_start_position, x]);
        end
        function endHzoom(obj)
            
            % This needs to more accessible for more classes
            
            obj.mouse_man.initDefaultState;
            
            x_fig = get(obj.h_fig_line, 'X');
            x_axes = h__translateX(obj.selected_axes,x_fig);
            x_axes = sort(x_axes);
            if x_axes(2) - x_axes(1) < 1e-9
                x_axes(2) = x_axes(1)+1e-9;
            end
            
            %We add y_lim so that we get purely horizontal zooming,
            %otherwise the axes would adjust ylim on xlim zooming, which
            %is not the behavior we expect for a horizontal-only zoom
            %
            %TODO: Keep track of ylim mode, on resetk, reset ylimmode as well
            y_lim = get(obj.selected_axes,'YLim');
            set(obj.selected_axes, 'XLim', [x_axes(1), x_axes(2)],...
                'YLim',y_lim);
            
            delete(obj.h_fig_line)
        end
    end
    methods
        function initYZoom(obj)
            % TODO:
            %   Need to restrict behavior of line to stay inside of 1 axes.
            %   Otherwise very strange errors occur!
            %
            %
            % initiates the y zoom function on a given axes
            %copies heavily from Hzoom
            
            % 1) change the callbacks on the mouse manager
            %   -motion , up (this class needs to own these)
            % 2) need to get the initial position
            % 3) create the line at the proper x0,y0
            
            axes_idx = obj.selected_axes_I;
            initial_y_range = obj.initial_y_ranges(axes_idx, :);
            
            if isequal(initial_y_range, [0,0])
                obj.initial_y_ranges(axes_idx, :) = obj.selected_axes.YLim;
            end
            
            h__drawInitialLineFromMouse(obj)
            
            obj.mouse_man.setMouseMotionFunction(@obj.runYZoom);
            obj.mouse_man.setMouseUpFunction(@obj.endYzoom);
        end
        function runYZoom(obj)
            [~,y] = h__getConstrainedPoint(obj);
            
            set(obj.h_fig_line, 'Y', [obj.y_start_position, y]);
        end
        function endYzoom(obj)
            % This needs to more accessible for more classes
            
            obj.mouse_man.initDefaultState;
            
            y_fig = get(obj.h_fig_line, 'Y');
            y_axes = h__translateY(obj.selected_axes,y_fig);
            y_axes = sort(y_axes);
            if y_axes(2) - y_axes(1) < 1e-9
                y_axes(2) = y_axes(1)+1e-9;
            end
            
            %See note in endXZoom about setting other limits
            x_lim = get(obj.selected_axes,'XLim');
            set(obj.selected_axes, 'YLim', [y_axes(1), y_axes(2)],...
                'XLim',x_lim);
            
            delete(obj.h_fig_line);
        end
    end
    methods
        function initUZoom(obj)
            % initiates the unconstrained zoom function
            %
            
            
            %TODO: Make these functions ...
            % for resetting the y lims:
            axes_idx = obj.selected_axes_I;
            initial_y_range = obj.initial_y_ranges(axes_idx, :);
            if isequal(initial_y_range, [0,0])
                obj.initial_y_ranges(axes_idx, :) = obj.selected_axes.YLim;
            end
            % for resetting the xlims:
            if isequal(obj.initial_x_ranges(obj.selected_axes_I, :), [0,0])
                obj.initial_x_ranges(obj.selected_axes_I,:) = obj.selected_axes.XLim;
            end
            
            h__drawInitialRectFromMouse(obj)
            
            obj.mouse_man.setMouseMotionFunction(@obj.runUZoom);
            obj.mouse_man.setMouseUpFunction(@obj.endUZoom);
        end
        function runUZoom(obj)
            h__redrawRectangle(obj)
        end
        function endUZoom(obj)
            % This needs to more accessible for more classes
            %
            
            obj.mouse_man.initDefaultState;
            
            
            p_new = h__translateRectangle(obj.selected_axes,obj.h_fig_rect);
            
            set(obj.selected_axes, 'XLim', [p_new(1), p_new(1)+p_new(3)]);
            set(obj.selected_axes, 'YLim', [p_new(2), p_new(2)+p_new(4)]);
            
            delete(obj.h_fig_rect);
        end
    end
    
    %Measure X ============================================================
    methods
        function initMeasureX(obj)
            % measures the distance in the data between mouse down and mouse
            % up on a given plot
            
            h__drawInitialLineFromMouse(obj)
            
            obj.mouse_man.setMouseMotionFunction(@obj.runMeasureX);
            obj.mouse_man.setMouseUpFunction(@obj.endMeasureX);
        end
        function runMeasureX(obj)
            x = h__getConstrainedPoint(obj);
            set(obj.h_fig_line, 'X', [obj.x_start_position, x]);
        end
        function endMeasureX(obj)
            
            obj.mouse_man.initDefaultState();
            
            x_fig = get(obj.h_fig_line, 'X');
            x_axes = h__translateX(obj.selected_axes,x_fig);
            x_axes = sort(x_axes);
            
            measurement = x_axes(2) - x_axes(1);
            set(obj.x_disp,'String',sprintf('%g',measurement));
            
            delete(obj.h_fig_line)
        end
    end
    
    %Measure Y ============================================================
    methods
        function initMeasureY(obj)
            h__drawInitialLineFromMouse(obj)
            
            obj.mouse_man.setMouseMotionFunction(@obj.runMeasureY);
            obj.mouse_man.setMouseUpFunction(@obj.endMeasureY);
        end
        function runMeasureY(obj)
            [~,cur_y] = h__getConstrainedPoint(obj);
            set(obj.h_fig_line, 'Y', [cur_y, obj.y_start_position]);
        end
        function endMeasureY(obj)
            obj.mouse_man.initDefaultState();
            
            y_fig = get(obj.h_fig_line, 'Y');
            y_axes = h__translateY(obj.selected_axes,y_fig);
            y_axes = sort(y_axes);
            
            measurement = y_axes(2) - y_axes(1);
            
            %TODO: Idealy this would be a call to a class ...
            obj.rhs_disp{obj.selected_axes_I}.String = sprintf('%g',measurement);
            
            delete(obj.h_fig_line);
        end
    end
    
    %Average Y
    %============================================================
    methods  
        function initAverageY(obj)
            obj.mouse_man.setMouseMotionFunction(@obj.runAverageY);
            obj.mouse_man.setMouseUpFunction(@obj.endAverageY);
            
            h__drawInitialLineFromMouse(obj)

                        
            %TODO: Replace with rectangle over entire y range
            %h__drawInitialYBoundedRectFromMouse(obj)
        end
        function runAverageY(obj)
            
            %h__redrawRectangle(obj)
            
            x = h__getConstrainedPoint(obj);
            
            set(obj.h_fig_line, 'X', [obj.x_start_position, x]);
        end
        function endAverageY(obj)
            
            % This needs to more accessible for more classes
            
            obj.mouse_man.initDefaultState;
            
            %p_new = h__translateRectangle(obj.selected_axes,obj.h_fig_rect);

            x_fig = get(obj.h_fig_line, 'X');
            x_axes = h__translateX(obj.selected_axes,x_fig);
            
            s = obj.settings.axes_props.getRawLineData(obj.selected_axes_I,...
                'get_x_data',false,...
                'xlim',x_axes);
                
            measurement = mean(s.y_final);
            
            obj.rhs_disp{obj.selected_axes_I}.String = sprintf('%g',measurement);
            delete(obj.h_fig_line);
        end
    end
end

function h__drawInitialYBoundedRectFromMouse(obj,color)

%TODO:
%- for average-y - NYI
%- get y from axes
%- fill in the rectangle
if nargin == 1
    color = 'k';
end
x = obj.x_start_position;
y = obj.y_start_position;
obj.h_fig_rect = annotation('rectangle',[x y 0.001 0.001],'Color',color);
end

function h__drawInitialRectFromMouse(obj,color)
if nargin == 1
    color = 'k';
end
x = obj.x_start_position;
y = obj.y_start_position;
obj.h_fig_rect = annotation('rectangle',[x y 0.001 0.001],'Color',color);
end

function h__drawInitialLineFromMouse(obj)
y = obj.y_start_position;
x = obj.x_start_position;

obj.h_fig_line = annotation('line', 'X', [x,x], 'Y' ,[y,y], 'Color', 'k');

end

function [x,y] = h__getCurrentPoint(obj)

[x,y] = interactive_plot.utils.getCurrentMousePoint(obj.h_fig);

end

function [x,y] = h__getConstrainedPoint(obj)
%Returns point (in fig space) that is within the axes
[x,y] = h__getCurrentPoint(obj);

%Get the bounds of the current axes
p_axes = obj.selected_axes.Position;
left_limit = p_axes(1);
right_limit = p_axes(1) + p_axes(3);
lower_limit = p_axes(2);
upper_limit = p_axes(2) + p_axes(4);

if x > right_limit
    x = right_limit;
elseif x < left_limit
    x = left_limit;
end
if y > upper_limit
    y = upper_limit;
elseif y < lower_limit
    y = lower_limit;
end
end

function h__redrawRectangle(obj)
[x1,y1] = h__getConstrainedPoint(obj);
y2 = obj.y_start_position;
x2 = obj.x_start_position;

p = h__getRectanglePosition(x1,y1,x2,y2);

set(obj.h_fig_rect,'Position',p);
end

function p = h__getRectanglePosition(x1,y1,x2,y2)
%
%   This function creates a valid position value from the start point and
%   the current mouse point.

%   x1,y1 - start point
%   x2,y2 - current point
%
%   From these two points create a position output

height = abs(y2 - y1);
width = abs(x2 - x1);

if x1 < x2
    left = x1;
else
    left = x2;
end

if y1 < y2
    bottom = y1;
else
    bottom = y2;
end

p = [left bottom width height];
end

function p_new = h__translateRectangle(h_axes,h_rect)
%Converts position of rectangle from fig based to axes based
p_old = get(h_rect,'Position');

x1 = p_old(1);
x2 = p_old(1) + p_old(3);
y1 = p_old(2);
y2 = p_old(2) + p_old(4);

x1_new = h__translateX(h_axes,x1);
x2_new = h__translateX(h_axes,x2);
y1_new = h__translateY(h_axes,y1);
y2_new = h__translateY(h_axes,y2);

p_new = [x1_new, y1_new, x2_new-x1_new, y2_new-y1_new];

end

function x_axes = h__translateX(h_axes,x_fig)
%Converts x value from figure to axes

%   x_axes = interactive_plot.utils.translateXFromFigToAxes(h_axes,x_fig)

xlim = get(h_axes,'XLim');

p_axes = get(h_axes,'position');

x1 = p_axes(1);
x2 = p_axes(1)+p_axes(3);
y1 = xlim(1);
y2 = xlim(2);

m = (y2 - y1)./(x2 - x1);
b = y2 - m*x2;

x_axes = m*x_fig + b;
end

function y_axes = h__translateY(h_axes,y_fig)
%Converts y value from figure to axes
ylim = get(h_axes,'YLim');

p_axes = get(h_axes,'position');

x1 = p_axes(2);
x2 = p_axes(2)+p_axes(4);
y1 = ylim(1);
y2 = ylim(2);

m = (y2 - y1)./(x2 - x1);
b = y2 - m*x2;

y_axes = m*y_fig + b;
end