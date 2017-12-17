classdef axes_props < handle
    %
    %   Class:
    %   interactive_plot.axes_props
    %
    %   This will be the place that holds axes specific info.
    %   When we save, this is the info we care about ...
    %
    %   JAH: Work in progress ...
    
    properties
        axes_handles    %cell array
        names           %cellstr
        calibrations    %cell array
        n_axes
    end
    properties (Dependent)
        y_min
        y_max
    end
    
    methods
        function value = get.y_min(obj)
            value = zeros(1,obj.n_axes);
            for i = 1:obj.n_axes
                ax = obj.axes_handles{i};
                p = get(ax,'Position');
                value(i) = p(2);
            end
        end
        function value = get.y_max(obj)
            value = zeros(1,obj.n_axes);
            for i = 1:obj.n_axes
                ax = obj.axes_handles{i};
                p = get(ax,'Position');
                value(i) = p(2) + p(4);
            end
        end
    end
    
    methods (Static)
        function obj = load(shared,s)
            
        end
    end
    
    methods
        function obj = axes_props(shared)
            obj.axes_handles = shared.axes_handles;
            obj.n_axes = length(obj.axes_handles);
            
            axes_names = shared.options.axes_names;
            if isempty(axes_names)
                axes_names = cell(1,obj.n_axes);
                axes_names(:) = {''};
            else
                %TODO: This could be made optional
                % - spaces replaced as well with newlines ...
                %names = regexprep(names,'_','\n');
            end
            
            obj.names = axes_names;
            
            obj.calibrations = cell(1,obj.n_axes);
        end
        function setCalibration(obj,calibration,I)
            obj.calibrations{I} = calibration;
        end
        function struct(obj)
            
        end
    end
    
end

