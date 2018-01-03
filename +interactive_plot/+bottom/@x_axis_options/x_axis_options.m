classdef x_axis_options < handle
    %
    %   Class:
    %   interactive_plot.bottom.x_axis_options
    %
    %   X Axis Options
    %   --------------
    %   - zoom out completely
    %   - change x axis ticks
    %       - 
    
    
    properties
        fig_handle
        h_button
        h_top_axes
        h_context_menu
        axes_props
    end
    
    methods
        function obj = x_axis_options(shared,h_button)
            %
            %   obj = interactive_plot.bottom.x_axis_options(shared,h_button)
            
            obj.fig_handle = shared.fig_handle;
            obj.h_button = h_button;
            
            obj.axes_props = shared.session.settings.axes_props;
            obj.h_top_axes = shared.axes_handles{1};
            
            c = uicontextmenu('Parent',obj.fig_handle);
                        
            uimenu(c,'Label','zoom out completely',...
                'Callback',@(~,~)obj.zoomOutCompletely);
            
            set(obj.h_button,'Callback',@(~,~)obj.buttonClicked());
            
            obj.h_context_menu = c;
        end
        function zoomOutCompletely(obj)
            set(obj.h_top_axes,'xlim',[obj.axes_props.x_min obj.axes_props.x_max]);
        end
        function buttonClicked(obj)
            drawnow('nocallbacks')
            %disp('button clicked')
            
            current_button = obj.h_button;
            p = getpixelposition(current_button);
            %Position must be in pixel units for context menu
            %The context menu only takes in a xy of the upper left corner
            
            set(obj.h_context_menu,'Visible','on','Position',p(1:2))
            
            %This seems to help with reliability of the context menu
            %showing up ...
            drawnow('nocallbacks')
        end
    end
    
end

