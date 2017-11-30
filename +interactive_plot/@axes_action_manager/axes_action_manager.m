classdef axes_action_manager
    %
    %   Class:
    %   interactivce_plot.axes_action_manager
    %
    %   - right click to change cur_action
    %   - on mouseover change to appropriate cursor
    %   - 
    
    %   https://github.com/JimHokanson/interactive_matlab_plot/issues/10
    
    properties
        cur_action = 'h_zoom'
        %- v_zoom - vertical zoom
        %- u_zoom - unrestricted zoom
        %- data_select
        %       - custom callbacks
        %       - plotting selections overlayed
        %- measure_x
        %- measure_y
        %- y_average
    end
    
    methods
        function obj = axes_action_manager()
            
        end
        function mouseOverAxes()
           %Should be called by the mouse_motion_callback_manager
           %
           %    - cursor update ...
           %    - set mouse down action ...
        end
    end
    
end

