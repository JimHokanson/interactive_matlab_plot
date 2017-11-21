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
        axes_handles
        mouse_manager
        line_moving_processor
        axis_resizer
        scroll_bar
        fig_size_change
        
        %Added graphical components
        %--------------------------
        %JAH: Eventually we will want to port this to being local
        %- All modules should be able to stand on their own for
        %distribution
        %- move to interactive_plot.sl.plot.subplotter or copy
        %small portion of that code into here locally ...
        sp %sl.plot.subplotter
        
        line_thickness = 0.003
        gap_thickness = 0.002
    end
    methods (Static)
        function obj = runTest(type)
            %
            %   interactive_plot.runTest(*type)
            
            %{
                interactive_plot.runTest(2)
            %}
            
            if nargin == 0
                type = 1;
            end
            
            f = figure;
            
            if type == 1
                N_PLOTS = 8;
                
                n_points = 1000;
                ax_ca = cell(1,N_PLOTS);
                for i = 1:N_PLOTS
                    ax_ca{i} = subplot(N_PLOTS,1,i);
                    y = linspace(0,i,n_points);
                    plot(round(y))
                    set(gca,'ylim',[-4 4]);
                end
            else
                n = 50000;
               	t = linspace(0,100,n);
                y = [(sin(0.10 * t) + 0.05 * randn(1, n))', ...
                    (cos(0.43 * t) + 0.001 * t .* randn(1, n))', ...
                    round(mod(t/10, 5))'];
                y(t > 40 & t < 50,:) = 0;                      % Drop a section of data.
                y(randi(numel(y), 1, 20)) = randn(1, 20);       % Emulate spikes. 
                ax_ca = cell(1,3);
                for i = 1:3
                    ax_ca{i} = subplot(3,1,i);
                    plot(t,y(:,i));
                end
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
            %   fig_handle : handle to the figure
            %   axes : cell array of the handles to all of the axes
            %       on the plot
            %
            %   Optional Inputs
            %   ---------------
            %   Not yet supported
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
            
            %JAH TODO: Specify top position and bottom position
            obj.sp.removeVerticalGap(rows, cols,...
                'gap_size',obj.line_thickness);
            
            %JAH: This might not be normal ... Ideally we would record
            %previous state and return to previous state.
            %reset units back to normal
            %
            %- Note, we may not be able to do non-normalized units
            %- this may be a limitation of the software
            set(fig_handle, 'Units', 'normalized'); 
            
            obj.line_moving_processor = interactive_plot.line_moving_processor(obj);
            obj.scroll_bar = interactive_plot.scroll_bar(obj);
            obj.axis_resizer = interactive_plot.axis_resizer(obj);
         	obj.mouse_manager = interactive_plot.mouse_motion_callback_manager(obj);
            obj.fig_size_change = interactive_plot.fig_size_change(obj);
        end
    end
end
