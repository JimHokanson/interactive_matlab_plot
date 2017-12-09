classdef toolbar < handle
    %
    %   Class:
    %   interactive_plot.toolbar
    
    %Toolbar options
    %---------------
    %1) Calibrate ...
    %2) Autoscale y all
    %3) 
    
    
    properties
        h_toolbar
        h_fig
        axes_handles
    end
    
    methods
        function obj = toolbar(handles)
            %
            %   obj = interactive_plot.toolbar(h_fig,axes_handles)
            
            obj.h_fig = handles.fig_handle;
            set(obj.h_fig,'ToolBar','none');
            obj.axes_handles = handles.axes_handles;
            obj.h_toolbar = uitoolbar(obj.h_fig);
            
            
            
        end
        function linkComponents(obj,axes_action_manager)
            root = fileparts(fileparts(which('interactive_plot')));
            
            icon_root = fullfile(root,'icons');
            ff = @(x) fullfile(icon_root,['icon_' x '.mat']);
            h = load(ff('cal'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Calibrate',...
                'ClickedCallback',@(~,~) axes_action_manager.calibrateData);
        end
    end
    
end

