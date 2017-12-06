classdef left_side_panel
    %
    %   Class:
    %   interactive_plot.left_side_panel
    
    properties
        handles
        %Logic processors ...
        y_axis_resizer
        y_zoom_buttons
        y_tick_display
        
        %Actual GUI objects
        %--------------------
        zoom_in_buttons
        zoom_out_buttons
        axis_option_buttons
    end
    
    methods
        function obj = left_side_panel(mouse_manager,handles,render_params,options)
            %
            %   obj = interactive_plot.left_side_panel(mouse_manager,handles,render_params,options)
            
            %JAH: Moving the button layout code into this class and keeping
            %the logic processing in the sub-classes.
            
            
            
            
            
            
            obj.y_axis_resizer = interactive_plot.axis_resizer(...
                mouse_manager,handles);
            obj.y_zoom_buttons = interactive_plot.y_zoom_buttons(...
                handles,render_params,options);
            obj.y_tick_display = interactive_plot.y_tick_display(handles.axes_handles);
        end
    end
    
end

