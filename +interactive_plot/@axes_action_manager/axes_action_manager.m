classdef axes_action_manager
    %
    %   Class:
    %   interactivce_plot.axes_action_manager
    %
    %   - right click to change cur_action
    %   - on mouseover change to appropriate cursor
    %   - 
    
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
    end
    
end

