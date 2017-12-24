classdef axes_props < handle
    %
    %   Class:
    %   interactive_plot.axes.axes_props
    %
    %   This will be the place that holds axes specific info.
    %   When we save, this is the info we care about ...
    %
    %   See Also
    %   --------
    %   
    
    properties
        axes_handles    %cell array
        line_handles
        eventz
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
            %
            %   obj = interactive_plot.axes.axes_props.load(shared,s);
            
            obj = interactive_plot.axes.axes_props(shared);
            obj.names = s.names;
            
            %Restore calibrations
            %------------------------
            for i = 1:length(obj.n_axes)
                c = s.calibrations{i};
                if ~isempty(c)
                    obj.setCalibration(calibration,i);
                end
            end
            
            %Restore ylims
            %--------------------------
            %TODO: technically this depends on auto vs manual ...
            %- if manual, restore, if auto, keep as is
            for i = 1:length(obj.axes_handles)
                ax = obj.axes_handles{i};
                set(ax,'YLim',[s.y_min(i) s.y_max(i)]);
            end
        end
    end
    
    methods
        function obj = axes_props(shared)
            obj.axes_handles = shared.axes_handles;
            obj.eventz = shared.eventz;
            obj.n_axes = length(obj.axes_handles);
            obj.line_handles = shared.handles.line_handles;
                        
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
    end
    methods
        function s = getRawLineData(obj,I,varargin)
            %
            %   Inputs
            %   ------
            %   I : which axes to retrieve data for ...
            %
            %   Optional Inputs
            %   ---------------
            %   get_x_data = true;
            %   xlim = [];
            %   get_calibrated = true;
            %   get_raw = false;
            %
            %   Outputs
            %   -------
            %   s : big_plot.raw_line_data
            
            %Trying to get rid of data_interface class
            
            h_line = obj.line_handles{I};
            
            s = big_plot.getRawLineData(h_line,varargin{:});
        end
        function setCalibration(obj,calibration,I)
            %For right now, line and I are the same ...
            selected_line = obj.line_handles{I};
            interactive_plot.data_interface.setCalibration(...
                selected_line,calibration);
            obj.eventz.notify('calibration',calibration);
            obj.calibrations{I} = calibration;
        end
        function s = struct(obj)
            
            s = struct;
            s.names = obj.names;
            s.y_min = obj.y_min;
            s.y_max = obj.y_max;
            s.calibrations = cellfun(@struct,obj.calibrations,'un',0);
            
        end
    end
    
end

