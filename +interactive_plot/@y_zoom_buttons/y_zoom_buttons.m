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
        function obj = y_zoom_buttons(handles,render_params,options)
            obj.zoom_in_factor = options.yzoom_in_scale;
            obj.zoom_out_factor = options.yzoom_out_scale;
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;

            obj.button_height = render_params.small_button_height;
            obj.button_width = render_params.small_button_width;
            
            n_axes = length(obj.axes_handles);
            obj.zoom_in_buttons = cell(1,n_axes);
            obj.zoom_out_buttons = cell(1,n_axes);
            
            for k = 1:length(obj.axes_handles)
                ax = obj.axes_handles{k};
                
                [v1,v2] = h__getSizeVectors(obj,ax,obj.button_width,obj.button_height);
                
                obj.zoom_out_buttons{k} = interactive_plot.ip_button(obj.fig_handle, v1,'-');
                set(obj.zoom_out_buttons{k}.button, 'Callback', @(~,~)obj.cb_yZoomOut(k));
                
                obj.zoom_in_buttons{k} = interactive_plot.ip_button(obj.fig_handle, v2,'+');
                set(obj.zoom_in_buttons{k}.button, 'Callback', @(~,~)obj.cb_yZoomIn(k));
                
                % add an action listener to the size of the axes so that
                % whenever they get taller/shorter we can adjust the size of
                % the buttons
                
                addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(k));
            end
        end
        function yLimChanged(obj, idx)
            % idx is the index of both the axes and the zoom buttons for
            % that axes
            
            ax = obj.axes_handles{idx};
            
            [v1,v2] = h__getSizeVectors(obj,ax,obj.button_width,obj.button_height);

            obj.zoom_out_buttons{idx}.setPosition(v1);
            obj.zoom_in_buttons{idx}.setPosition(v2);
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

function [v1,v2] = h__getSizeVectors(obj,h_axes,button_width,button_height)
%axes_right_edge = h_axes.Position(1) + h_axes.Position(3);
bottom = h_axes.Position(2);
axes_height = h_axes.Position(4);

%h = axes_height/2;
if axes_height < 2*button_height
    button_height = axes_height/2;
end
x = 0;
y1 = bottom; % lower position of zoom-out button
y2 = bottom + button_height; % lower position of zoom-in button

v1 = [x,y1,button_width, button_height];
v2 = [x,y2,button_width, button_height];
end