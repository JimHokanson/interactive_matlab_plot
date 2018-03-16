classdef settings < handle
    %
    %   Class:
    %   interactive_plot.settings
    %
    %   See Also
    %   --------
    %   interactive_plot.session
    %   interactive_plot.comments
        
    properties 
        options  %  interactive_plot.options
        
        axes_props  %   interactive_plot.axes.axes_props
        
        %The status of the button ...
        auto_scroll_enabled
        
        %The current window size for streaming
        streaming_window_size
        %Set via: setStreamingWindowSize
        
        %------------------
        bottom_panel
    end
    
%     methods (Static)
%         function obj = load(shared,s)
%             obj = interactive_plot.settings(shared);
%             obj.options = s.options;
%             obj.auto_scroll_enabled = s.auto_scroll_enabled;
%             obj.streaming_window_size = s.streaming_window_size;
%             obj.axes_props = interactive_plot.axes.axes_props.load(shared,s.axes_props);
%         end
%     end
    
    %Constructor ----------------------------------------------------------
    methods
        function obj = settings(shared)
            %
            %   obj = interactive_plot.settings(shared)
            
            obj.options = shared.options;
            obj.axes_props = interactive_plot.axes.axes_props(shared);
            
            obj.auto_scroll_enabled = shared.options.streaming;
            
            obj.streaming_window_size = shared.options.streaming_window_size;
                        
        end
        function load(obj,s)
            keyboard
        end
        function linkObjects(obj,bottom_panel)
            obj.bottom_panel = bottom_panel;
            is_streaming_value = true;
            bottom_panel.setWidthValue(obj.streaming_window_size,is_streaming_value)
        end
        function setStreamingWindowSize(obj,new_size)
            obj.streaming_window_size = new_size;
            if ~isempty(obj.bottom_panel)
                is_streaming_value = true;
                obj.bottom_panel.setWidthValue(obj.streaming_window_size,is_streaming_value)
            end
        end
    end
    
    
    methods
        function s = struct(obj)
            s.options = obj.options;
            s.VERSION = 1;
            s.axes_props = struct(obj.axes_props);
            s.auto_scroll_enabled = obj.auto_scroll_enabled;
            s.streaming_window_size = obj.streaming_window_size;
        end
        function setCalibration(obj,calibration,I)
            obj.axes_props.setCalibration(calibration,I);
        end
    end
    
end

