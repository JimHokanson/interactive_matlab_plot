classdef toolbar < handle
    %
    %   Class:
    %   interactive_plot.toolbar
    %
    %??? - How did I do the editing?
    %
    %   addpath(fullfile(matlabroot,'toolbox/matlab/guide/guitools'))
    %   cdata = iconeditor;
    %   save('icon_<name>.mat','cdata')
    
    %Toolbar options
    %---------------
    %1) Calibrate ...
    %2) Autoscale y all
    %3) 
    
    
    properties
        h_toolbar
        h_fig
        axes_handles
        left_panel
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
        function linkComponents(obj,axes_action_manager,left_panel)
            root = fileparts(fileparts(which('interactive_plot')));
            
            obj.left_panel = left_panel;
            
            icon_root = fullfile(root,'icons');
            ff = @(x) fullfile(icon_root,['icon_' x '.mat']);
            h = load(ff('cal'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Calibrate',...
                'ClickedCallback',@(~,~) axes_action_manager.calibrateData);
            h = load(ff('auto_y_global'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Auto-Scale Y - Global',...
                'ClickedCallback',@(~,~) obj.autoScaleAll(false));
         	h = load(ff('auto_y_local'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Auto-Scale Y - View Only',...
                'ClickedCallback',@(~,~) obj.autoScaleAll(true));
                
        end
        function autoScaleAll(obj,view_only)
            %autoscale(obj,I,view_only)
            for i = 1:length(obj.axes_handles)
                obj.left_panel.autoscale(i,view_only);
            end
        end
    end
    
end

