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
    
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    
    properties
        fig_handle
      
        session
        shared_props
        
        axes_panel
        bottom_panel
        left_panel
        right_panel
        top_panel
        menu
     
        fig_size_change  %interactive_plot.fig_size_change
        streaming
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
            %   See interactive_plot.options for all options.
            %
            %   update_on_drag : default true
            %       If true plots will be updated as scrolling happens.
            %   scroll : default true
            %       If true a scroll bar is included on the plot.
            %   lines : default true
            %       If true draggable lines are included
            %
            %
            %   Improvements
            %   ------------
            %   1) Support multiple columns
            %   2) Vertical and hortizontal scaling
            %   3) Adjust yticks to not be on the line ...
            %   4) Manual yticks with support for changing via buttons &
            %   mouse
            
            %JAH: Had remote desktop active
            %TODO: Verify proper renderer
            %Video card info incorrect
            %- opengl info
            
            
            in = interactive_plot.options();
            
            shared = interactive_plot.shared_props;
            shared.options = interactive_plot.sl.in.processVarargin(in,varargin);
            
            obj.shared_props = shared;
            
            shared.render_params = interactive_plot.render_params;
            shared.fig_handle = fig_handle;
            obj.fig_handle = fig_handle;
            
            %Current limitation of the software
            set(fig_handle,'Units','normalized');
            set(fig_handle,'CloseRequestFcn', @(~,~) obj.cb_close);
            
            %TODO: Verify correct setup of the axes handles since these 
            %come from the user, not internally ...
            shared.axes_handles = axes_handles;
            shared.handles = interactive_plot.handles(fig_handle,axes_handles);
            
            all_axes = [axes_handles{:}];
            linkaxes(all_axes,'x');
            
            %Non-rendered components
            %--------------------------------------------------------------
            shared.mouse_manager = interactive_plot.mouse_manager(shared.handles);
            shared.eventz = interactive_plot.eventz(@notify);
            shared.session = interactive_plot.session(shared);
            obj.session = shared.session;
            obj.eventz = shared.eventz;
            
            %Top Components
            %--------------------------------------------------------------
            shared.toolbar = interactive_plot.toolbar(shared);
            
            obj.top_panel = interactive_plot.top.top_panel(shared);
            %refresh(fig_handle)
            %These make the whole process feel much more snappy
            drawnow('nocallbacks')
            
            %Center
            obj.axes_panel = interactive_plot.axes.axes_panel(...
                shared,obj.top_panel.top_for_axes);
            %refresh(fig_handle)
            drawnow('nocallbacks')
            
            %Left
            obj.left_panel = interactive_plot.left.left_panel(shared);
            %refresh(fig_handle)
            drawnow('nocallbacks')
            
        	%Right
         	obj.right_panel = interactive_plot.right.right_panel(shared);
            %refresh(fig_handle)
            drawnow('nocallbacks')
            
            %We do this later so that the lines draw over the text objects
            %...
            obj.axes_panel.createLines();
            %refresh(fig_handle)
            drawnow('nocallbacks')
            
            %Bottom
            obj.bottom_panel = interactive_plot.bottom.bottom_panel(...
                shared);
            %refresh(fig_handle)
            drawnow('nocallbacks')
            
            obj.streaming = interactive_plot.streaming(...
                shared,obj.bottom_panel);

            obj.menu = interactive_plot.fig_menu(shared);
            
            
            %Some final parts ...
            %------------------------
            obj.fig_size_change = interactive_plot.fig_size_change(obj);
            fsc = obj.fig_size_change;
            fsc.linkObjects(obj.left_panel,obj.right_panel);
            
            shared.toolbar.linkComponents(...
                obj.axes_panel.axes_action_manager,...
                obj.left_panel)
            shared.mouse_manager.linkObjects(...
                obj.axes_panel.axes_action_manager,...
                obj.left_panel.y_axis_resizer);
            obj.top_panel.linkObjects(...
                obj.axes_panel.axes_action_manager);
            obj.left_panel.y_axis_options.linkObjects(...
                obj.axes_panel.axes_action_manager);
            shared.mouse_manager.updateAxesLimits();
            
            %Link right hand text display to the axes manager
            
            y_disp = obj.right_panel.y_display_handles;
            x_disp = obj.bottom_panel.x_disp_handle;
            obj.axes_panel.axes_action_manager.linkObjects(y_disp,x_disp);
        end
    end
    
    methods
        function save(obj,varargin)
            %
            %   save(obj,varargin)       
            %
            %   Optional Inputs
            %   ---------------
            %   save_path : (default, in this repo)
            %   save_data : (default false) NYI
            
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
            
            s = getSessionData(obj);
            save(in.save_path,'-struct','s');
        end
        function s = getSessionData(obj)
            %
            %   s = 
            %
            %   
            s = struct(obj.session);
        end
        function addComment(obj,comment_time,comment_string)
            %NYI
            % - requires comments being active ...
            obj.session.addComment(comment_time,comment_string);
        end
        function dataAdded(obj,new_max_time)
            %Notify the code that new data has been added ...
            if isvalid(obj.fig_handle)
                obj.streaming.changeMaxTime(new_max_time);
            end
        end
    end
    methods (Hidden) 
        %TODO: Save on figure close???? - auto_save
        function cb_close(obj)
            delete(obj.fig_handle);
        end
    end
end
