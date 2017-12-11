classdef data_selection < handle
    %
    %   Class:
    %   interactive_plot.data_selection
    
    properties
        is_rect
        x_min
        x_max
        y_min
        y_max
    end
    
    methods (Static)
        function obj = fromPosition(p)
            %
            %   obj = interactive_plot.data_selection.fromPosition(p)
            
            obj = interactive_plot.data_selection;
            obj.x_min = p(1);
            obj.x_max = p(1) + p(3);
            obj.y_min = p(2);
            obj.y_max = p(2) + p(4);
        end
    end
    
    methods
    end
    
end

