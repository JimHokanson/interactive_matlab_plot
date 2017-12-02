classdef toolbar < handle
    %
    %   Class:
    %   interactive_plot.toolbar
    
    %f = figure('ToolBar','none');
    %tb = uitoolbar(f);
    %img = zeros(16,16,3);
    %t = uitoggletool(tb,'CData',img,'TooltipString','Hello');
    %
%   https://undocumentedmatlab.com/blog/modifying-default-toolbar-menubar-actions

%   addpath(fullfile(matlabroot,'toolbox/matlab/guide/guitools'))

    %   h_pan = findall(gcf,'tag','Exploration.Pan');
    
    properties
        h_toolbar
        h_fig
        axes_handles
    end
    
    methods
        function obj = toolbar(h_fig,axes_handles,axes_action_manager)
            %
            %   obj = interactive_plot.toolbar(h_fig,axes_handles)
            
            obj.h_fig = h_fig;
            set(h_fig,'ToolBar','none');
            obj.axes_handles = axes_handles;
            h_toolbar = uitoolbar(h_fig);
            
            root = fileparts(fileparts(which('interactive_plot')));
            
            icon_root = fullfile(root,'icons');
            ff = @(x) fullfile(icon_root,['icon_' x '.mat']);
            h = load(ff('cal'));
            h2 = uipushtool(h_toolbar,'CData',h.cdata,...
                'TooltipString','Calibrate',...
                'ClickedCallback',@(~,~) axes_action_manager.calibrateData);
            
        end
    end
    
end

