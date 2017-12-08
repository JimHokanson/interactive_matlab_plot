classdef x_zoom < handle
    %
    %   Class:
    %   interactive_plot.x_zoom
    
    properties
        parent
        axes_handles
        
        zoom_in_button
        zoom_out_button
        
        zoom_in_scale
        zoom_out_scale
    end
    
    methods
        function obj = x_zoom(parent,handles,render_params,options,scroll_right_limit,scroll_base_y)
            %
            %   obj = interactive_plot.x_zoom(parent)
            %
            %   Inputs
            %   ------
            %   parent :
            
            obj.zoom_in_scale = options.xzoom_out_scale;
            obj.zoom_out_scale = options.xzoom_in_scale;
            
            obj.parent = parent;
            obj.axes_handles = handles.axes_handles;
            
            H = render_params.small_button_height;
            L = render_params.small_button_width;
            
            % numbering (x3,x4) is based on the buttons which already exist
            % (created in the scroll_bar class which is the parent of this
            % class)
            x3 = scroll_right_limit + 2*L; % position of x zoom out button
            x4 = scroll_right_limit + 3*L; % position of x zoom in button
            y = scroll_base_y; % y position of the bottom of the scroll bar
            
            obj.zoom_out_button = interactive_plot.ip_button(obj.parent.fig_handle,[x3,y,L,H],'-');
            obj.zoom_out_button.setCallback(@(~,~) obj.cb_zoomOut);
            
            obj.zoom_in_button = interactive_plot.ip_button(obj.parent.fig_handle, [x4, y, L, H], '+');
            obj.zoom_in_button.setCallback(@(~,~) obj.cb_zoomIn);
        end
    end
    methods (Hidden)% callbacks
        function cb_zoomIn(obj)
            limits_in_view = obj.parent.time_range_in_view;
            range_in_view = limits_in_view(2) - limits_in_view(1);
            center = mean(limits_in_view);
            
            fraction_to_zoom =0.9; %move to options class
            new_time_range = range_in_view*fraction_to_zoom;
            
            lower_lim = center - new_time_range/2;
            upper_lim = center + new_time_range/2;
            new_limits = [lower_lim, upper_lim];
            obj.axes_handles{1}.XLim = new_limits;
        end
        function cb_zoomOut(obj)
            limits_in_view = obj.parent.time_range_in_view;
            range_in_view = limits_in_view(2) - limits_in_view(1);
            center = mean(limits_in_view);
            
            fraction_to_zoom =1.5; %move to options class
            new_time_range = range_in_view*fraction_to_zoom;
            
            lower_lim = center - new_time_range/2;
            upper_lim = center + new_time_range/2;
            
            max_lims = obj.parent.total_time_limits;
            
            if new_time_range >= obj.parent.total_time_range
                new_limits = max_lims;
            elseif lower_lim < max_lims(1)
                % if we are at the left edge, maintain the left position
                % and add the zoomed-in width
                new_limits = [max_lims(1), max_lims(1) + new_time_range];
            elseif upper_lim > max_lims(2)
                % if at the right edge, maintain the right position, and go
                % left to the new zoomed width
                new_limits = [max_lims(2) - new_time_range, max_lims(2)];
            else
                %the normal case
                new_limits = [lower_lim, upper_lim];
            end
            obj.axes_handles{1}.XLim = new_limits;
        end
    end
end

