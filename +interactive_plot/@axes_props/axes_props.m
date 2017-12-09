classdef axes_props
    %
    %   Class:
    %   interactive_plot.axes_props
    %
    %   This will be the place that holds axes specific info.
    %   When we save, this is the info we care about ...
    %
    %   JAH: Work in progress ...
    
    properties
        names           %cellstr
        calibrations    %cellstr
        y_min
        y_max
    end
    
    methods
        function obj = axes_props(names)
            obj.names = names;
            handles = shared.handles;
            mouse_manager = shared.mouse_manager;
            render_params = shared.render_params;
            options = shared.options;
        end
    end
    
end

