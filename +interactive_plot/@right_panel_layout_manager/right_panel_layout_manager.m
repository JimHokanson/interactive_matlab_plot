classdef right_panel_layout_manager
    %
    %   Class:
    %   interactive_plot.right_panel_layout_manager
    %
    %   Right hand side:
    %   ---------------
    %   - last % value
    %   - name
    
    %   JAH: I might rename this class ... right_panel?????
    
    properties
        fig_handle
        options  %interactive_plot.options
        axes_handles
        names
    end
    
    methods
        function obj = right_panel_layout_manager(handles,options)
            %
            %   obj =
            %   interactive_plot.right_panel_layout_manager(fig_handle,axes_handles,options)
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            obj.options = options;
            obj.names = interactive_plot.names(obj.fig_handle,obj.axes_handles,options);
        end
    end
end

