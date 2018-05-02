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
    %   interactive_plot.settings
    %   interactive_plot.session
    %
    %   Improvements
    %   ------------
    %   1) We have too many names between this and daq2. Clean, original,
    %   safe for variables, non-empty, etc.
    
    properties
        axes_handles    %cell array
        line_handles
        data_ptrs %cell of either [] or big_plot.line_data_pointer
        eventz          %interative_plot.eventz
        
        x_min
        x_max
        
        names           %cellstr
        units           %cellstr
        
        calibrations    %cell array
        %interactive_plot.calibration
        
        n_axes
    end
    properties (Dependent)
        y_min
        y_max
        has_calibration
        clean_names
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
        function value = get.has_calibration(obj)
            value = ~cellfun('isempty',obj.calibrations);
        end
        function value = get.clean_names(obj)
            value = regexprep(obj.names,'\s','_');
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
            %
            %   obj = interactive_plot.axes.axes_props(shared)
            
            obj.axes_handles = shared.axes_handles;
            obj.eventz = shared.eventz;
            obj.n_axes = length(obj.axes_handles);
            obj.line_handles = shared.handles.line_handles;
            
            temp = cell(1,obj.n_axes);
            for i = 1:obj.n_axes
                h_line = obj.line_handles{i};
                %TEMP HACK
                if length(h_line) > 1
                    h_line = h_line(1);
                end
                temp{i} = big_plot.getRawDataPointer(h_line);
            end
            obj.data_ptrs = temp;
            
            axes_names = shared.options.axes_names;
            if isempty(axes_names)
                axes_names = cell(1,obj.n_axes);
                axes_names(:) = {''};
            end
            
            obj.names = axes_names;
            
            obj.calibrations = cell(1,obj.n_axes);
        end
    end
    methods
        function name = getNonEmptyName(obj,I)
            name = obj.names{I};
            if isempty(name)
                name = sprintf('untitled_chan__%d',I);
            end
        end
        % % %         function clean_names = getCleanAxesNames(obj,varargin)
        % % %
        % % %             in.
        % % %             if nargin == 1
        % % %                 I = 1:obj.n_axes;
        % % %             end
        % % %
        % % %             clean_names = cell(1,length(I));
        % % %             for i = 1:length(I)
        % % %                 cur_I = I(i);
        % % %                 name = obj.names{cur_I};
        % % %                 clean_names{i} = regexprep(name,'\s','_');
        % % %             end
        % % %
        % % %         end
        function displayChannelCalibrationInfo(obj)
            %
            %   displayChannelCalibrationInfo(obj)
            %
            %   This function displays a figure with a table summarizing
            %   the calibration status of each channel.
            %
            %   ??? Who calls this. A toolbar?
            
            f = figure();
            set(f,'units','normalized')
            h = uitable(f,'units','normalized','Position',[0.05 0.05 0.9 0.9]);
            %
            %   Columns
            %   --------------------
            %   - channel name
            %   - calibration name
            %   - time of calibration
            %   - ????? anything else?????
            channel_names = obj.names;
            c2 = cell(obj.n_axes,1);
            c2(:) = {''};
            c3 = cell(obj.n_axes,1);
            c3(:) = {''};
            l_units = obj.units;
            for i = 1:obj.n_axes
                cal = obj.calibrations{i};
                if ~isempty(cal)
                    c2{i} = cal.name;
                    c3{i} = datestr(cal.datenum);
                end
            end
            data = [channel_names(:) c2 c3 l_units(:)];
            set(h,'ColumnName',...
                {'Chan Name','Calibration Name','Time of Calibration','Units'},...
                'Data',data,'ColumnWidth',{120 120 130 60})
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
            
            %Trying to get rid of data_interface class and putting
            %everything in this classs
            
            h_line = obj.line_handles{I};
            
            s = big_plot.getRawLineData(h_line,varargin{:});
        end
        function setUnits(obj,value,I)
            %
            %   setUnits(obj,value,I)
            %
            
            obj.units{I} = value;
            ax = obj.axes_handles{I};
            ylabel(ax,value);
        end
        function s = getCalibrationsSummary(obj)
            %
            %   Written so that others (e.g. daq2) could apply the calibration
            %   as well.
            %
            %   Outputs
            %   -------
            %   s : interactive_plot.axes.calibration_summary
            %
            %   See Also
            %   --------
            %   interactive_plot.getCalibrationsSummary
            
            s = interactive_plot.axes.calibration_summary;
            
            n = obj.n_axes;
            
            m = ones(1,n);
            b = zeros(1,n);
            is_calibrated = false(1,n);
            
            for i = 1:n
                c = obj.calibrations{i};
                if ~isempty(c)
                    m(i) = c.m;
                    b(i) = c.b;
                    is_calibrated(i) = true;
                end
            end
            
            s.m = m;
            s.b = b;
            s.names = obj.names;
            s.is_calibrated = is_calibrated;
        end
        function loadCalibrations(obj,file_paths,varargin)
            %
            %   loadCalibrations(obj,file_paths,varargin)
            %
            
            if ischar(file_paths)
                file_paths = {file_paths};
            end
            l_clean_names = obj.clean_names;
            
            for i = 1:length(file_paths)
                h = load(file_paths{i});
                %Untitled channels not yet supported' ...
                I = find(strcmp(h.chan_name,l_clean_names));
                if isempty(I)
                    error('Unable to find match for %s',h.chan_name);
                end
                cal = interactive_plot.calibration.fromStruct(h);
                obj.setCalibration(cal,I);
            end
        end
        function setCalibration(obj,calibration,I)
            %
            %   setCalibration(obj,calibration,I)
            %
            %   Inputs
            %   ------
            %   calibration :
            %   I : 
            %
            %   See Also
            %   --------
            %   
            
            if ~isempty(calibration.units)
                obj.setUnits(calibration.units,I);
            end
            
            %For right now, line and I are the same (1 to 1 match)
            %   - we might eventually have more lines for each axes
            
            selected_line = obj.line_handles{I};
            
            %This passes the calibration to the underlying streaming data
            %object
            interactive_plot.data_interface.setCalibration(...
                selected_line,calibration);
            
            obj.eventz.notify('calibration',calibration);
            obj.calibrations{I} = calibration;
            
            %Send out a session change notification as well ...
            %-----------------------------------------------------------
            s = interactive_plot.eventz.session_updated_event_data();
            s.class_updated = 'axes_props';
            s.prop_updated = 'calibrations';
            s.event_name = 'set_calibration';
            s.axes_I = I;
            s.custom_data = calibration;
            obj.eventz.notify('session_updated',s);
            
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

