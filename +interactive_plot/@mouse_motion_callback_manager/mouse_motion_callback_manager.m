classdef mouse_motion_callback_manager < handle
    %
    %   Class:
    %   interactive_plot.mouse_motion_callback_manager
    %
    %   Processors should call this function.
    %
    %   The idea is to place any mouse related logic that interacts with
    %   the figure here. Anything that can be tied specifically into a
    %   component should go there instead.
    %
    %   JAH: this class got named a bit too specifically. Ideally this
    %   would be mouse_callback_manager
    %
    %   We might also want 2+ classes
    %   - mouse movement
    %   - mouse clicking (specifically on the figure)
    
    properties
        fig_handle
        axes_action_manager
        parent %interactive plot class
        axes_handles
        axis_resizer
        
        %Resize limits
        %------------
        x1
        x2
        x3
        x4
        y_min_axes
        y_max_axes
        x_min_axes
        x_max_axes
        cur_ptr = 0
    end
    
    methods
        function obj = mouse_motion_callback_manager(parent)
            obj.parent = parent;
            obj.axes_action_manager = parent.axes_action_manager;
            obj.fig_handle = parent.fig_handle;
            obj.axes_handles = parent.axes_handles;
            obj.axis_resizer = parent.axis_resizer;
            
            %Determine limits for axis resizer
            %-------------------------------------------------
            temp = get(obj.axes_handles{1},'position');
            obj.x4 = temp(1) - 0.02; %left most part of axis
            obj.x3 = obj.x4 - 0.02;
            obj.x2 = obj.x3 - 0.02;
            obj.x1 = obj.x2 - 0.02;
            obj.x_min_axes = temp(1);
            obj.x_max_axes = temp(1)+temp(3);
            
            obj.initDefaultState();
            
            obj.y_max_axes = temp(2) + temp(4);
            temp = get(obj.axes_handles{end},'position');
            obj.y_min_axes = temp(2);
                        
        end
        function setMouseMotionFunction(obj,fcn)
            set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~)fcn());
        end
        function setMouseUpFunction(obj,fcn)
            set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~)fcn());
        end
        %Line moving
        %------------------------------------------------------------------
        function initializeLineMoving(obj, id)
            set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~) obj.parent.line_moving_processor.moveLine(id));
            set(obj.fig_handle, 'WindowButtonUpFcn',  @(~,~) obj.releaseLineMoving());
        end
        function releaseLineMoving(obj)
            set(obj.fig_handle,'WindowButtonMotionFcn','');
            obj.parent.line_moving_processor.resizePlots();
            obj.initDefaultState();
        end
        %Axis resizing
        %------------------------------------------------------------------
        function initializeScaleTopFixed(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn',...
                @(~,~) obj.axis_resizer.processScaleTopFixed());
            set(obj.fig_handle, 'WindowButtonUpFcn',  ...
                @(~,~) obj.releaseAxisResize());
        end
        function initializeScaleBottomFixed(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn',...
                @(~,~) obj.axis_resizer.processScaleBottomFixed());
            set(obj.fig_handle, 'WindowButtonUpFcn',  ...
                @(~,~) obj.releaseAxisResize());
        end
        function initializeAxisPan(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn',...
                @(~,~) obj.axis_resizer.processPan());
            set(obj.fig_handle, 'WindowButtonUpFcn',  ...
                @(~,~) obj.releaseAxisResize());
        end
        function releaseAxisResize(obj)
            obj.initDefaultState();
        end
        
        
        %Scrolling
        %------------------------------------------------------------------
        function initializeScrolling(obj)
            % temporary hack. this is not efficient
            %--
            %JAH: This looks fine but I'm not clear why this code is here
            %and not in the scroll bar class
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            obj.parent.scroll_bar.prev_mouse_x = cur_mouse_x;
            %--
            set(obj.fig_handle, 'WindowButtonMotionFcn', @(~,~) obj.parent.scroll_bar.scroll());
            set(obj.fig_handle, 'WindowButtonUpFcn', @(~,~) obj.releaseScrollBar());
        end
        function releaseScrollBar(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn', '');
            if ~obj.parent.options.update_on_drag
                obj.parent.scroll_bar.updateAxes();
            end
        end
        %Defaults
        %------------------------------------------------------------------
        function initDefaultState(obj)
            set(obj.fig_handle,'WindowButtonMotionFcn',@(~,~) obj.defaultMouseMovingCallback());
            set(obj.fig_handle,'WindowButtonDownFcn',@(~,~) obj.defaultMouseDownCallback());
            set(obj.fig_handle,'WindowButtonUpFcn','');
        end
        function defaultMouseDownCallback(obj)
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            y = cur_mouse_coords(2);
            x = cur_mouse_coords(1);
            
            h__getInfoByMousePosition(obj,x,y,true);
        end
        function defaultMouseMovingCallback(obj)
            %
            %
            %   Window:
            %   ---------
            
            
            %TODO:
            %1) maintain an array of y-positions - this will need to update
            %  if we change the axes size
            %2) when in range (but no mouse click) change the cursor
            %       - top half of each axes - pull down or pan
            %       - bottom half - pull up or pan
            %       - for now toggle between pan and pull every 5% of the
            %       axis
            %
            %   Pull behavior:
            %   - keep extreme the same
            %   - based on where we grab relative to the fixed point, scale
            %   everything else
            %   - if we pass the bottom point ... (not sure what to do)
            
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            y = cur_mouse_coords(2);
            x = cur_mouse_coords(1);
            
            %Determine appropriate cursor
            %----------------------------
            ptr = h__getInfoByMousePosition(obj,x,y,false);
            
            if isempty(ptr)
                return;
            end
            
            if ptr ~= obj.cur_ptr
                h__setPtr(obj,ptr)
            end
        end
    end
