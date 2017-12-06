classdef scroll_bar <handle
    % 
    %   Class:
    %   interactive_plot.scroll_bar
    %
    %   creates a scroll bar on a figure with the interactive plot
    %
    %   All changes are made to the first axes in the figure/list. Because
    %   the axes are linked, this accounts for changes made to all of
    %   them (that this class makes and detects)
    %
    %   improvements:
    %   -------------
    %   -Do we need a variable to keep track of the position of the right
    %   side when the position is always specified by the left edge? And
    %   the width?
    %
    %   get rid of the action listener on close so no warning gets thrown
    
    properties
        fig_handle %interactive_plot class
        axes_handles
        mouse_man
        options
        
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
        ax_listener %listener on the first axes
    end
    
    methods
        function obj = scroll_bar(mouse_man,handles,options,render_params)
            
            
            obj.mouse_man = mouse_man;
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            
            p = get(handles.axes_handles{1},'Position');
                
            bar_left_limit = p(1) + render_params.small_button_width;
            
            %TODO: This could be based on whether or not we do streaming
            %3 - no streaming
            %4 - with streaming
            bar_right_limit = p(1) + p(3) - 4*render_params.small_button_width;
                                    
            obj.options = options;
            
            % assume that at this point all figure units are normalized
            
            %Create scrollbar
            %----------------------------------------
            %- limits
            obj.left_limit = bar_left_limit;
            obj.right_limit = bar_right_limit;
            obj.base_y = render_params.scroll_bar_bottom;
            obj.bar_height = render_params.scroll_bar_height;
            obj.button_width = render_params.small_button_width;
            
            %Background - doesn't move
            obj.bar_width = obj.right_limit - obj.left_limit;
            p1 = [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height];
            obj.background_bar = annotation('rectangle', p1, 'FaceColor', 'w');
            
            %Buttons
            %-----------------------------------------
            bar_height = obj.bar_height;
            button_width = obj.button_width;
            x1 = obj.left_limit - button_width; % position of scroll left button
            x2 = obj.right_limit; % position of scroll right button
            y = obj.base_y; % y position of the bottom of the scroll bar
            
            % uicontrol push buttons don't look quite as good in this case,
            % but they have a visible response when clicked and are
            % slightly easier to work with
            obj.left_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '<',...
                'units', 'normalized', 'Position',[x1, y, button_width, bar_height],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_scrollLeft());
            
            obj.right_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '>',...
                'units', 'normalized', 'Position',[x2, y, button_width, bar_height],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_scrollRight());
            
            ax1 = handles.axes_handles{1};
            xlim = get(ax1,'xlim');
            obj.total_time_limits = xlim;
            obj.total_time_range = xlim(2) - xlim(1);
            
            
            %create the slider
            %---------------------------------------
            p2 = [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height];
            obj.slider = annotation('rectangle', p2, 'FaceColor', 'k');
            obj.slider_left_x = obj.left_limit;
            obj.slider_right_x = obj.right_limit;
            
            
            ax = handles.axes_handles{1};
            
            % add an action listener which updates the size of the scroll
            % bar when the zoom is changed
            obj.ax_listener = addlistener(ax, 'XLim', 'PostSet', @(~,~) obj.xLimChanged);

            %  Add callback for on click on rectangle to engage mouse movement
            set(obj.slider, 'ButtonDownFcn', @(~,~) obj.initializeScrolling);
            
            % set up scroll bar based on what the starting zoom is
            % this is testing for the case that the user had already zoomed
            % before feeding the figure to the class.
            obj.xLimChanged();

            %JAH: This isn't exactly a scroll bar ....
            %We could group by x-changers or something ...
            obj.x_zoom = interactive_plot.x_zoom(obj,handles,render_params,...
                options,obj.slider_right_x,obj.base_y);
            obj.auto_scroll = interactive_plot.auto_scroll(obj);
        end
        function initializeScrolling(obj)
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            obj.prev_mouse_x = cur_mouse_x;
          	obj.mouse_man.setMouseMotionFunction(@scroll_bar.scroll);
            obj.mouse_man.setMouseUpFunction(@obj.releaseScrollBar);
        end
        function releaseScrollBar(obj)
            if ~obj.options.update_on_drag
                obj.updateAxes();
            end
            obj.mouse_man.initDefaultState();
        end
        function updateXMax(obj,new_x_max)
            %TODO: position of the scroll bar needs to rerender ...
            
            %See streaming class
             obj.total_time_limits(2) = new_x_max;
             obj.total_time_range = obj.total_time_limits(2) - obj.total_time_limits(1);
             obj.xLimChanged();
        end
        function xLimChanged(obj)
            %  obj.xLimChanged()
            %
            % Called by action listener on x limits of the first axes.
            % checks the limits of the axis of the first plot and sets the
            % scroll bar based on the limits relative to the total time
            % range in the data
            
            try
                %convert from units of space to proportion of time
                obj.width_per_time = (obj.right_limit - obj.left_limit)/obj.total_time_range;
                
                % just check axes 1 for proof of concept...
                ax = obj.axes_handles{1};
                
                x_min = ax.XLim(1);
                x_max = ax.XLim(2);
                
                obj.slider_left_x = obj.left_limit + x_min*obj.width_per_time;
                obj.slider_right_x = obj.left_limit + x_max*obj.width_per_time;
                obj.bar_width = obj.slider_right_x - obj.slider_left_x;
                obj.time_range_in_view = ax.XLim;
                
                p = [obj.slider_left_x, obj.base_y, obj.bar_width, obj.bar_height];
                set(obj.slider, 'Position', p);
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
            p = [obj.slider_left_x, obj.base_y, obj.bar_width, obj.bar_height];
            set(obj.slider, 'Position', p);
            obj.prev_mouse_x = cur_mouse_x;
            if obj.options.update_on_drag
                obj.updateAxes();
            end
        end
        function updateAxes(obj)
            % convert the left position to a time
            left_time = (obj.slider_left_x - obj.left_limit)/obj.width_per_time;
            right_time = (obj.slider_right_x - obj.left_limit)/obj.width_per_time;
            
            ax = obj.axes_handles{1};
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
            ax = obj.axes_handles{1};
            
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
            ax = obj.axes_handles{1};
            
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