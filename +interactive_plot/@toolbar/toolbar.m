classdef toolbar < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    %
    %f = figure('ToolBar','none');
    %tb = uitoolbar(f);
    %img = zeros(16,16,3);
    %t = uitoggletool(tb,'CData',img,'TooltipString','Hello');
    %
%   https://undocumentedmatlab.com/blog/modifying-default-toolbar-menubar-actions


    %   h_pan = findall(gcf,'tag','Exploration.Pan');
    
    properties
        h_fig
        axes_handles
    end
    
    methods
        function obj = toolbar(h_fig,axes_handles)
            obj.h_fig = h_fig;
            obj.axes_handles = axes_handles;
        end
    end
    
end

