classdef scroll_bar <handle
    % 
    %   Class:
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
        zoom_in_button
        zoom_out_button
        background_bar
        slider
        
        base_y
        left_limit % the edges of the background bar
        right_limit
        bar_height
        bar_width
        button_width
        
        total_time_range
        total_time_limits
        time_range_in_view
        
        slider_left_x
        slider_right_x
        
        prev_mouse_x
        
        width_per_time
        
        x_zoom
        auto_scroll
    end
    
    methods
        function obj = scroll_bar(parent)
            
            %JAH: Design decision
            %- should the limits be determined based on the axes or the
            %underlying data, we could default to one and provide an option
            %for the other
            
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            
            % assume that at this point all figure units are normalized
            
            %Create scrollbar
            %----------------------------------------
            %- limits
            options = obj.parent.options;
            obj.left_limit =options.bar_left_limit;
            obj.right_limit = options.bar_right_limit;
            obj.base_y = options.bar_base_y;
            obj.bar_height = options.bar_height;
            obj.button_width = options.button_width;
            
            %Background - doesn't move
            obj.bar_width = obj.right_limit - obj.left_limit;
            obj.background_bar = annotation(...
                'rectangle', [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height], ...
                'FaceColor', 'w');
            
            %Buttons
            %-----------------------------------------
            % TODO: expose all of these in the options class?
            %       or at least move to higher level for sharing?
            H = obj.bar_height;
            L = obj.button_width;
            x1 = obj.left_limit - L; % position of scroll left button
            x2 = obj.right_limit; % position of scroll right button
