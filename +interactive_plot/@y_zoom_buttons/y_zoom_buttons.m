classdef y_zoom_buttons < handle
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
      parent
      fig_handle %necessary?
      axes_handles
      
      zoom_in_buttons
      zoom_out_buttons
      
      options %expose at this level?
       
      ZOOM_FACTOR = 0.1;
      SPACE_FROM_AXES = 0.01;
      % best way to store buttons? multidimensional cell array?
   end
   methods
       function obj = y_zoom_buttons(parent)
           BUTTON_HEIGHT = 0.03;
           obj.parent = parent; % interactive_plot class
           obj.fig_handle = obj.parent.fig_handle;
           obj.axes_handles = obj.parent.axes_handles;
           
           button_width = obj.parent.options.button_width; 
           %ghg: this is a hidden property in the options class... 
           %...why did I do that?
           
           s = length(obj.axes_handles);
           obj.zoom_in_buttons = cell(1,s);
           obj.zoom_out_buttons = cell(1,s);
           
           
           for k = 1:length(obj.axes_handles)
               ax = obj.axes_handles{k};
               axes_right_edge = ax.Position(1) + ax.Position(3);
               bottom = ax.Position(2);
               axes_height = ax.Position(4);

               %JAH: I moved this to the left hand side
               
               %h = axes_height/2;
               h = BUTTON_HEIGHT;
               %x = axes_right_edge + obj.SPACE_FROM_AXES;
               x = 0;
               y1 = bottom; % lower position of zoom-out button
               y2 = bottom + h; % lower position of zoom-in button
               
               obj.zoom_out_buttons{k} = interactive_plot.ip_button(obj.fig_handle, [x,y1,button_width, h],'-');
               set(obj.zoom_out_buttons{k}.button, 'Callback', @(~,~)obj.cb_yZoomOut(k));
               
               obj.zoom_in_buttons{k} = interactive_plot.ip_button(obj.fig_handle, [x,y2,button_width, h],'+');
               set(obj.zoom_in_buttons{k}.button, 'Callback', @(~,~)obj.cb_yZoomIn(k));
               
               % add an action listener to the size of the axes so that
               % whenever they get taller/shorter we can adjust the size of
               % the buttons
               
               %JAH: This isn't actually running
               %Position doesn't work in >= 2014b
               addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(k));
           end
       end
       function yLimChanged(obj, idx)
           
           %JAH: This conflicts with the behavior above ...
           % idx is the index of both the axes and the zoom buttons for
           % that axes
           
           ax = obj.axes_handles{idx};
           axes_right_edge = ax.Position(1) + ax.Position(3);
           bottom = ax.Position(2);
           axes_height = ax.Position(4);
           
           button_width = obj.parent.options.button_width; 
           h = axes_height/2;
           x = axes_right_edge + obj.SPACE_FROM_AXES;
           y1 = bottom; % lower position of zoom-out button
           y2 = bottom + h; % lower position of zoom-in button
           
           obj.zoom_out_buttons{idx}.setPosition([x,y1,button_width, h]);
           obj.zoom_in_buttons{idx}.setPosition([x,y2,button_width, h]);
       end
   end
   methods %callbacks
       % TODO: should there be a reset ylim button?? also a reset for
       % xlims?
       function cb_yZoomIn(obj, idx)
           % idx: the index of axes handles to adjust
           ax = obj.axes_handles{idx};
           ylims = ax.YLim;
           y_range = ylims(2) - ylims(1);
           center = mean(ylims);
           new_y_range = y_range*(1-obj.ZOOM_FACTOR);
           
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
           new_y_range = y_range*(1+obj.ZOOM_FACTOR);
           
           y_min = center - new_y_range/2;
           y_max = center + new_y_range/2;
           ax.YLim = [y_min, y_max];
       end
   end
end