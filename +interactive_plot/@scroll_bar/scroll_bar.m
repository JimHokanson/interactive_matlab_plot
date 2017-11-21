classdef scroll_bar <handle
    %   interactive_plot.scroll_bar
    %
    %   creates a scroll bar on a figure with the interactive plot
    %
    %
    %
    %   improvements:
    %   -------------
    %   -Do we need a variable to keep track of the position of the right
    %   side when the position is always specified by the left edge? And
    %   the width?
    %
    %   get rid of the action listener on close so no warning gets thrown
    
    properties
        parent
        fig_handle %interactive_plot class
        
        left_button
        right_button
        background_bar
        slider
        
        base_y = 0.01;
        left_limit % the edges of the background bar
        right_limit
        bar_height = 0.04;
        width
        
        total_time_range
        time_range_in_view
        
        slider_left_x
        slider_right_x
        
        prev_mouse_x
        
        width_per_time
        
    end
    
    methods
        function obj = scroll_bar(parent)
            
            %JAH: Design decision
            %- should the limits be determined based on the axes or the
            %underlying data, we could default to one and provide an option
            %for the other
            
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            
            %JAH: This is a big change to make this deep in the code
            %  - In general we'll assume this is true at the most top level
            %   thus this code is redundant at best
            %   - this should be removed
            %   - I've started a section on code assumptions in the parent
            %   at the top of the class
            set(obj.fig_handle, 'Units', 'normalized');
            
            
            %JAH: In general try and split secontions with comments 
            %   - this provides much easier visualization of what is going
            %   on where
            % - I've added them ...
            
            %Create scrollbar
            %----------------------------------------
            %- limits
            axes_handles = obj.parent.axes_handles;
            temp1 = axes_handles{1};
            p = temp1.Position;
            obj.left_limit = p(1);
            obj.right_limit = p(1) + p(3);
            
            %Background - doesn't move
            width = obj.right_limit - obj.left_limit;
            obj.background_bar = annotation(...
                'rectangle', [obj.left_limit, obj.base_y, width, obj.bar_height], ...
                'FaceColor', 'w');
            
            %Buttons
            %-----------------------------------------
            L = obj.bar_height;
            x1 = obj.left_limit - L;
            x2 = obj.right_limit;
            y = obj.base_y;
            
            obj.left_button = annotation('textbox',...
                [x1, y, L, L], 'String','<', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');%,'FaceColor', 'k');
            obj.right_button = annotation('textbox',...
                [x2, y, L, L], 'String','>', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');%, 'FaceColor', 'k');
            
            
            %JAH: Base this on the axes, not on the data
            % -- need to figure this out based on the axes (or all of the
            % axes??)
            %
            %JAH: As part of this code base we will require all axes to be
            %   x-linked, so any axex is fine
            
            %JAH: temp1 is way too far away for a name like this ...
            %- temp should only last for a couple lines
            
            %JAH: commented out this code below and rewrote
            
%             data_objs =  get(temp1, 'Children');
%             time_vector = data_objs.XData;
%             obj.total_time_range = max(time_vector) - min(time_vector);
            
            ax1 = axes_handles{1};
            xlim = get(ax1,'xlim');
            obj.total_time_range = xlim(2) - xlim(1);
            
            
            %create the slider
            %---------------------------------------
            obj.slider = annotation(...
                'rectangle', [obj.left_limit, obj.base_y, width, obj.bar_height], ...
                'FaceColor', 'k');
            obj.slider_left_x = obj.left_limit;
            obj.slider_right_x = obj.right_limit;
            
            
            ax = obj.parent.axes_handles{1};
            
            %JAH: I like to have the callbacks named a bit more accurately
            %xLimChanged???
            addlistener(ax, 'XLim', 'PostSet', @(~,~) obj.checkTimeRange);
            
            %  Add callback for on click on rectangle to engage mouse movement
            set(obj.slider, 'ButtonDownFcn', @(~,~) obj.parent.mouse_manager.initializeScrolling);
        end
        function checkTimeRange(obj)
            
            %JAH: Ideally add a comment at the top to specify what this 
            %function is doing
            
            %JAH: Added try/catch due to error puking on closing figure
            
            try
                % checks the limits of the axis of the first plot and sets the
                % scroll bar based on the limits relative to the total time
                % range in the data
                
                %JAH: This is constant, why calculate it multiple times in
                %a callback????
                %
                %convert from units of space to proportion of time
                obj.width_per_time = (obj.right_limit - obj.left_limit)/obj.total_time_range;
                
                % just check axes 1 for proof of concept...
                ax = obj.parent.axes_handles{1};
                x_min = ax.XLim(1);
                x_max = ax.XLim(2);
                
                obj.slider_left_x = obj.left_limit + x_min*obj.width_per_time;
                obj.slider_right_x = obj.left_limit + x_max*obj.width_per_time;
                obj.width = obj.slider_right_x - obj.slider_left_x;
                obj.time_range_in_view = ax.XLim;
                
                % put the
                set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.width, obj.bar_height]);
            catch ME
                %JAH: This is temporary until Greg fixes this code
                %   - most likely we need to verify handles are valid or
                %   destory the listener earlier than we currently are
                %   
                fprintf(2,'Caught error on on time range change\n')
            end
        end
        function scroll(obj)
            %
            %   Callback for scrolling ...
            %
            %   JAH: This scroll implementation currently doesn't change
            %   the axes limits as dragged. I had thought it would. Current
            %   behavior is to just change on mouse up.
            %
            %   - This should be exposed in an options class with the
            %   default behavior being to enable movement of the axes with
            %   the scroll bar.
            
            %obj.prev_mouse_x has been set when the mouse is first clicked.
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            
            dif = cur_mouse_x - obj.prev_mouse_x;
            new_right_limit = obj.slider_right_x  + dif;
            new_left_limit = obj.slider_left_x + dif;
            
            if new_right_limit >= obj.right_limit
                % have to base position on this edge
                obj.slider_left_x = obj.right_limit - obj.width;
                obj.slider_right_x = obj.right_limit;
            elseif new_left_limit <= obj.left_limit
                obj.slider_left_x = obj.left_limit;
                obj.slider_right_x = obj.slider_left_x + obj.width;
            else % not at a boundary
                obj.slider_left_x = new_left_limit;
                obj.slider_right_x = new_right_limit;
            end
            set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.width, obj.bar_height]);
            obj.prev_mouse_x = cur_mouse_x;
        end
        function updateAxes(obj)
            % convert the left position to a time
            left_time = (obj.slider_left_x - obj.left_limit)/obj.width_per_time;
            right_time = (obj.slider_right_x - obj.left_limit)/obj.width_per_time;
            
            axes_handles = obj.parent.axes_handles;
            ax = axes_handles{1};
            ax.XLim = [left_time, right_time];
        end
    end
end