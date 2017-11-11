classdef mouse_motion_callback_manager < handle
    %
    %   Class:
    %   interactive_plot.mouse_motion_callback_manager
    
    properties
        fig_handle
        parent %interactive plot class
    end
    
    methods
        function obj = mouse_motion_callback_manager(parent)
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            
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
    end
end

