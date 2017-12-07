classdef y_zoom_buttons < handle
    %
    %   Class:
    %   interactive_plot.y_zoom_buttons
    %
    %   Creates zoom in/zoom out buttons next to each plot
    %   optionally only creates zoom buttons next to only the plots which
    %   are specified in the optional input arguments
    %
    %   Improvements:
    %
    %
    
    properties
        button_height
        button_width
    end
    
    properties
        parent
        fig_handle %necessary?
        axes_handles
        
        zoom_in_buttons
        zoom_out_buttons
        
        options %expose at this level?
        
        zoom_in_factor
        zoom_out_factor
    end
    methods
        function obj = y_zoom_buttons(handles,render_params,options,zoom_in_buttons,zoom_out_buttons)
            obj.zoom_in_factor = options.yzoom_in_scale;
            obj.zoom_out_factor = options.yzoom_out_scale;
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;

            obj.button_height = render_params.small_button_height;
            obj.button_width = render_params.small_button_width;
            
            n_axes = length(obj.axes_handles);
            obj.zoom_in_buttons = zoom_in_buttons;
            obj.zoom_out_buttons = zoom_out_buttons;
            
            for k = 1:n_axes
                z1 = obj.zoom_out_buttons{k};
                z1.setCallback(@(~,~)obj.cb_yZoomOut(k));
                
                z2 = obj.zoom_in_buttons{k};
                z2.setCallback(@(~,~)obj.cb_yZoomIn(k));             
            end
        end
    end
    methods %callbacks
        %JAH: That's a good idea but low priority.
        % TODO: should there be a reset ylim button?? also a reset for
        % xlims?
        function cb_yZoomIn(obj, idx)
            % idx: the index of axes handles to adjust
            ax = obj.axes_handles{idx};
            ylims = ax.YLim;
            y_range = ylims(2) - ylims(1);
            center = mean(ylims);
            new_y_range = y_range*(1-obj.zoom_in_factor);
            
            y_min = center - new_y_range/2;
            y_max = center + new_y_range/2;
            ax.YLim = [y_min, y_max];
        end
        function cb_yZoomOut(obj, idx)
            % idx: the index of axes handles to adjust
            ax = obj.axes_handles{idx};
            ylims = ax.YLim;
            y_range = ylims(2) - ylims(1);
            center = mean(ylims);
            new_y_range = y_range*(1+obj.zoom_out_factor);
            
            y_min = center - new_y_range/2;
            y_max = center + new_y_range/2;
            ax.YLim = [y_min, y_max];
        end
    end
end