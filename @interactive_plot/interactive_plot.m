classdef interactive_plot < handle
    %
    %   Class:
    %   interactive_plot
    %
    %   Test Code:
    %   interactive_plot.runTest()
    %
    %   Changes/assumptions
    %   -------------------
    %   1) Figure units changed to normalized
    %
    %   See Also
    %   --------
    %   interactive_plot.interactive_plot
    
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    
    properties
        fig_handle
      
        session 	%   interactive_plot.session
        %   interactive_plot.settings
        %   interactive_plot.axes.axes_props
        
        shared_props
        
        axes_panel
        bottom_panel
        left_panel
        right_panel
        top_panel
        menu
     
        fig_size_change  %interactive_plot.fig_size_change
        streaming   %interactive_plot.streaming
        eventz
    end
    methods (Static)
        function obj = runTest(type,varargin)
            %
            %   interactive_plot.runTest(*type)
            %
            %   Optional Inputs
            %   ---------------
            %   type : 
            %       - 1 - 8 simple plots
            %       - 2 - 3 longer more interesting plots with names
            %       - 3 - streaming
            
            %{
                interactive_plot.runTest(2)
            %}
            
            if nargin == 0
                type = 1;
            end

            if type == 1
                obj = interactive_plot.examples.standard1(varargin{:});
            elseif type == 2
                obj = interactive_plot.examples.standard2(varargin{:});
            elseif type == 3
                obj = interactive_plot.examples.streaming_example(varargin{:});
            end
        end
    end
    
    %Constructor    =======================================================
    methods
        function obj = interactive_plot(fig_handle, axes_handles, varargin)
            %
            %   obj = interactive_plot(fig_handle, axes_handles, varargin)
            %
            %   Inputs
            %   ------
            %   fig_handle : handle
            %       Handle to the figure.
            %   axes_handles : cell array {n_rows x n_cols}
            %       Cell array of the handles to all of the axes on the 
            %       plot. Currently the shape of the axes cell matters.
            %
            %   
            %   Optional Inputs
            %   ---------------
            %   **** See interactive_plot.options for all options. ****
            %
            
            %JAH: Had remote desktop active
            %TODO: Verify proper renderer
            %Video card info incorrect
            %- opengl info
            
            in = interactive_plot.options();
            
            shared = interactive_plot.shared_props;
            shared.options = interactive_plot.sl.in.processVarargin(in,varargin);
            
            obj.shared_props = shared;
            

            %Moved into a function to remove size from this file
            obj.initialize(shared,fig_handle,axes_handles);

        end
    end
    
    %======================================================================
    %                       Public Methods
    %======================================================================
    methods
        function save(obj,varargin)
            %
            %   save(obj,varargin)       
            %
            %   Optional Inputs
            %   ---------------
            %   save_path : (default, in this repo)
            %   save_data : (default false) NYI
            %       The idea here is that that we would only save the
            %       session data but not the plotted data.
            
            in.save_path = [];
            in.save_data = false;
            in = interactive_plot.sl.in.processVarargin(in,varargin);
            
            if isempty(in.save_path)
               root_path = interactive_plot.sl.stack.getPackageRoot(); 
               root_path = fullfile(root_path,'data');
               if ~exist(root_path,'dir')
                   mkdir(root_path)
               end
               date_string = datestr(now,'yymmdd__HH_MM_SS');
               file_name = sprintf('%s_ip_data.mat',date_string);
               in.save_path = fullfile(root_path,file_name);
            end
            
            s = getSessionData(obj); %#ok<NASGU>
            save(in.save_path,'-struct','s');
        end
        function s = getSessionData(obj)
            %
            %   s = getSessionData(obj)
            %
            %   Session data are returned as a structure (struct) for saving.
            %
            
            %obj.session : interactive_plot.session
            s = obj.session.struct();
        end
        function s = getCalibrationsSummary(obj)
            %
            %   s = getCalibrationsSummary(obj)
            
            s = obj.session.settings.axes_props.getCalibrationsSummary();
        end
        function addComments(obj,comment_times,comment_strings)
            %
            %   addComments(obj,comment_times,comment_strings)
            %
            %   See Also
            %   --------
            %   interactive_plot.session 
            %   interactive_plot.comment
            obj.session.addComments(comment_times,comment_strings);
        end
        function addComment(obj,comment_time,comment_string)
            %
            %   addComment(obj,comment_time,comment_string)
            %   
            %   See Also
            %   --------
            %   interactive_plot.session 
            %   interactive_plot.comments
            
            obj.session.addComment(comment_time,comment_string);
        end
        function dataAdded(obj,new_max_time,new_data_means)
            %
            %   dataAdded(obj,new_max_time,*new_data_means)
            %
            %   Indicate to the plot that new data has been added. 
            %
            %   Code Usage
            %   -----------
            %   The current usage is to first add data to streaming data
            %   types (see big_plot.streaming_data). When ready call this
            %   function with the new max time to plot.
            %
            %   Inputs
            %   ------
            %   new_max_time : 
            %       The maximum time of the data plotted
            %   
            %   Optional Inputs
            %   ---------------
            %   new_data_means :
            %       If specified the right display entries for each axis
            %       are updated with these new mean values.
            %
            %   Examples
            %   ---------
            %   %Standard usage
            %   iplot.dataAdded(20);
            %
            %   %Update means for 4 channels as well
            %   iplot.dataAdded(30,[5 0 -3 2.567]);
            
            %Notify the code that new data has been added ...
            if isvalid(obj.fig_handle)
                %obj.streaming : interactive_plot.streaming
                obj.streaming.changeMaxTime(new_max_time);
            end
            
            if nargin == 3
                if obj.session.settings.auto_scroll_enabled
                    rp = obj.right_panel;
                    for i = 1:length(new_data_means)
                        str = sprintf('%g',new_data_means(i));
                        rp.setDisplayString(str,i);
                    end 
                end
            end
        end
        function loadCalibrations(obj,file_paths,varargin)
            %
            %   loadCalibrations(obj,file_paths,varargin)
            %
            %   Input
            %   -----
            %   file_paths : string or cellstr
            %       The path or paths of calibration files to load.
            %       Calibrations are currently saved individually so to
            %       calibrate multiple channels multiple file paths must be
            %       specified.
            %
            
            %interactive_plot.axes.axes_props
            axes_props = obj.session.settings.axes_props;
            
            %interactive_plot.axes.axes_props.loadCalibrations
            axes_props.loadCalibrations(file_paths,varargin);
        end
        function h_fig = getFigureHandle(obj)
            h_fig = obj.fig_handle;
        end
    end
    methods (Hidden) 
        %TODO: Save on figure close???? - auto_save
        function cb_close(obj)
            
            %In case we can't close due to invalid function
            %set(gcf,'CloseRequestFcn',@(x,y)delete(gcf))
            
            delete(obj.fig_handle);
            delete(obj)
        end
    end
end
