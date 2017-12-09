classdef x_zoom < handle
    %
    %   Class:
    %   interactive_plot.x_zoom
    
    properties
        parent
        h_axes
        
        zoom_in_button
        zoom_out_button
        
        zoom_in_scale
        zoom_out_scale
    end
    
    properties (Dependent)
        x_min
        x_max
    end
    
    methods
        function value = get.x_min(obj)
            value = obj.parent.x_min;
        end
        function value = get.x_max(obj)
            value = obj.parent.x_max;
        end
    end
    
    methods
        function obj = x_zoom(parent,zoom_out_button,zoom_in_button,handles,options)
            %
            %   obj = interactive_plot.x_zoom(parent)
            %
            %   Inputs
            %   ------
            %   parent :
            
            obj.parent = parent;
            
            obj.zoom_out_button = zoom_out_button;
            obj.zoom_in_button = zoom_in_button;
            obj.zoom_in_scale = options.xzoom_out_scale;
            obj.zoom_out_scale = options.xzoom_in_scale;
            
            obj.h_axes = handles.axes_handles{1};
            
            obj.zoom_out_button.setCallback(@(~,~) obj.cb_zoomOut);
            obj.zoom_in_button.setCallback(@(~,~) obj.cb_zoomIn);
        end
    end
    methods (Hidden)% callbacks
        function cb_zoomIn(obj)
            
            current_xlim = get(obj.h_axes,'XLim');
            range_in_view = current_xlim(2)-current_xlim(1);
            center = mean(current_xlim);
            
            fraction_to_zoom = 1 - obj.zoom_in_scale;
            new_time_range = range_in_view*fraction_to_zoom;
            
            lower_lim = center - new_time_range/2;
            upper_lim = center + new_time_range/2;
            new_limits = [lower_lim, upper_lim];
            set(obj.h_axes,'XLim',new_limits);
        end
        function cb_zoomOut(obj)
            current_xlim = get(obj.h_axes,'XLim');
            range_in_view = current_xlim(2)-current_xlim(1);
            center = mean(current_xlim);
            
            fraction_to_zoom = 1 + obj.zoom_out_scale;
            new_time_range = range_in_view*fraction_to_zoom;
            
            lower_lim = center - new_time_range/2;
            upper_lim = center + new_time_range/2;
            
            x_min_local = obj.x_min;
            x_max_local = obj.x_max;
            x_range = x_max_local - x_min_local;
            
            if new_time_range >= x_range
                new_limits = [x_min_local x_max_local];
            elseif lower_lim < x_min_local
                % if we are at the left edge, maintain the left position
                % and add the zoomed-in width
                new_limits = [x_min_local, x_min_local + new_time_range];
            elseif upper_lim > x_max_local
                % if at the right edge, maintain the right position, and go
                % left to the new zoomed width
                new_limits = [x_max_local - new_time_range, x_max_local];
            else
                %the normal case
                new_limits = [lower_lim, upper_lim];
            end
            set(obj.h_axes,'XLim',new_limits);
        end
    end
end


