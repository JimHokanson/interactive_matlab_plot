classdef data_interface < handle
    %
    %   Class:
    %   interactive_plot.data_interface
    
    properties
    end
    
    methods (Static)
        function s = getRawLineData(h_plot,varargin)
            %
            %   s = interactive_plot.getRawLineData(h_plot,varargin)
            %
            %   Inputs
            %   ------
            %   h_plot
            %
            %   Optional Inputs
            %   ---------------
            % in.get_x_data = true;
            % in.xlim = [];
            % in.get_calibrated = true;
            % in.get_raw = false;
            %
            %   Outputs
            %   -------
            %   s : big_plot.raw_line_data
            %

            s = big_plot.getRawLineData(h_plot,varargin{:});
        end
        function setCalibration(h_plot,calibration)
            big_plot.setCalibration(h_plot,calibration);
        end
    end
    
end

