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
    %
    %   Edit Old
    %   cdata = iconeditor('icon',cdata)
    
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
        axes_panel
        axes_props %interactive_plot.axes.axes_props
    end
    
    methods
        function obj = toolbar(shared)
            %
            %   obj = interactive_plot.toolbar(h_fig,axes_handles)
            
            handles = shared.handles;
            
            obj.h_fig = handles.fig_handle;
            set(obj.h_fig,'ToolBar','none');
            obj.axes_handles = handles.axes_handles;
            obj.h_toolbar = uitoolbar(obj.h_fig);
            obj.axes_props = shared.session.settings.axes_props;
            
            
        end
        function linkComponents(obj,axes_action_manager,left_panel,axes_panel)
            root = fileparts(fileparts(which('interactive_plot')));
            
            obj.left_panel = left_panel;
            obj.axes_panel = axes_panel;
            
            icon_root = fullfile(root,'icons');
            ff = @(x) fullfile(icon_root,['icon_' x '.mat']);
            
            h = load(ff('cal_info'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Calibration Info',...
                'ClickedCallback',@(~,~) obj.axes_props.displayChannelCalibrationInfo);
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
            h = load(ff('view_new_fig'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','View in new fig',...
                'ClickedCallback',@(~,~) axes_action_manager.plotDataInNewWindow);
            h = load(ff('even_space_axes'));
            h2 = uipushtool(obj.h_toolbar,'CData',h.cdata,...
                'TooltipString','Evenly space axes',...
                'ClickedCallback',@(~,~) obj.evenlySpaceAxes);    
        end
        function evenlySpaceAxes(obj)
            processor = obj.axes_panel.line_moving_processor();
          	old_y = processor.line_y_positions;
            new_y = linspace(old_y(1),old_y(end),length(old_y)); 
            processor.resizePlots(new_y);
        end
        function nyi(obj)
            
        end
        function autoScaleAll(obj,view_only)
            %autoscale(obj,I,view_only)
            for i = 1:length(obj.axes_handles)
                obj.left_panel.autoscale(i,view_only);
            end
        end
    end
    
end

