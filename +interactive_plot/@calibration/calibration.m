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
    
    
    %TODO: Split 
    properties
        raw_x
        raw_y
        x1
        x2
        y1
        y2
    end
    
    methods (Static)
        function c = createCalibration(selected_data,line_handle)
            %
            %   c = interactive_plot.calibration.createCalibration(selected_data,line_handle)
            
            %***** We currently don't support calibrating on
            %already calibrated data
            
            %1) We want raw data
            %2) We need it to be pre-calibration ...
            
            x_min = selected_data.x_min;
            x_max = selected_data.x_max;
            xlim = [x_min x_max];
            
            %TODO: Ask for raw, not calibrated ...
            s = interactive_plot.getRawLineData(line_handle,'xlim',xlim);

            %This blocks until it is filled out or closed
            g = interactive_plot.calibration_gui(s);
            
            if ~g.is_ok
                c = [];
                return;
            end
            
            c = interactive_plot.calibration();
            c.x1 = g.x1;
            c.x2 = g.x2;
            c.y1 = g.y1;
            c.y2 = g.y2;

        end
    end
    
    methods
        function obj = calibration()
            %all filled out in static constructor
        end
    end
    
end

