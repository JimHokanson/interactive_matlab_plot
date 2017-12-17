classdef settings < handle
    %
    %   interactive_plot.settings
    
    %I want this to handle saving 
    
    properties
        options
        axes_props
        
        %The status of the button ...
        auto_scroll_enabled
        
        %The current window size for streaming
        streaming_window_size
    end
    
    methods
        function obj = settings(shared)
            obj.options = shared.options;
            obj.axes_props = interactive_plot.axes.axes_props(shared);
            
            obj.auto_scroll_enabled = shared.options.streaming;
            
            obj.streaming_window_size = shared.options.streaming_window_size;
            %keyboard
        end
        function setCalibration(obj,calibration,I)
            obj.axes_props.setCalibration(calibration,I);
        end
    end
    
end

