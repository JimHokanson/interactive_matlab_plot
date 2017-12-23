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
        
     
        fig_size_change  %interactive_plot.fig_size_change
        streaming
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
    
    %Constructor
    %===========================================
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
            
            
            %Top Components
            %--------------------------------------------------------------
            shared.toolbar = interactive_plot.toolbar(shared.handles);
            
            obj.top_panel = interactive_plot.top.top_panel(shared);
            
            %Center
            obj.axes_panel = interactive_plot.axes.axes_panel(...
                shared,obj.top_panel.top_for_axes);
            
            %Left
            obj.left_panel = interactive_plot.left.left_panel(shared);
            
        	%Right
         	obj.right_panel = interactive_plot.right.right_panel(shared);

            %We do this later so that the lines draw over the text objects
            %...
            obj.axes_panel.createLines();
            
            %Bottom
            obj.bottom_panel = interactive_plot.bottom.bottom_panel(...
                shared);
            
            obj.streaming = interactive_plot.streaming(...
                shared,obj.bottom_panel);

            %Some final parts ...
            %------------------------
            obj.fig_size_change = interactive_plot.fig_size_change(obj);
            fsc = obj.fig_size_change;
            fsc.right_panel = obj.right_panel;
            
            shared.toolbar.linkComponents(...
                obj.axes_panel.axes_action_manager,...
                obj.left_panel)
            shared.mouse_manager.linkObjects(...
                obj.axes_panel.axes_action_manager,...
                obj.left_panel.y_axis_resizer);
            obj.top_panel.linkObjects(obj.axes_panel.axes_action_manager);
            shared.mouse_manager.updateAxesLimits();
            
            %Link right hand text display to the axes manager
            
            y_disp = obj.right_panel.y_display_handles;
            x_disp = obj.bottom_panel.x_disp_handle;
            obj.axes_panel.axes_action_manager.linkObjects(y_disp,x_disp);
            
           
        end
    end
    
    methods
        function addComment(obj,comment_string,comment_time)
            %NYI
            % - requires comments being active ...
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