end

function ptr = h__getInfoByMousePosition(obj,x,y,is_action)

%JAH: I'm not thrilled with this setup of merging ptr and action
%but I also didnt like having the same checks twice

STD_PTR = 0;
SCALE1_PTR = 1;
SCALE2_PTR = 2;
PAN_PTR = 3;

action = [];

if y > obj.y_min_axes && y < obj.y_max_axes
    
    if x > obj.x_min_axes && x < obj.x_max_axes
        ptr = obj.axes_action_manager.getMousePointerAndAction(x,y,is_action);
    elseif x > obj.x1 && x < obj.x2
        ptr = SCALE1_PTR;
        if is_action
            obj.axis_resizer.registerResizeCall(y,1);
        end
    elseif x > obj.x2 && x < obj.x3
        ptr = SCALE2_PTR;
        if is_action
            obj.axis_resizer.registerResizeCall(y,2);
        end
    elseif x > obj.x3 && x < obj.x4
        ptr = PAN_PTR;
        if is_action
            obj.axis_resizer.registerResizeCall(y,2);
        end
    else
        
        
        ptr = STD_PTR;
    end
else
    ptr = STD_PTR;
end


end

function h__setPtr(obj,ptr)
%16x16
%hotspot: 9 8

% SCALE_PTR = 1;
% PAN_PTR = 2;
% STD_PTR = 3;

obj.cur_ptr = ptr;

switch ptr
    case 0
        setptr(obj.fig_handle,'arrow')
        return
    case 1
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1   NaN NaN NaN NaN NaN
            NaN NaN NaN 1   1   1   1   1   1   1   1   1   NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   1   1   1   1   1   1   1   1   1   1   1   1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
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
    case 3  %vertical pan on lhs
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
    case 21 %Horizontal zoom ...
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
    case 22  %Vertical zoom ...
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN         
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1 NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    case 23  %Unconstrained zoom ...
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   1   1   1   1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   1   1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN         
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN 1   NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1 NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN 1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   1   1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   1   1   1   1   NaN NaN
            ];
        hotspot = [8 8];
     case 24  %data select
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN         
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1 NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];    
    case 25   %measure x
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN         
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN 1   1   1   1   1   1   1   1   1   NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];

    case 26
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN         
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1 NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    case 27
        %1  2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
        cdata=[...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN         
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN 1   1   1   1   1   1   1 NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
            ];
        hotspot = [8 8];
    
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
