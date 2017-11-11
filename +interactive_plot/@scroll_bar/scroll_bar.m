classdef scroll_bar <handle
    %   interactive_plot.scroll_bar
    %
    %   creates a scroll bar on a figure with the interactive plot
    %
    properties
        parent
        fig_handle %interactive_plot class
        
        left_button
        right_button
        background_bar
        slider
        
        base_y = 0.01;
        left_limit
        right_limit
        bar_height = 0.04;
        width
        
        total_time_range
        time_range_in_view
        
        slider_left_x
        slider_right_x
        
        prev_mouse_x
    end
    
    methods
        function obj = scroll_bar(parent)
        obj.parent = parent;
        obj.fig_handle = parent.fig_handle;
        
        set(obj.fig_handle, 'Units', 'normalized');
        temp1 = obj.parent.axes_handles{1};
        temp2 = temp1.Position;
        obj.left_limit = temp2(1);
        obj.right_limit = temp2(1) + temp2(3);
        width = obj.right_limit - obj.left_limit;
        obj.background_bar = annotation('rectangle', [obj.left_limit, obj.base_y, width, obj.bar_height], 'FaceColor', 'w');
        
        
        data_objs =  get(temp1, 'Children');
        time_vector = data_objs.XData;
        obj.total_time_range = max(time_vector) - min(time_vector);
        
        %create the slider
        obj.slider = annotation('rectangle', [obj.left_limit, obj.base_y, width, obj.bar_height], 'FaceColor', 'k');
        obj.slider_left_x = obj.left_limit;
        obj.slider_right_x = obj.right_limit;
        
        % get the time range that we have zoomed to (currently just base it
        % on the first plot -- will need to figure out how to update all
        % plots zooming together
        set(obj.slider, 'ButtonDownFcn', @(~,~) obj.parent.mouse_manager.initializeScrolling);
        ax = obj.parent.axes_handles{1};
        %addlistener(ax, 'XLim', 'PostSet', @(~,~) obj.checkTimeRange);
        end
        function checkTimeRange(obj)
           % just check axes 1 for proof of concept...
           ax = obj.parent.axes_handles{1};
           x_min = ax.XLim(1);
           x_max = ax.XLim(2);
           
           obj.slider_left_x = x_min/obj.total_time_range;
           obj.slider_right_x = x_max/obj.total_time_range;
           obj.width = obj.slider_right_x - obj.slider_left_x;
           obj.time_range_in_view = ax.XLim;
           
           % put the 
           set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.width, obj.bar_height]);
        end
        function scroll(obj)
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            
            dif = cur_mouse_x - obj.prev_mouse_x;
            new_right_limit = obj.slider_right_x  + dif;
            new_left_limit = obj.slider_left_x + dif;
            
            if new_right_limit >= obj.right_limit
                % have to base position on this edge
                obj.slider_left_x = obj.right_limit - obj.width;
                obj.slider_right_x = obj.right_limit;
            elseif new_left_limit <= obj.left_limit
                obj.slider_left_x = obj.left_limit;
                obj.slider_right_x = obj.slider_left_x + obj.width;
            else
                obj.slider_left_x = new_left_limit;
                obj.slider_right_x = new_right_limit;
            end
            set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.width, obj.bar_height]);
            obj.prev_mouse_x = cur_mouse_x;
        end
        function updateAxes(obj)
            % convert the left position to a time
            max_width = (obj.right_limit - obj.left_limit);
            left_time = (obj.slider_left_x/max_width)*obj.total_time_range;
            right_time = (obj.slider_right_x/max_width)*obj.total_time_range;
            
            axes_handles = obj.parent.axes_handles;
            ax = axes_handles{1};
            ax.XLim = [left_time, right_time];
        end
    end
end