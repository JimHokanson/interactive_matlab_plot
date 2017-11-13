classdef interactive_plot < handle
    %
    %   Class:
    %   interactive_plot
    

    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    % at first, split up the lines based on where the limits of the
    % axes are...
    
    %{
            %Old code
    %%             ax1 = subplot(3,1,1);
%             ax2 = subplot(3,1,2);
%             ax3 = subplot(3,1,3);
%             ax4 = subplot(3,1,4);
%             plot(ax1,sin(1:8));
%             plot(ax2,10:-1:1);
%             plot(ax3, cos(1:9));

            %axes_handles = {ax1, ax2, ax3};
            
    
            %Test Code
            %--------------------------
            %
            N_PLOTS = 8;
            f = figure;
            n_points = 1000;
            ax_ca = cell(1,N_PLOTS);
            for i = 1:N_PLOTS
                ax_ca{i} = subplot(N_PLOTS,1,i);
                y = linspace(0,i,n_points);
                plot(round(y))
            end

            obj = interactive_plot(f,ax_ca)
    %}
    
    properties
        fig_handle
        axes_handles
        mouse_manager
        line_moving_processor
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
        function obj = interactive_plot(fig_handle, axes)
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
            set(fig_handle, 'Units', 'normalized'); %reset units back to normal
            
            obj.line_moving_processor = interactive_plot.line_moving_processor(obj);
            obj.mouse_manager = interactive_plot.mouse_motion_callback_manager(obj);
            obj.scroll_bar = interactive_plot.scroll_bar(obj);
        end
    end
end


function moveLine(h,f, obj)
    %
    %   Main Callback:
    %   1) - move the selected line
    %   2) - update other lines if being pushed ...
    
    %JAH: This is supposed to be a tight loop, remove unecessary logic
    
    
    temp = get(f, 'CurrentPoint');
    cur_position = temp(2);
    
    %JAH: We should know the line positions, no querying in the loop
    %- Just keep a variable of line positions, specifically the y-values.
    %- Grab line positions on mouse-click - figure shouldn't resize within
    %   that time frame
    
    obj.trackLinePositions();
    
    
    %JAH: Make this part of the callback
    %i.e. add id on as an input
    %
    % figure out which line we are moving
    for k = 1: length(obj.lines)
       if h == obj.lines{k}
           id = k;
           break;
       end
    end
      
    
    %State Data
    %------------------------
    %- physical line widths (relative to figure positions)
    %    - i.e. how may pixels does a line occupy
    %- current line selected
    %- last position of line
    %    - initializes to position of click
    %- lines engaged in moving clump - if any
    %    - line joins clump when extent of clump exceeeds extent of line
    %    - line leaves clump on downward movement
    %- vertical width # of lines engaged in clump
    %- vertical extent of clump
    %- position of clump relative to line (above or below)
    %
    %Inner line algorithm
    %----------------------
    %1) Log initial y_positions
    %2) Log initial y_position of selected line
    %3) On Move
    %   - determine direction, up or down
    %   - split lines into towards group (pushing) and away (pulling)
    %   - If opposite of previous movement, disengage clump (pulled away)
    %   - for the pushing group, check next line not engaged in clump and
    %   engage if necessary. Keep engaging more lines into clump up to max.
    %   
    %
    %
    %Terms/Concepts to introduce into code:
    %---------------------------------------
    %pushing/pulling
    %up/down 
    %lower and upper extents of each line
    %
    %In usage:
    %- I'm pushing line 3 up. Which lines that are above line 3 have a 
    %  lower extent that is below the upper extent of line 3. If any, add
    %  to clump and find any lines that below that lines upper extent.
    
    
    
%   lines_above = obj.lines(1:(id-1));
%   lines_below = obj.lines(1:(id+1));
    
    %JAH: These are y_positions, not to be confused with the well used
    %'position' term in Matlab which is a 4-element vector
    %- rename variable, variable naming is a critical part of code design
    positions_above = obj.positions(1:(id-1));
    positions_below = obj.positions((id+1):end);
    
    above_mask = cur_position > positions_above;
    lines_above_to_move = obj.lines(above_mask);
    
    below_mask = cur_position < positions_below;
    lines_below_to_move = obj.lines(below_mask);
    % these masks specify the lines which now need to move as well
    
    
    %JAH: Start simple, let's not extend bounds
    % if we are outside of these bounds, have to start pushing the other
    % lines.... and then if those lines get outside of boundaries, have to
    % start pushing the other lines as well.... this is going to get really
    % complicated.....   
    
    
    %JAH: One of these loops is empty. Rewrite the code to make this more
    %explicit.
    for m = 1:length(lines_above_to_move)
       L = lines_above_to_move{m};
       
       %Don't collapse all of the lines, offset them appropriately
       L.Position(2) = cur_position; 
    end
    
    for n = 1:length(lines_below_to_move)
       L = lines_below_to_move{n};
       L.Position(2) = cur_position; 
    end
    h.Position(2) = cur_position;
    
    
    
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

