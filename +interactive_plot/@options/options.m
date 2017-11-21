classdef options < handle
    % interactive_plot.options
    %
    %
    % Keeps track of the options for the interactive_plot class
    properties
        update_on_drag
        scroll
        lines
        
    end
    methods
        function obj = options(varargin)  
            in.update_on_drag = true;
            in.scroll = true;
            in.lines = true;
            % TODO: remove dependency!
            in = sl.in.processVarargin(in, varargin);
            obj.update_on_drag = in.update_on_drag;
            obj.scroll = in.scroll;
            obj.lines = in.lines;
        end
    end
end