classdef data_selection < handle
    %
    %   Class:
    %   interactive_plot.data_selection
    
    properties
        x_min
        x_max
        y_min
        y_max
    end
    
    methods
        function obj = data_selection(x_min,x_max,y_min,y_max)
            
            %obj = interactive_plot.data_selection(x_min,x_max,y_min,y_max)
            
            obj.y_min = y_min;
            obj.y_max = y_max;
            obj.x_min = x_min;
            obj.x_max = x_max;
            
        end
    end
    
end

