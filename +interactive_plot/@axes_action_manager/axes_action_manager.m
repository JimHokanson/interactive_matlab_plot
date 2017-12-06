classdef axes_action_manager < handle
    %
    %   Class:
    %   interactive_plot.axes_action_manager
    %
    %   - right click to change cur_action
    %   - on mouseover change to appropriate cursor
    %   -
    
    %   https://github.com/JimHokanson/interactive_matlab_plot/issues/10
    
    properties
        mouse_man
        eventz
        h_fig
        axes_handles
        line_handles
        xy_positions
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
        ptr_map
        
        last_calibration
        
        selected_axes_I
        selected_axes %matlab.graphics.axis.Axes
        selected_line
        
        selected_data %interactive_plot.data_selection
        %Only valid after data selection
        
        x_start_position
        y_start_position
        h_fig_rect
        h_axes_rect
        h_line %horizontal zoom
        y_line %vertical zoom
    end
    
    methods
        function obj = axes_action_manager(h_fig,axes_handles,line_handles,...
                xy_positions,mouse_man,eventz)
            %
            %   obj = interactive_plot.axes_action_manager()
            
            obj.h_fig = h_fig;
            obj.axes_handles = axes_handles;
            obj.line_handles = line_handles;
            obj.mouse_man = mouse_man;
            obj.eventz = eventz;
            obj.xy_positions = xy_positions;
            mouse_man.axes_action_manager = obj;
            
            c = uicontextmenu;
            
            % Create child menu items for the uicontextmenu
            % JAH: Nest menu's?????
            uimenu(c,'Label','horizontal zoom','Callback',@(~,~)obj.setActiveAction(1));
            uimenu(c,'Label','vertical zoom','Callback',@(~,~)obj.setActiveAction(2));
            uimenu(c,'Label','unrestriced zoom','Callback',@(~,~)obj.setActiveAction(3));
            uimenu(c,'Label','data select','Callback',@(~,~)obj.setActiveAction(4));
            uimenu(c,'Label','measure x','Callback',@(~,~)obj.setActiveAction(5));
            uimenu(c,'Label','measure y','Callback',@(~,~)obj.setActiveAction(6));
            uimenu(c,'Label','y average','Callback',@(~,~)obj.setActiveAction(7));
            
            n_axes = length(axes_handles);
            for i = 1:n_axes
                cur_axes = axes_handles{i};
                cur_axes.UIContextMenu = c;
            end
        end
        %TODO: Add mouse down action listener ...
        %- this should allow us to clear the current drawing for data
        %select
        function setActiveAction(obj, selected_value)
            obj.cur_action = selected_value;
        end
        function ptr = getMousePointerAndAction(obj,x,y,is_action)
            %Should be called by the mouse_motion_callback_manager
            %
            %    - cursor update ...
            %    - set mouse down action ...
            
            %https://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
            
            
            
            [I,is_line] = obj.xy_positions.getActiveAxes(x,y);
            
            if is_line
                ptr = obj.cur_action + 20;
            else
                ptr = 20;
            end
            %ptr = 4;
            
            %TODO: Are we over the lines
            
            if is_action
                %For now we are not worrying about line actions
                %since I think line callbacks will handle lines
                
                obj.clearDataSelection();
                
                obj.selected_axes_I = I;
                obj.selected_axes = obj.axes_handles{I};
                obj.selected_line = obj.line_handles{I};
                
                obj.x_start_position = x;
                obj.y_start_position = y;
                
                switch obj.cur_action
                    case 1
                        obj.initHZoom();
                    case 2

%<<<<<<< HEAD
                        obj.initYZoom();
%=======
                        %v_zoom
