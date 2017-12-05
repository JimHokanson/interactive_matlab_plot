classdef y_axis_options
    %
    %   Class:
    %   interactive_plot.y_axis_options
    
    %   Options
    %   -------
    %   1) Autoscale
    %   2) YLimMode - manual
    %   3) YLimMode - auto
    
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
        
        ZOOM_FACTOR = 0.1;
        SPACE_FROM_AXES = 0.01;
        % best way to store buttons? multidimensional cell array?
    end
    
    methods
        function obj = y_axis_options()
           BUTTON_HEIGHT = 0.03;
            BUTTON_WIDTH = 0.03;
            
            obj.parent = parent; % interactive_plot class
            obj.fig_handle = obj.parent.fig_handle;
            obj.axes_handles = obj.parent.axes_handles;
            
            obj.button_height = BUTTON_HEIGHT;
            obj.button_width = BUTTON_WIDTH;
            %ghg: this is a hidden property in the options class...
            %...why did I do that?
            %
            %JAH: got me ... I would not have it hidden
            %
            
            s = length(obj.axes_handles);
            obj.zoom_in_buttons = cell(1,s);
            obj.zoom_out_buttons = cell(1,s);
            
            
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
    end
    
end

