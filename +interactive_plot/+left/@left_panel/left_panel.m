classdef left_panel
    %
    %   Class:
    %   interactive_plot.left_panel
    %
    %   See Also
    %   --------
    
    properties
        fig_handle
        axes_handles
        button_height
        button_width
        axes_props
        
        %Logic processors ...
        %-----------------------------
        y_axis_resizer
        y_zoom_buttons
        y_tick_display      %interactive_plot.left.y_tick_display
        y_axis_options      %interactive_plot.left.y_axis_options
        
        %Actual GUI objects
        %--------------------
        zoom_in_buttons
        zoom_out_buttons
        axis_option_buttons
    end
    
    methods
        function obj = left_panel(shared)
            %
            %   obj = interactive_plot.left_panel(mouse_manager,handles,render_params,options)
            
            %The button layout code is in this class and 
            %the logic processing in the sub-classes.
            
            handles = shared.handles;
            mouse_manager = shared.mouse_manager;
            render_params = shared.render_params;
            options = shared.options;
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            obj.axes_props = shared.session.settings.axes_props;

            obj.button_height = render_params.small_button_height;
            obj.button_width = render_params.small_button_width;
            
            n_axes = length(obj.axes_handles);
            obj.zoom_in_buttons = cell(1,n_axes);
            obj.zoom_out_buttons = cell(1,n_axes);
            obj.axis_option_buttons = cell(1,n_axes);
            
            %Units resolving
            %---------------
            if isempty(options.default_units)
                units = cell(1,n_axes);
                units(:) = {''};
            elseif ischar(options.default_units)
                units = cell(1,n_axes);
                units(:) = {options.default_units};
            elseif iscell(options.default_units)
                if length(options.default_units) ~= n_axes
                    error('Improper length of default units cell')
                end
                units = options.default_units;
            else
                error('Unexpected type for default units')
            end
            
            obj.axes_props = units;
            
            for k = 1:n_axes
                ax = obj.axes_handles{k};
                
                ylabel(ax,units(k));
                
                [v1,v2,v3] = h__getSizeVectors(obj,ax,obj.button_width,obj.button_height);
                
                obj.zoom_out_buttons{k} = interactive_plot.utils.ip_button(...
                    obj.fig_handle, v1,'-');
                
                obj.zoom_in_buttons{k} = interactive_plot.utils.ip_button(...
                    obj.fig_handle, v2,'+');
                
                obj.axis_option_buttons{k} = interactive_plot.utils.ip_button(...
                    obj.fig_handle, v3,'...');
                
                % add an action listener to the size of the axes so that
                % whenever they get taller/shorter we can adjust the size of
                % the buttons
                addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(k));
            end
            
            obj.y_axis_resizer = interactive_plot.left.y_axis_resizer(...
                mouse_manager,handles);
            obj.y_zoom_buttons = interactive_plot.left.y_zoom_buttons(...
                handles,render_params,options,obj.zoom_in_buttons,obj.zoom_out_buttons);
            obj.y_tick_display = interactive_plot.left.y_tick_display(shared);
            obj.y_axis_options = interactive_plot.left.y_axis_options(...
                shared,obj.axis_option_buttons);
        end
        function autoscale(obj,I,view_only)
            %TODO: Document ...
            obj.y_axis_options.autoscale(view_only,I);
        end
        function figureSizeChanged(obj)
            obj.y_tick_display.redrawAll();
        end
     	function yLimChanged(obj, idx)
            % idx is the index of both the axes and the zoom buttons for
            % that axes
            
            ax = obj.axes_handles{idx};
            
            [v1,v2,v3] = h__getSizeVectors(obj,ax,obj.button_width,obj.button_height);

            obj.zoom_out_buttons{idx}.setPosition(v1);
            obj.zoom_in_buttons{idx}.setPosition(v2);
            obj.axis_option_buttons{idx}.setPosition(v3);
        end
    end
    
end

function [v1,v2,v3] = h__getSizeVectors(obj,h_axes,button_width,button_height)
%axes_right_edge = h_axes.Position(1) + h_axes.Position(3);
bottom = h_axes.Position(2);
axes_height = h_axes.Position(4);

%h = axes_height/2;
if axes_height < 3*button_height
    button_height = axes_height/3;
end
x = 0;
y1 = bottom; % lower position of zoom-out button
y2 = bottom + button_height; % lower position of zoom-in button
y3 = y2 + button_height;

v1 = [x,y1,button_width, button_height];
v2 = [x,y2,button_width, button_height];
v3 = [x,y3,button_width, button_height];
end

