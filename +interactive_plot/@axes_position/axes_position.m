classdef axes_position
    %
    %   Class:
    %   interactive_plot.axes_position
    %
    %   JAH: I'm deciding if I want to use this or not ...
    %
    %   move code from standard library
    
    properties
        h_axes
    end
    
    methods
        function obj = axes_position(h_axes)
            obj.h_axes = h_axes;
        end
    end
end

