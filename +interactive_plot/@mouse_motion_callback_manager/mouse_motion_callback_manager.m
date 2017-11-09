classdef mouse_motion_callback_manager
    %
    %   Class:
    %   interactive_plot.mouse_motion_callback_manager
    
    properties
        fig_handle
    end
    
    methods
        function obj = mouse_motion_callback_manager(fig_handle)
        end
        function initializeLineMoving(obj)
        end
        function releaseLineMoving(obj)
            %set(f,'WindowButtonMotionFcn','');

            %JAH: Once this is released, we might want to then engage
            %a default action ...
        end
    end
end

