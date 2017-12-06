classdef handles < handle
    %
    %   Class:
    %   interactive_plot.handles
    
    properties
        fig_handle
        axes_handles
        line_handles
    end
    
    methods
        function obj = handles(fig_handle,axes_handles)
            %
            %   obj = interactive_plot.handles(fig_handle,axes_handles)
            
            obj.fig_handle = fig_handle;
            obj.axes_handles = axes_handles;
            
           	%Grab line handles
            %------------------------------
            temp = cell(size(obj.axes_handles));
            for i = 1:length(temp)
                temp2 = get(obj.axes_handles{i},'Children');
                %'matlab.graphics.chart.primitive.Line'
                %TODO: Filter out non-lines ...
                obj.line_handles{i} = temp2;
            end
        end
    end
    
end

