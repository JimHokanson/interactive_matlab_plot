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
        h_fig
        axes_handles
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
        all_actions
        
        %Hzoom 
        x_start_position
        y_start_position
        h_rect
        h_line
        
    end
    
    methods
        function obj = axes_action_manager(h_fig,axes_handles,mouse_man)
            %
            %   obj = interactive_plot.axes_action_manager()

            %JAH: This is a work in progress
            
            %p = containers.Map;
            %p('h
            
            obj.h_fig = h_fig;
            obj.mouse_man = mouse_man;
            mouse_man.axes_action_manager = obj;
            
            obj.all_actions = {};
%             obj.all_actions = {...
%                 obj.HZoom, ...
%                 obj.YZoom, ...
%                 obj.UZoom};
                        
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
        function setActiveAction(obj,selected_value)
            obj.cur_action = selected_value;
        end
        function [ptr,action] = getMousePointerAndAction(obj,x,y,is_action)
           %Should be called by the mouse_motion_callback_manager
           %
           %    - cursor update ...
           %    - set mouse down action ...
           
           %https://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
           
            ptr = obj.cur_action + 20;
            %ptr = 4;
            
            %TODO: Are we over the lines
            
            if is_action
                obj.x_start_position = x;
                obj.y_start_position = y;
        
                switch obj.cur_action
                    case 1
                        obj.initHZoom();
                    case 2
                    case 3
                    case 4
                        %data select
                        obj.initDataSelect();
                    case 5
                    case 6
                    case 7
                end
                
            end
            action = [];
            
            %When ready use this!
           % action = obj.all_actions{obj.cur_action};
            
        end
        function initHZoom(obj)
            % initiates the horizontal zoom function 
            % 1) change the callbacks on the mouse manager
            %   -motion , up (this class needs to own these)
            % 2) need to get the initial position
            % 3) create the line at the proper x0,y0
            
            
            x = obj.x_start_position;
            y = obj.y_start_position;
            
            %obj.x_start_position = x;
            
            obj.h_line = annotation('line', 'X', [x,x], 'Y' ,[y,y]); 
            
            %obj.mouse_man.initHZoom();

            % get the current x position of the mouse, register what this
            % position corresponds to in the data
            % as the mouse moves, draw a horizontal line
            % register the final position and what it corresponds to in
            % the data
            % adjust the xlimits to show this
            % delete the line

        end
        function initDataSelect(obj)
            obj.mouse_man.setMouseMotionFunction(@obj.dataSelectMove);
            obj.mouse_man.setMouseUpFunction(@obj.dataSelectMouseUp);
            %left
            %bottom
            %width
            %height
            x = obj.x_start_position;
            y = obj.y_start_position;
            obj.h_rect = annotation('rectangle',[x y 0.001 0.001],'Color','red');
        end
        function dataSelectMove(obj)
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            y1 = cur_mouse_coords(2);
            x1 = cur_mouse_coords(1);
            y2 = obj.y_start_position;
            x2 = obj.x_start_position;
            
            
            p = h__getRectanglePosition(x1,y1,x2,y2);
            
            set(obj.h_rect,'Position',p);
            %
            %
        end
        function dataSelectMouseUp(obj)
            %Translate figure based animation to actual data
            delete(obj.h_rect);
            obj.mouse_man.initDefaultState();
        end
        function runHZoom(obj)
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            x = cur_mouse_coords(1);
            set(obj.h_line, 'X', [obj.x_start_position, x]);
        end
        function endHzoom(obj)
            
        delete(obj.h_line);
        end
        function YZoom(obj)
           % initiates the y zoom function on a given axes
           %NYI!
        end
        function UZoom(obj)
            % initiates the unconstrained zoom function
            % NYI!
            
        end
    end
    
end

function p = h__getRectanglePosition(x1,y1,x2,y2)

%
%   A
%     \
%       B
%
%       B
%     /
%   A
%
%      A
%    /
%   B
%
%   
%   B
%    \
%      A

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


%This is only a scratch section
%------------------------------------------------
function h__setPtr(obj,ptr)
%16x16
%hotspot: 9 8

% SCALE_PTR = 1;
% PAN_PTR = 2;
% STD_PTR = 3;

obj.cur_ptr = ptr;

switch ptr
    case 1
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN       
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN 1   NaN NaN NaN NaN 1   NaN NaN NaN NaN 1   NaN NaN NaN
            NaN 1   1   NaN NaN NaN NaN 1   NaN NaN NaN NaN 1   1   NaN NaN
            1   1   1   NaN 1   1   1   1   1   1   1   NaN 1   1   1   NaN
            NaN 1   1   NaN NaN NaN NaN 1   NaN NaN NaN NaN 1   1   NaN NaN
            NaN NaN 1   NaN NaN NaN NaN 1   NaN NaN NaN NaN 1   NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    case 2
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   1   1   1   1   1   1   1   1   1   1   1   1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN 1   1   1   1   1   1   1   1   1   NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1   NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    case 3
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    case 4
    case 5
end

Data = {...
    'Pointer'            ,'custom' , ...
    'PointerShapeCData'  ,cdata    , ...
    'PointerShapeHotSpot',hotspot    ...
    };
set(obj.fig_handle,Data{:});
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


