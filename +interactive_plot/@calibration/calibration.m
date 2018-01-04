classdef calibration < handle
    %
    %   Class:
    %   interactive_plot.calibration
    %
    %   Usage of calibration
    %   - If we collect data we might want to save it as calibrated
    %   but then it becomes confusing if we are working with calibrated 
    %   data or raw data, and whether or not we need to apply the
    %   calibration
    %
    %   Design Decision: work with raw data and apply calibration
    %   dynamically
    %
    %   - raw data gets collected
    %   - 
    %
    %   TODO:
    %   1) store raw data in the class for plotBig
    %   2) implement calibration variables in streaming_data
    %   3) expose placing these calibration values in at plotBig
    %
    %   See Also
    %   --------
    %   interactive_plot.calibration_gui
    %   interactive_plot.axes.axes_props
    
    
    properties
        name     %User specified name to associate with the calibration
        chan_name
        datenum  %When the calibration was created
        units
        
        %These are only populated if specifically selected.
        offset
        gain
        
        x_data
        y_data
        
        x1
        x2
        y1
        y2
        m
        b
    end
    
    methods (Static)
        function obj = createCalibration(selected_data,current_calibration,chan_name,line_handle)
            %
            %   c = interactive_plot.calibration.createCalibration(...
            %               selected_data,current_calibration,line_handle)
            %
            %   Inputs
            %   ------
            %   selected_data
            %   current_calibration : [] or interactive_plot.calibration
            %   line_handle
            
            
            
            %***** We currently don't support calibrating on
            %already calibrated data
            
            %1) We want raw data
            %2) We need it to be pre-calibration ...
            
            x_min = selected_data.x_min;
            x_max = selected_data.x_max;
            xlim = [x_min x_max];
            
            %s : big_plot.raw_line_data
            s = interactive_plot.data_interface.getRawLineData(line_handle,...
                'xlim',xlim,'get_raw',true);

            %This blocks until it is filled out or closed
            g = interactive_plot.calibration_gui(s,current_calibration);
            
            if ~g.is_ok
                obj = [];
                return;
            end
            
            obj = interactive_plot.calibration();
            obj.datenum = now;
            obj.name = g.name;
            obj.chan_name = chan_name;
            obj.units = g.units;
            
            obj.x_data = s.x;
            obj.y_data = s.y_raw;
            obj.x1 = g.x1;
            obj.x2 = g.x2;
            obj.y1 = g.y1;
            obj.y2 = g.y2;
            
            obj.m = (obj.y2 - obj.y1)/(obj.x2-obj.x1);
            obj.b = obj.y2 - obj.m*obj.x2;
            
        end
    end
    
    methods
        function obj = calibration()
            %all data filled out in static constructor
        end
        function s = struct(obj)

            %TODO: This would be better as a function that had
            %introspection on the class to guarantee all propertiers are
            %targeted
            s = struct;
            s.VERSION  = 1;
            s.STRUCT_DATE = now;
            s.TYPE = 'interactive_plot.calibration';
            s.name = obj.name;
            s.chan_name = obj.chan_name;
            s.units = obj.units;
            s.datenum = obj.datenum;
            s.offset = obj.offset;
            s.gain = obj.gain;
            s.x_data = obj.x_data;
            s.y_data = obj.y_data;
            s.x1 = obj.x1;
            s.x2 = obj.x2;
            s.y1 = obj.y1;
            s.y2 = obj.y2;
            s.m = obj.m;
            s.b = obj.b;
        end
    end
    
end

