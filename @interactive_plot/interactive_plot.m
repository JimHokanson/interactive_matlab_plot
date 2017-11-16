classdef interactive_plot < handle
    %
    %   Class:
    %   interactive_plot
    %
    %   Test Code:
    %   interactive_plot.runTest()
    
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    
    properties
        fig_handle
        axes_handles
        mouse_manager
        line_moving_processor
        axis_resizer
        scroll_bar
        
        %Added graphical components
        %--------------------------
        %JAH: Eventually we will want to port this to being local
        %- All modules should be able to stand on their own for
        %distribution
        %- move to interactive_plot.sl.plot.subplotter or copy
        %small portion of that code into here locally ...
        sp %sl.plot.subplotter
        
        %JAH: I like to initialize semi-constants in the property
        %definition
        
        THICKNESS = 0.002
    end
    methods (Static)
        function obj = runTest()
            %
            %   interactive_plot.runTest()
            
            N_PLOTS = 8;
            f = figure;
            n_points = 1000;
            ax_ca = cell(1,N_PLOTS);
            for i = 1:N_PLOTS
                ax_ca{i} = subplot(N_PLOTS,1,i);
                y = linspace(0,i,n_points);
                plot(round(y))
            end
            
            obj = interactive_plot(f,ax_ca);
        end
    end
    methods
        function obj = interactive_plot(fig_handle, axes, varargin)
            %
            %   obj = interactive_plot(fig_handle, axes, varargin)
            %
            %   Inputs:
            %   ----------
            %   -fig_handle: handle to the figure
            %   -axes: cell array of the handles to all of the axes
            %   on the plot
            %
            %   Improvements
            %   -------------
            %   1) Support multiple columns
            %   2) Vertical and hortizontal scaling
            %   3) Adjust yticks to not be on the line ...
            %   4) Manual yticks with support for changing via buttons &
            %   mouse
            
            in.scroll = true;
            in.lines = true;
            in = sl.in.processVarargin(in,varargin);
            
            %JAH: Had remote desktop active
            %TODO: Verify proper renderer
            %Video card info incorrect
            %- opengl info
            
            obj.fig_handle = fig_handle;
            obj.axes_handles = axes;
            
            shape = size(obj.fig_handle.Children);
            obj.sp = sl.plot.subplotter.fromFigure(obj.fig_handle, shape);
            
            obj.sp.linkXAxes();
            
            rows = 1:shape(1);
            cols = 1:shape(2);
            
            % need a gap size between the axes of a few pixels.
            % removeVerticalGap works in normalized units. need to find a
            % conversion factor.
            
            
            % figure out how to ste the gap size in normalized units when
            % given a desired gap size in pixels
            set(obj.fig_handle, 'Units','normalized');
            
            obj.sp.removeVerticalGap(rows, cols, 'gap_size',obj.THICKNESS);
            
            %JAH: This might not be normal ... Ideally we would record
            %previous state and return to previous state.
            %reset units back to normal
            %
            %- Note, we may not be able to do non-normalized units
            %- this may be a limitation of the software
            set(fig_handle, 'Units', 'normalized'); 
            
            obj.mouse_manager = interactive_plot.mouse_motion_callback_manager(obj);
            obj.line_moving_processor = interactive_plot.line_moving_processor(obj);
            obj.scroll_bar = interactive_plot.scroll_bar(obj);
            obj.axis_resizer = interactive_plot.axis_resizer(obj);
        end
    end
end

%{
         UIContextMenu: [0×0 GraphicsPlaceholder]
         ButtonDownFcn: ''
            BusyAction: 'queue'
          BeingDeleted: 'off'
         Interruptible: 'on'
             CreateFcn: ''
             DeleteFcn: @imlineAPI/deleteContextMenu
                  Type: 'hggroup'
                   Tag: 'imline'
              UserData: []
              Selected: 'off'
    SelectionHighlight: 'on'
               HitTest: 'on'
         PickableParts: 'visible'
           DisplayName: ''
            Annotation: [1×1 matlab.graphics.eventdata.Annotation]
              Children: [4×1 Line]
                Parent: [1×1 Axes]
               Visible: 'on'
      HandleVisibility: 'on'

%}

