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
        streaming_window_size
        options
        axes_handles
        class_enabled = true
        scroll_bar
    end
    
    methods
        function obj = streaming(options,axes_handles,scroll_bar)
            %
            %   obj = interactive_plot.streaming(axes_handles)
            
            obj.streaming_window_size = options.streaming_window_size;
            obj.axes_handles = axes_handles;
            obj.scroll_bar = scroll_bar;
            
            if options.streaming
               for i = 1:length(axes_handles)
                  cur_axes = axes_handles{i};
                  set(cur_axes,'YLimMode','manual');
               end
            end
        end
        function changeMaxTime(obj,new_max_time)
            %Update scroll bar ...
            
            obj.scroll_bar.updateXMax(new_max_time);
            TIME_WINDOW = obj.streaming_window_size;
            
            %TODO: This assumes we start at 0 ...
            %----------------------------------------------
            if obj.scroll_bar.auto_scroll.scroll_enabled
                if new_max_time > TIME_WINDOW
                    new_xlim = [(new_max_time - TIME_WINDOW) new_max_time];
                    set(obj.axes_handles{1},'XLim',new_xlim)
                else
                    cur_xlim = get(obj.axes_handles{1},'XLim');
                    if cur_xlim(2) < new_max_time
                        %TODO: This might not be right ...
                        new_xlim = [0 new_max_time];
                        set(obj.axes_handles{1},'XLim',new_xlim)
                    end
                end
            end
            
        end
    end
end

