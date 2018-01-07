classdef fig_menu < handle
    %
    %   Class:
    %   interactive_plot.fig_menu
    
    properties
        h_fig
    end
    
    methods
        function obj = fig_menu(shared)
            %
            %   obj = interactive_plot.fig_menu(shared)
            
            obj.h_fig = shared.fig_handle;
            set(obj.h_fig,'MenuBar', 'none')
            
            %2017b specific 'Text'
            %m = uimenu(obj.h_fig,'Text','File');
            %mitem = uimenu(m,'Text','Save Calibrations','MenuSelectedFcn',@(~,~)shared.session.saveCalibrations);
        end
    end
end

