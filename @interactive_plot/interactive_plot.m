classdef interactive_plot < handle
    %
    %   Class:
    %   interactive_plot
    
    %{
    Design:
    - each plot gets 2 lines to move, except for the top and bottom
    - moving the lines moves placeholders (need to render lines on the figs
    at their locations)
    - releasing the line stops the movement and changes the axes
    - lines push, but don't pull
    
    Steps
    -----------------------------
    
    
    Line Behavior
    -----------------------------
    1) Axis resize:
 

    TODO:
    1)
    
    %}
    
    %{
    ax1 = subplot(2,1,1);
    plot(1:100,1:100);
    ax2 = subplot(2,1,2);
    plot(1:100,100:-1:1);
    
    %Yikes, this caused a resize of the axes :/
    h = imline(ax2,[-10 110], [95 95]);
    setColor(h,[0 0 0]);
    set(ax2,'xlim',[0 100]);
    
    
    'PositionConstraintFcn'
    
    
    
    %The line can't be grabbed at the very top :/
    %}
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    % at first, split up the lines based on where the limits of the
    % axes are...
    %{
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
        
        lines
        positions
        
        sp
        
        TOP_BOUNDARY  
        BOTTOM_BOUNDARY
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
            %   first round implementation only allows for 1 column of
            %   plots....... TODO: allow for multiple columns of plots
            %
            %   future implementation: allow for both vertical and
            %   horizontal scaling this way.
            
            %   implementation:
            obj.TOP_BOUNDARY = 0.9;
            obj.BOTTOM_BOUNDARY = 0.1;
            
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
            
            % IMPORTANT: assume that we have the figures given in order
            % from top of the figure down. need to find a way to ensure
            % that this is happening in the future!
            
            % find the positions of all of the lines
            % start at the top of the figure
            
            % the first line is just the top position of the first plot
            obj.lines = cell(1,n_axes+1);

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
            
            for k = 1:(n_lines)
                 set(obj.lines{k}, 'ButtonDownFcn', @(~,~) lineClicked(obj.lines{k},obj.fig_handle, obj));
            end
            set(obj.fig_handle,'WindowButtonUpFcn', @(~,~) mouseReleased(obj, obj.fig_handle));
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
            n_lines = length(obj.lines);
            
            obj.positions = zeros(1,n_lines);
            for k = 1:n_lines
                L = obj.lines{k};
                obj.positions(k) = L.Position(2);
            end
        end
    end
end

function h = createLine(hieght)
h = annotation('line',[0 1],[hieght, hieght],'Linewidth',2);
end
function lineClicked(h,f,obj)
set(f,'WindowButtonMotionFcn',@(~,~) moveLine(h,f,obj));
end
function moveLine(h,f, obj)
    temp = get(f, 'CurrentPoint');
    cur_position = temp(2);
    obj.trackLinePositions();
    % figure out which line we are moving
    for k = 1: length(obj.lines)
       if h == obj.lines{k}
           id = k;
           break;
       end
    end
      
    
%   lines_above = obj.lines(1:(id-1));
%   lines_below = obj.lines(1:(id+1));
    
    positions_above = obj.positions(1:(id-1));
    positions_below = obj.positions((id+1):end);
    
    above_mask = cur_position > positions_above;
    lines_above_to_move = obj.lines(above_mask);
    
    below_mask = cur_position < positions_below;
    lines_below_to_move = obj.lines(below_mask);
    % these masks specify the lines which now need to move as well
    
    
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
function mouseReleased(obj, f)
set(f,'WindowButtonMotionFcn','');
obj.resizePlots();
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

