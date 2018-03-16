classdef data_interface < handle
    %
    %   Class:
    %   interactive_plot.data_interface
    %
    %   This contains a set of methods to communicate with the underyling
    %   streaming data objects used for plotting.
    %
    %   See Also
    %   --------
    %   big_plot.streaming_data
    
    properties
    end
    
    methods (Static)
        function s = getRawLineData(h_plot,varargin)
            %
            %   s = interactive_plot.data_interface.getRawLineData(h_plot,varargin)
            %
            %   Returns actual data for a line. Since the lines are
            %   subsampled for plotting, we can't just get the underlying
            %   data by accesssing the xdata and ydata properties. 
            %
            %   Instead a handle to the object that contains the actual
            %   data is contained in the plot handle. Details of this
            %   access are encapsulated in the big_plot library.
            %
            %   Inputs
            %   ------
            %   h_plot : line handle return from plotting
            %
            %   Optional Inputs
            %   ---------------
            %   get_x_data : logical (default true)
            %       If true, a vector of x-data points are returned. 
            %   xlim : [min_time max_time] (default [])
            %       If specified only a subset of the data array is
            %       returned. By default all the data are returned.
            %   get_calibrated : logical (default true)
            %       When true the output class contains the calibrated
            %       data, when available (i.e. when the channel has been
            %       calibrated)
            %   get_raw : logical (default false)
            %       When true the raw data are returned.
            %
            %   Outputs
            %   -------
            %   s : big_plot.raw_line_data
            %
            %   Example
            %   -------
            %   Get data from x=10 to x=20
            %   s = interactive_plot.data_interface.getRawLineData(h_plot,'xlim',[10 20])
            %

            s = big_plot.getRawLineData(h_plot,varargin{:});
        end
        function setCalibration(h_plot,calibration)
            big_plot.setCalibration(h_plot,calibration);
        end
        function rerender(line_handles)
            %
            %   This was created for when new data was added but the
            %   lines weren't getting redrawn because we hadn't filled
            %   up enough data to have the render window move.
            big_plot.forceRender(line_handles);
        end
    end
    
end

