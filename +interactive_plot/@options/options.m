classdef options < handle
    %   
    %   Class:
    %   interactive_plot.options
    %
    %   Keeps track of the options for the interactive_plot class
    %
    %   Design Notes
    %   ------------
    %   - This code should be read-only within the code base. In other
    %   words the code base should not modify these values.
    %   - These options may only be processed once. Updates to this class 
    %   don't necessarily propogate to the code base.
    %
    %   Examples
    %   --------
    %   opt = interactive_plot.options('streaming',true);
    %
    %   opt = interactive_plot.options;
    %   opt.streaming = true;
    %
    %   interactive_plot(fig,h_axes,opt)
    %
    %
    %   interactive_plot(fig,h_axes,'streaming',true);
    
    properties
        update_on_drag = true
        
        scroll = true %NYI
        lines = true %NYI
        
        streaming = false
        %Streaming indicates that we expect new data to arrive.
        
        comments  = false %logical, default false
        %If true then an area to add comments is shown on the screen
        
        axes_names = []
        
        xlim %Default xlim to use, implemented??? NYI????
        
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
    
    methods
        function obj = options(varargin)  
            %
            %   obj = interactive_plot.options(varargin)
            
            interactive_plot.sl.in.processVarargin(obj, varargin);
        end
        function struct(obj)
            
        end
    end
end