%>>>>>>> 7625b901f886687de5b1142186d0a49aed1bede7
                    case 3
                        %u_zoom
                    case 4
                        %data select
                        obj.initDataSelect();
                    case 5
                    case 6
                    case 7
                end
                
            end
            
            %When ready use this!
            % action = obj.all_actions{obj.cur_action};
            
        
        end
    end
        
    %Data Selection ===========================================
    methods
        function calibrateData(obj)
            %
            %   This is currently exposed via a toolbar button. It requires
            %   that data has been selected.
            
            if ~isempty(obj.selected_data)
                if length(obj.selected_line) ~= 1
                    %We could prompt which line we want ...
                    error('Only able to calibrate for 1 line per plot')
                end
                calibration = interactive_plot.calibration.createCalibration(...
                    obj.selected_data,obj.selected_line);
                if isempty(calibration)
                    return
                end
                interactive_plot.data_interface.setCalibration(obj.selected_line,calibration);
                
                notify(obj.eventz,'calibration',interactive_plot.event_data(calibration));
            else
                error('Unable to calibrate without selected data') 
            end
            
        end
        function clearDataSelection(obj)
            
            obj.selected_data = [];
            if ~isempty(obj.h_axes_rect)
                delete(obj.h_axes_rect);
                obj.h_axes_rect = [];
            end
         
        end
        function initDataSelect(obj)
            obj.mouse_man.setMouseMotionFunction(@obj.dataSelectMove);
            obj.mouse_man.setMouseUpFunction(@obj.dataSelectMouseUp);

            x = obj.x_start_position;
            y = obj.y_start_position;
            
            %TODO: Do we want this to look different?
            obj.h_fig_rect = annotation('rectangle',[x y 0.001 0.001],'Color','red');
        end
        function dataSelectMove(obj)
            %
            %   Update the rectangle drawing ...
            
            h__redrawRectangle(obj)
        end
        function dataSelectMouseUp(obj)
            %Translate figure based animation to actual data
            
            %- which axes is active?
            
            %rectangle('Position')
            
            
            %h_fig_rect
            
            %TODO: Move this to somewhere common
            ylim = get(obj.selected_axes,'YLim');
            xlim = get(obj.selected_axes,'XLim');
            x_range = xlim(2)-xlim(1);
            y_range = ylim(2)-ylim(1);
            
            p_axes = get(obj.selected_axes,'position');
            
            height = p_axes(4);
            width  = p_axes(3);
            
            x_ax_per_norm = x_range/width;
            y_ax_per_norm = y_range/height;
            
            p_fig_rect = get(obj.h_fig_rect,'Position');
            
            new_left = xlim(1) + (p_fig_rect(1)-p_axes(1))*x_ax_per_norm;
            new_bottom = ylim(1) + (p_fig_rect(2)-p_axes(2))*y_ax_per_norm;
            new_height = (p_fig_rect(4))*y_ax_per_norm;
            new_width = (p_fig_rect(3))*x_ax_per_norm;
            
            position = [new_left new_bottom new_width new_height];
            %Note that the 4th element is an alpha value (transparency)
            obj.h_axes_rect = rectangle(...
                'Position',position,...
                'EdgeColor',[0 0 0 0],'FaceColor',[0.1 0.1 0.1 0.1]);
            
            %TODO: Pass the adding into the constructor ...
            %data_selection.fromPosition
            obj.selected_data = interactive_plot.data_selection(...
                new_left,new_left+new_width,new_bottom,new_bottom+new_height);
            
            %Delete the figure based rectangle, keeping the axes
            %based rectangle
            delete(obj.h_fig_rect);
            obj.mouse_man.initDefaultState();
        end
    end
    
    %Zoom
    %======================================================================
    methods
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
            
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            y = cur_mouse_coords(2);
            x = cur_mouse_coords(1);
            
            obj.x_start_position = x;
            obj.y_start_position = y;
            
            obj.h_line = annotation('line', 'X', [x,x], 'Y' ,[y,y], 'Color', 'k');

           obj.mouse_man.setMouseMotionFunction(@obj.runHZoom);
           obj.mouse_man.setMouseUpFunction(@obj.endHzoom);
            
        end
        function runHZoom(obj)
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            x = cur_mouse_coords(1);
            set(obj.h_line, 'X', [obj.x_start_position, x]);
        end
        function endHzoom(obj)
           
            % This needs to more accessible for more classes
            delete(obj.h_line);
            obj.mouse_man.initDefaultState;
            
            %TODO: Move this to somewhere common
            xlim = get(obj.selected_axes,'XLim');
            x_range = xlim(2)-xlim(1);
            
            p_axes = get(obj.selected_axes,'position'); 
            width  = p_axes(3);
            x_ax_per_norm = x_range/width;
            
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            cur_x = cur_mouse_coords(1); 
            start_x = obj.x_start_position;
            x_positions = sort([cur_x, start_x]);
            
            %This is to make Matlab happy
            if x_positions(2) == x_positions(1)
                x_positions(2) = x_positions(1)+0.0001;
            end
            
            % need to convert the start and end x positions to the
            % corresponding coordinates in the data
            
            axes_left_edge = p_axes(1);
            data_left_edge = xlim(1) + (x_positions(1) - axes_left_edge)*x_ax_per_norm;
            data_right_edge = xlim(1) + (x_positions(2) - axes_left_edge)*x_ax_per_norm;
            
            %JAH: In order to hzoom we need to manually set the ylim so
            %that it stays the same
            %
            %This however changes the YLimMode to manual. Unfortuantely if
            %we change it back to auto then the YLim will change,
            %invalidaing our h zoom
            %
            %JAH: Do we want the other axes to be fixed as well for YLim?
            %- no, the user can always set the axes to manual - this should
            %be exposed via the ylim options
            ylim = get(obj.selected_axes,'YLim');
            set(obj.selected_axes, 'XLim', [data_left_edge, data_right_edge],...
                'YLim',ylim); 
        end
        function initYZoom(obj)
            % TODO: 
            %   Need to restrict behavior of line to stay inside of 1 axes.
            %   Otherwise very strange errors occur!
            %
            %
            % initiates the y zoom function on a given axes
            %copies heavily from Hzoom
            
             % initiates the horizontal zoom function
            % 1) change the callbacks on the mouse manager
            %   -motion , up (this class needs to own these)
            % 2) need to get the initial position
            % 3) create the line at the proper x0,y0   
            
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            y = cur_mouse_coords(2);
            x = cur_mouse_coords(1);
            
            obj.x_start_position = x;
            obj.y_start_position = y;
            
            obj.y_line = annotation('line', 'X', [x,x], 'Y' ,[y,y], 'Color', 'k');

           obj.mouse_man.setMouseMotionFunction(@obj.runYZoom);
           obj.mouse_man.setMouseUpFunction(@obj.endYzoom);
        end
        function runYZoom(obj)
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            y = cur_mouse_coords(2);
            % for some reason the y position is given as [top, bottom]
            set(obj.y_line, 'Y', [y, obj.y_start_position]);
        end
        function endYzoom(obj)
            % This needs to more accessible for more classes
            delete(obj.y_line);
            obj.mouse_man.initDefaultState;
            
            %TODO: Move this to somewhere common
            ylim = get(obj.selected_axes,'YLim');
            y_range = ylim(2)-ylim(1);
            
            p_axes = get(obj.selected_axes,'position'); 
            hieght  = p_axes(4);
            y_ax_per_norm = y_range/hieght;
            
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            cur_y = cur_mouse_coords(2); 
            start_y = obj.y_start_position;
            y_positions = sort([cur_y, start_y]);
            
            % need to convert the start and end x positions to the
            % corresponding coordinates in the data
            
            axes_bottom_edge = p_axes(2);
            data_bottom_edge = ylim(1) + (y_positions(1) - axes_bottom_edge)*y_ax_per_norm;
            data_top_edge = ylim(1) + (y_positions(2) - axes_bottom_edge)*y_ax_per_norm;
            
            set(obj.selected_axes, 'YLim', [data_bottom_edge, data_top_edge]);  
        end
        function UZoom(obj)
            % initiates the unconstrained zoom function
            % NYI!
            
        end
    end
    
end

function h__redrawRectangle(obj)
cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
y1 = cur_mouse_coords(2);
x1 = cur_mouse_coords(1);
y2 = obj.y_start_position;
x2 = obj.x_start_position;


%TODO: This currently isn't limited to the channel
%- we need to limit x and y ...

p = h__getRectanglePosition(x1,y1,x2,y2);

set(obj.h_fig_rect,'Position',p);
end

function p = h__getRectanglePosition(x1,y1,x2,y2)

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


%{
  	cdata=[...
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
        ];

%}


