classdef streaming
    %
    %   Class:
    %   interactive_plot.streaming
    %
    %   The goal of this class is to have a central place to focus on 
    %   things related to streaming.
    %
    %   See Also
    %   --------
    %   
    
    properties 
        options
        settings
        axes_handles
        class_enabled = true
        bottom_panel
    end
    
    properties (Dependent)
        streaming_window_size
    end
    
    methods
        function value = get.streaming_window_size(obj)
            value = obj.settings.streaming_window_size;
        end
    end
    
    methods
        function obj = streaming(shared,bottom_panel)
            %
            %   obj = interactive_plot.streaming(axes_handles)
            
            options = shared.options;
            axes_handles = shared.axes_handles;
            
            obj.axes_handles = axes_handles;
            obj.bottom_panel = bottom_panel;
            obj.options = options;
            obj.settings = shared.session.settings;
            
            if options.streaming
               for i = 1:length(axes_handles)
                  cur_axes = axes_handles{i};
                  set(cur_axes,'YLimMode','manual');
               end
               
               xlim = get(axes_handles{1},'xlim');
               if xlim(2) < obj.streaming_window_size
                   obj.changeMaxTime(obj.streaming_window_size);
               end
            end
        end
        function changeMaxTime(obj,new_max_time)
            %
            %   Update scroll bar ...
            
            %interactive_plot.bottom.scroll_bar.updateXMax
            obj.bottom_panel.scroll_bar.updateXMax(new_max_time);
            TIME_WINDOW = obj.streaming_window_size;
            
            %TODO: This assumes we start at 0 ... - low priority
            %---------------------------------------------------------
            if obj.settings.auto_scroll_enabled
                if new_max_time >= TIME_WINDOW
                    new_xlim = [(new_max_time - TIME_WINDOW) new_max_time];
                    set(obj.axes_handles{1},'XLim',new_xlim);
                else
                    new_xlim = [0 TIME_WINDOW];
                    set(obj.axes_handles{1},'XLim',new_xlim);
                end
            end
        end
    end
end

