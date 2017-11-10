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
        movable_bar
        
        left_limit
        right_limit
        bar_height = 0.05;
        
        total_time_range
        time_range_in_view
        
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
        obj.background_bar = annotation('rectangle', [obj.left_limit, 0, width, obj.bar_height], 'FaceColor', 'w');
        
        
        data_objs =  get(temp1, 'Children');
        time_vector = data_objs.XData;
        obj.total_time_range = max(time_vector) - min(time_vector);
        
        end
        
    end
end