classdef x_zoom < handle
    %
    %   Class:
    %   interactive_plot.x_zoom
    
    properties
        parent
        axes_handles
        
        zoom_in_button
        zoom_out_button
    end
    
    methods
        function obj = x_zoom(parent)
            %
            %   obj = interactive_plot.x_zoom(parent)
            %
            %   Inputs
            %   ------
            %   parent :
            obj.parent = parent;
            obj.axes_handles = parent.parent.axes_handles;
            
            H = obj.parent.bar_height;
            L = obj.parent.button_width;
            
            % numbering (x3,x4) is based on the buttons which already exist
            % (created in the scroll_bar class which is the parent of this
            % class)
            x3 = obj.parent.right_limit + 2*L; % position of x zoom out button
            x4 = obj.parent.right_limit + 3*L; % position of x zoom in button
            y = obj.parent.base_y; % y position of the bottom of the scroll bar
            
            obj.zoom_out_button = uicontrol(obj.parent.fig_handle,...
                'Style', 'pushbutton', 'String', '-',...
                'units', 'normalized', 'Position',[x3, y, L, H],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_zoomOut);

            obj.zoom_in_button = uicontrol(obj.parent.fig_handle,...
                'Style', 'pushbutton', 'String', '+',...
                'units', 'normalized', 'Position',[x4, y, L, H],...
                'Visible', 'on', 'callback', @(~,~)obj.cb_zoomIn);
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
                        
            fraction_to_zoom =1.1; %move to options class
            new_time_range = range_in_view*fraction_to_zoom;
            
            lower_lim = center - new_time_range/2;
            upper_lim = center + new_time_range/2;
            new_limits = [lower_lim, upper_lim];
            
            max_lims = obj.parent.total_time_limits;
            
            if (lower_lim < max_lims(1) || upper_lim > max_lims(2))
               obj.axes_handles{1}.XLim = max_lims;
            else
              obj.axes_handles{1}.XLim = new_limits;
            end
        end
    end
end

