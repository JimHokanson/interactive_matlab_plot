classdef shared_props
    %
    %   Class:
    %   interactive_plot.shared_props
    
    properties
        handles
        options
        render_params
        mouse_manager
        eventz
    end
    
    methods
        function obj = shared_props(handles,options,render_params,mouse_manager,eventz)
            %
            %   obj.interactive_plot.shared_props(handles,options,render_params,mouse_manager,eventz)
            
            obj.options = options;
            obj.render_params = render_params;
            obj.mouse_manager = mouse_manager;
            obj.handles = handles;
            obj.eventz = eventz;
        end
    end
    
end

