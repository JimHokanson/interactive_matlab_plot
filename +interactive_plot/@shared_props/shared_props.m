classdef shared_props < handle
    %
    %   Class:
    %   interactive_plot.shared_props
    
    properties
        fig_handle
        axes_handles
        handles
        options
        render_params
        mouse_manager
        eventz
        session
        toolbar
    end
    
    methods
        function obj = shared_props()
            %
            %   obj.interactive_plot.shared_props(handles,options,render_params,mouse_manager,eventz)
            
%             obj.options = options;
%             obj.render_params = render_params;
%             obj.mouse_manager = mouse_manager;
%             obj.handles = handles;
%             obj.eventz = eventz;
        end
    end
    
end

