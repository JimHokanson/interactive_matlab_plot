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
        xlim
        
        %How 
        streaming_window_size = 20
        x_stream_in_scale = 0.333
        x_stream_out_scale = 0.5;
        
        auto_scale_padding = 0.05
        yzoom_in_scale = 0.3
        yzoom_out_scale = 0.3
        xzoom_in_scale = 0.2;
        xzoom_out_scale = 0.2;
        scroll_button_factor = 0.05;
    end
    
    properties (Hidden)
        %JAH: I'd prefer to remove all options related to rendering
        %and only keep options related to behavior
        
        % properties used for sizes of different elements of the
        % interactive plot like button width or scroll bar height and
        % position
        
        
        % set by the interactive plot class itself
        bar_right_limit
        bar_left_limit
        
        % TODO: include line sizing options
        
        % NYI------------
        
    end
    methods
        function obj = options(varargin)  
            %
            %   obj = interactive_plot.options(varargin)
            
            in.update_on_drag = true;
            in.scroll = true;
            in.lines = true;
            in.streaming = false;
            in.axes_names = [];

            in = interactive_plot.sl.in.processVarargin(in, varargin);
            obj.update_on_drag = in.update_on_drag;
            obj.scroll = in.scroll;
            obj.lines = in.lines;
            obj.streaming = in.streaming;
            obj.axes_names = in.axes_names;
        end
    end
end