%             x3 = obj.right_limit + L; % position of x zoom out button
%             x4 = obj.right_limit + 2*L; % position of x zoom in button
            y = obj.base_y; % y position of the bottom of the scroll bar
            %             [x1, y, L, H]
            %NYI
            
            % uicontrol push buttons don't look quite as good in this case,
            % but they have a visible response when clicked and are
            % slightly easier to work with
            obj.left_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '<',...
                'units', 'normalized', 'Position',[x1, y, L, H],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_scrollLeft());
            
            obj.right_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '>',...
                'units', 'normalized', 'Position',[x2, y, L, H],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_scrollRight());
            
            ax1 = obj.parent.axes_handles{1};
            xlim = get(ax1,'xlim');
            obj.total_time_limits = xlim;
            obj.total_time_range = xlim(2) - xlim(1);
            
            
            %create the slider
            %---------------------------------------
            obj.slider = annotation(...
                'rectangle', [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height], ...
                'FaceColor', 'k');
            obj.slider_left_x = obj.left_limit;
            obj.slider_right_x = obj.right_limit;
            
            
            ax = obj.parent.axes_handles{1};
            
            % add an action listener which updates the size of the scroll
            % bar when the zoom is changed
            addlistener(ax, 'XLim', 'PostSet', @(~,~) obj.xLimChanged);
            
            %  Add callback for on click on rectangle to engage mouse movement
            set(obj.slider, 'ButtonDownFcn', @(~,~) obj.parent.mouse_manager.initializeScrolling);
            
            % set up scroll bar based on what the starting zoom is
            % this is testing for the case that the user had already zoomed
            % before feeding the figure to the class.
            obj.xLimChanged();
            
            %JAH: This isn't exactly a scroll bar ....
            %We could group by x-changers or something ...
            obj.x_zoom = interactive_plot.x_zoom(obj);
            obj.auto_scroll = interactive_plot.auto_scroll(obj);
        end
        function xLimChanged(obj)
            %  obj.xLimChanged()
            %
            % Called by action listener on x limits of the first axes.
            % checks the limits of the axis of the first plot and sets the
            % scroll bar based on the limits relative to the total time
            % range in the data
            
            %JAH: Added try/catch due to error puking on closing figure
            try
                %JAH: This is constant, why calculate it multiple times in
                %a callback????
                %
                %convert from units of space to proportion of time
                %
                %GHG: This is temporary to account for possible change in
                %axes size relative to the figure. We will have a listener
                %for that
                %
                %JAH: For normalized isn't this constant???
                %JAH: For streaming this will need to by dynamic ...
                obj.width_per_time = (obj.right_limit - obj.left_limit)/obj.total_time_range;
                
                % just check axes 1 for proof of concept...
                ax = obj.parent.axes_handles{1};
                x_min = ax.XLim(1);
                x_max = ax.XLim(2);
                
                obj.slider_left_x = obj.left_limit + x_min*obj.width_per_time;
                obj.slider_right_x = obj.left_limit + x_max*obj.width_per_time;
                obj.bar_width = obj.slider_right_x - obj.slider_left_x;
                obj.time_range_in_view = ax.XLim;
                
                set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.bar_width, obj.bar_height]);
            catch ME %#ok<NASGU>
                %JAH: This is temporary until Greg fixes this code
                %   - most likely we need to verify handles are valid or
                %   destory the listener earlier than we currently are
                %
                %fprintf(2,'Caught error on on time range change\n')
            end
        end
        function scroll(obj)
            % obj.scroll()
            %
            % Callback function for scrolling
            % Called whenever the mouse is both clicked and moves
            % This function may call updateAxes as scrolling occurs
            % depending on the options specified in the options class held
            % by the parent.
            
            %obj.prev_mouse_x has been set when the mouse is first clicked.
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            
            dif = cur_mouse_x - obj.prev_mouse_x;
            new_right_limit = obj.slider_right_x  + dif;
            new_left_limit = obj.slider_left_x + dif;
            
            if new_right_limit >= obj.right_limit
                % have to base position on this edge
                obj.slider_left_x = obj.right_limit - obj.bar_width;
                obj.slider_right_x = obj.right_limit;
            elseif new_left_limit <= obj.left_limit
                obj.slider_left_x = obj.left_limit;
                obj.slider_right_x = obj.slider_left_x + obj.bar_width;
            else % not at a boundary
                obj.slider_left_x = new_left_limit;
                obj.slider_right_x = new_right_limit;
            end
            set(obj.slider, 'Position', [obj.slider_left_x, obj.base_y, obj.bar_width, obj.bar_height]);
            obj.prev_mouse_x = cur_mouse_x;
            if obj.parent.options.update_on_drag
                obj.updateAxes();
            end
        end
        function updateAxes(obj)
            % convert the left position to a time
            left_time = (obj.slider_left_x - obj.left_limit)/obj.width_per_time;
            right_time = (obj.slider_right_x - obj.left_limit)/obj.width_per_time;
            
            axes_handles = obj.parent.axes_handles;
            ax = axes_handles{1};
            ax.XLim = [left_time, right_time];
            obj.time_range_in_view = ax.XLim;
        end
    end
    methods % callbacks
        function cb_scrollLeft(obj)
            % shift by 5% of the visible time range
            % TODO: expose as option
            % TODO: allow continuous scrolling with this method using
            % timers
            fraction_shift = 0.05;
            range_in_view = obj.time_range_in_view(2) - obj.time_range_in_view(1);
            amt_to_shift = fraction_shift*range_in_view;
            ax = obj.parent.axes_handles{1};
            
            new_xmin = ax.XLim(1) - amt_to_shift;
            if ~(new_xmin < obj.total_time_limits(1))
                ax.XLim = ax.XLim - amt_to_shift;
            else
                ax.XLim(1) = obj.total_time_limits(1);
                ax.XLim(2) = obj.total_time_limits(1) + range_in_view;
            end
        end
        function cb_scrollRight(obj)
            % see comments on cb_scrollRight
            fraction_shift = 0.05;
            range_in_view = obj.time_range_in_view(2) - obj.time_range_in_view(1);
            amt_to_shift = fraction_shift*range_in_view;
            ax = obj.parent.axes_handles{1};
            
            new_xmax = ax.XLim(2) + amt_to_shift;
            if ~(new_xmax > obj.total_time_limits(2))
                ax.XLim = ax.XLim + amt_to_shift;
            else
                ax.XLim(2) = obj.total_time_limits(2);
                ax.XLim(1) = obj.total_time_limits(2) - range_in_view;
            end
        end
    end
end