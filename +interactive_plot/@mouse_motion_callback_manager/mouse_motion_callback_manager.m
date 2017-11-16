classdef mouse_motion_callback_manager < handle
    %
    %   Class:
    %   interactive_plot.mouse_motion_callback_manager
    
    properties
        fig_handle
        parent %interactive plot class
        axes_handles
    end
    
    methods
        function obj = mouse_motion_callback_manager(parent)
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            obj.axes_handles = parent.axes_handles;
            obj.initDefaultState();
            
        end
        function initializeLineMoving(obj, id)
            set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~) obj.parent.line_moving_processor.moveLine(id));
            set(obj.fig_handle, 'WindowButtonUpFcn',  @(~,~) obj.releaseLineMoving());          
        end
        function releaseLineMoving(obj)
           set(obj.fig_handle,'WindowButtonMotionFcn','');
            %JAH: Once this is released, we might want to then engage
            %a default action ...
            
            obj.parent.line_moving_processor.resizePlots();
            obj.initDefaultState();
        end
        function initializeAxisResize(obj)
        	set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~) obj.parent.line_moving_processor.moveLine(id));
        end
        function releaseAxisResize(obj)
            obj.initDefaultState();
        end
        function initDefaultState(obj)
            %TODO: Anything we want here ...
            set(obj.fig_handle,'WindowButtonMotionFcn',@(~,~) obj.defaultMouseMovingCallback());
        end
        function initializeScrolling(obj)
            % temporary hack. this is not efficient
            %--
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            obj.parent.scroll_bar.prev_mouse_x = cur_mouse_x;
            %--
            set(obj.fig_handle, 'WindowButtonMotionFcn', @(~,~) obj.parent.scroll_bar.scroll());
            set(obj.fig_handle, 'WindowButtonUpFcn', @(~,~) obj.releaseScrollBar());   
        end
        function releaseScrollBar(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn', '');
            obj.parent.scroll_bar.updateAxes();
        end
        function defaultMouseMovingCallback(obj)
            %
            %
            %   Window:
            %   ---------
            
            % - get y positions of axes
            % - determine if in reasonable range
            % - 
            
            X_MIN = 0;
            X_MAX = 0.05;
            
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_y_pos = cur_mouse_coords(2);
            cur_mouse_x_pos = cur_mouse_coords(1);
            disp(cur_mouse_coords);
            
%             call_axis_resize = cur_mouse_x_pos > 
%             
%             
%     
%             
% 
%             call_axis_resize = true;
%             %TODO: Insert logic
%             if call_axis_resize
%                 %TODO: Not sure if we want to pass in any args
%                 obj.parent.axis_resizer.registerResizeCall();
%                 
%             end
            
        end
    end
end

