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
            %Test Code
            %--------------------------
            f = figure;
            ax1 = subplot(3,1,1);
            ax2 = subplot(3,1,2);
            ax3 = subplot(3,1,3);
            plot(ax1,sin(1:8));
            plot(ax2,10:-1:1);
            plot(ax3, cos(1:9));
            
            axes_handles = {ax1, ax2, ax3};
            
            obj = interactive_plot(f,axes_handles)
    %}
    
    properties
        fig_handle
        axes
        
        line_moving_processor
        
        %Added graphical components
        %--------------------------
        lines 
        positions
        
        %JAH: Eventually we will want to port this to being local
        %- All modules should be able to stand on their own for
        %distribution
        %- move to interactive_plot.sl.plot.subplotter or copy
        %small portion of that code into here locally ...
        sp %sl.plot.subplotter
        
        %JAH: I like to initialize semi-constants in the property
        %definition
        TOP_BOUNDARY = 0.9
        BOTTOM_BOUNDARY = 0.1
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
            obj.axes = axes;
            
            shape = size(obj.fig_handle.Children);
            obj.sp = sl.plot.subplotter.fromFigure(obj.fig_handle, shape);
           
            obj.sp.linkXAxes();

            rows = 1:shape(1);
            cols = 1:shape(2);
            obj.sp.removeVerticalGap(rows, cols, 'gap_size',0);
            
            n_axes = length(obj.axes);
            n_lines = n_axes + 1;
            
            set(fig_handle, 'Units', 'normalized');
            
            % get all of the y limits
            y_low = zeros(n_axes,1);
            y_high = zeros(n_axes,1);
            
            for k = 1:n_axes
                cur_ax = obj.axes{k};
                cur_pos = cur_ax.Position;
                %position is [x,y, width, length]
                y_low(k) = cur_pos(2);
                y_high(k) = y_low(k) + cur_pos(4);
            end
            
            %--------------------------------------------------------------
            %JAH: Move all of this into the line processor
            %--------------------------------------------------------------
            
            % IMPORTANT: assume that we have the figures given in order
            % from top of the figure down. need to find a way to ensure
            % that this is happening in the future!
            
            % find the positions of all of the lines
            % start at the top of the figure
            
            % the first line is just the top position of the first plot
            obj.lines = cell(1,n_axes+1);

            %JAH: For local functions that are one liners it is better to create
            %an anonymous function
            %   - I made this function from the function that was below
            %
            %JAH: What are the units on Linewidth? Is this pixels?
            %   - we need to understand this to create dragging
            createLine = @(height) annotation('line',[0 1],[height, height],'Linewidth',3);
            
             obj.lines{1} = createLine(y_high(1));
            % the middle lines are harder to figure out...
            for k = 1:n_axes-1
                % these two values should be the same, but this will allow
                % for support of the case where they aren't... I think...
                % this may not be the best way to do this...
               temp = (y_low(k) + y_high(k+1))/2;
               obj.lines{k+1} =  createLine(temp); 
            end
            
            % the last line is just the low position of the last plot
            obj.lines{end} = createLine(y_low(end));
            
            %JAH: TODO: Pass in relevant info
            %- setup appropriate callbacks in the processor
            %
            %
            %obj.line_moving_processor = interactive_plot.line_moving_processor();
            
            for k = 1:(n_lines)
                %JAH: I prefer to use h__ to identify local functions
                %Pass in the line_id to the callback
                 set(obj.lines{k}, 'ButtonDownFcn', @(~,~) h__lineClicked(obj.lines{k},obj.fig_handle, obj));
            end
            set(obj.fig_handle,'WindowButtonUpFcn', @(~,~) h__mouseReleased(obj, obj.fig_handle));
        end
        function resizePlots(obj)
            % get the positions of all of the lines
 
            % TODO: don't adjust for the plots whose lines have not changed
            %           will this cause a big speed error when plotting
            %           lots of data?
            obj.trackLinePositions();
            
            for k = 1:length(obj.axes)
               top = obj.positions(k);
               bottom = obj.positions(k+1);
               height = top - bottom;

               ax = obj.axes{k};
               x = ax.Position(1);
               %y = ax.Position(2);
               w = ax.Position(3);
               %h = ax.Position(4);
                set(ax, 'Position', [x, bottom, w, height]);
            end
        end
        function trackLinePositions(obj)
            %
            n_lines = length(obj.lines);
            
            obj.positions = zeros(1,n_lines);
            for k = 1:n_lines
                L = obj.lines{k};
                obj.positions(k) = L.Position(2);
            end
        end
    end
end

% function h = createLine(hieght)
% h = annotation('line',[0 1],[hieght, hieght],'Linewidth',2);
% end
function h__lineClicked(h,f,obj)
    %JAH: Instantiate line_moving_processor and do the logic in there
    %   - The interactive plot should handle interactive plotting, not just
    %moving lines!
    %
    %JAH: We might want other mouse movement functionality - i.e. figure
    %resizing. Make calls to something that manages these states.
    set(f,'WindowButtonMotionFcn',@(~,~) moveLine(h,f,obj));
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
    for m = 1:length(lines_above_to_move)
       L = lines_above_to_move{m};
       L.Position(2) = cur_position; 
    end
    
    for n = 1:length(lines_below_to_move)
       L = lines_below_to_move{n};
       L.Position(2) = cur_position; 
    end
    h.Position(2) = cur_position;
    
    
    
end
function h__mouseReleased(obj, f)
set(f,'WindowButtonMotionFcn','');
obj.resizePlots();
end




%{
         UIContextMenu: [0�0 GraphicsPlaceholder]
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
            Annotation: [1�1 matlab.graphics.eventdata.Annotation]
              Children: [4�1 Line]
                Parent: [1�1 Axes]
               Visible: 'on'
      HandleVisibility: 'on'

%}

