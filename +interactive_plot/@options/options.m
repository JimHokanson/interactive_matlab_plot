classdef options < handle
    %   
    %   Class:
    %   interactive_plot.options
    %
    %
    % Keeps track of the options for the interactive_plot class
    
    properties
        update_on_drag
        scroll
        lines
        streaming
        axes_names
    end
    
    properties (Hidden)
        % properties used for sizes of different elements of the
        % interactive plot like button width or scroll bar height and
        % position
        button_width = 0.02;
        bar_height = 0.04;
        bar_base_y = 0.01;
        
        % set by the interactive plot class itself
        bar_right_limit
        bar_left_limit
        
        % TODO: include line sizing options
    end
    methods
        function obj = options(varargin)  
            %
            %   obj = interactive_plot.options(varargin)
            
            in.update_on_drag = true;
            in.scroll = true;
            in.lines = true;
            in.streaming = false;

            in = interactive_plot.sl.in.processVarargin(in, varargin);
            obj.update_on_drag = in.update_on_drag;
            obj.scroll = in.scroll;
            obj.lines = in.lines;
            obj.streaming = in.streaming;
        end
    end
end