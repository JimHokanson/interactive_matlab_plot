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
        parent
        mouse_man
        options
        fig_handle
        axes_props
        h_axes
        
        scroll_left_limit
        scroll_right_limit
        
        
        slider_bottom
        slider_height
        
        %Object handles
        %----------------
        left_button
        right_button
        slider
        
        xlim_listener
        
        %State
        %----------------------
        prev_mouse_x
        width_per_time
        slider_right
        slider_left
        view_xlim
        bar_width
    end
    
    properties (Dependent)
        x_min
        x_max
        auto_scroll_enabled
    end
    
    methods
        function value = get.auto_scroll_enabled(obj)
            value = obj.parent.auto_scroll_enabled;
        end
        function value = get.x_min(obj)
            value = obj.axes_props.x_min;
        end
        function value = get.x_max(obj)
            value = obj.axes_props.x_max;
        end
        function set.x_min(obj,value)
            obj.axes_props.x_min = value;
        end
        function set.x_max(obj,value)
            obj.axes_props.x_max = value;
        end
    end
    
    methods
        function obj = scroll_bar(shared,parent)
            %
            %   obj = interactive_plot.scroll_bar(mouse_man,handles,options,parent)
            %
            %   Inputs
            %   ------
            %   parent : interactive_plot.bottom_panel
            
            obj.parent = parent;
            obj.options = shared.options;
            obj.fig_handle = shared.fig_handle;
            obj.h_axes = shared.axes_handles{1};
            obj.mouse_man = shared.mouse_manager;
            obj.axes_props = shared.session.settings.axes_props; 
            
            xlim = obj.options.xlim;
            if isempty(xlim)
                xlim = get(obj.h_axes,'XLim');
            end
            obj.x_min = xlim(1);
            obj.x_max = xlim(2);
            
            obj.scroll_left_limit = parent.scroll_left_limit;
            obj.scroll_right_limit = parent.scroll_right_limit;
            obj.left_button = parent.left_button;
            obj.right_button = parent.right_button;
            obj.slider = parent.slider;
            p = get(obj.slider,'Position');
            obj.slider_bottom = p(2);
            obj.slider_height = p(4);
            
            %Callback setup
            %----------------------------
            set(obj.left_button,'callback', @(~,~) obj.cb_scrollLeft());
            set(obj.right_button,'callback',@(~,~) obj.cb_scrollRight());
            
            % add an action listener which updates the size of the scroll
            % bar when the zoom is changed
            obj.xlim_listener = addlistener(obj.h_axes, 'XLim', 'PostSet', @(~,~) obj.xLimChanged);
            
            %  Add callback for on click on rectangle to engage mouse movement
            set(obj.slider, 'ButtonDownFcn', @(~,~) obj.initializeScrolling);
            
            % set up scroll bar based on what the starting zoom is
            % this is testing for the case that the user had already zoomed
            % before feeding the figure to the class.
            obj.xLimChanged();
            
            
        end
        function delete(obj)
            delete(obj.xlim_listener);
        end
    end
    methods
        function initializeScrolling(obj)
            %
            %   Activated by mouse down on the slider
            
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            obj.prev_mouse_x = cur_mouse_x;
            obj.parent.disableAutoScroll();
            obj.mouse_man.setMouseMotionFunction(@obj.scroll);
            obj.mouse_man.setMouseUpFunction(@obj.releaseScrollBar);
        end
        function releaseScrollBar(obj)
            if ~obj.options.update_on_drag
                obj.updateAxes();
            end
            obj.mouse_man.initDefaultState();
        end
        function updateXMax(obj,new_x_max)
            %
            %   Called by streaming ...
            %
            %   interactive_plot.bottom.scroll_bar.updateXMax
            
            %This is needed because our xlim might not change if we don't
            %have auto-scroll enabled. This however forces the scroll bar
            %to resize ...
            obj.x_max = new_x_max;
            obj.xLimChanged();
        end
        function xLimChanged(obj)
            %  obj.xLimChanged()
            %
            % Called by action listener on x limits of the first axes.
            % checks the limits of the axis of the first plot and sets the
            % scroll bar width based on the limits relative to the total time
            % range in the data
            
            %We get errors from this on closing
            try
                %convert from units of space to proportion of time
                
                xlim = get(obj.h_axes,'XLim');
                if xlim(1) < obj.x_min
                    obj.x_min = xlim(1);
                end
                if xlim(2) > obj.x_max
                    obj.x_max = xlim(2);
                end
                
                total_time_range = obj.x_max - obj.x_min;
                
                ax = obj.h_axes;
                x_view_min = ax.XLim(1);
                x_view_max = ax.XLim(2);
                
                obj.width_per_time = (obj.scroll_right_limit - obj.scroll_left_limit)/total_time_range;
                
                obj.slider_left = obj.scroll_left_limit + x_view_min*obj.width_per_time;
                obj.slider_right = obj.scroll_left_limit + x_view_max*obj.width_per_time;
                obj.bar_width = obj.slider_right - obj.slider_left;
                obj.view_xlim = xlim;
                
                p = [obj.slider_left, obj.slider_bottom, obj.bar_width, obj.slider_height];
                set(obj.slider, 'Position', p);
            catch ME
                %disp(ME)
                %disp(ME.stack(1));
            end
        end
        function scroll(obj)
            % obj.scroll()
            %
            % Callback function for scrolling
            % Called whenever the mouse is both clicked and moves
            %
            % This function may call updateAxes as scrolling occurs
            % depending on the options specified in the options class held
            % by the parent.
            
            %obj.prev_mouse_x has been set when the mouse is first clicked.
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            
            dif = cur_mouse_x - obj.prev_mouse_x;
            new_right_limit = obj.slider_right  + dif;
            new_left_limit = obj.slider_left + dif;
            
            %Adjust left and right based on limits
            %--------------------------------------
            if new_right_limit >= obj.scroll_right_limit
                % have to base position on this edge
                obj.slider_left = obj.scroll_right_limit - obj.bar_width;
                obj.slider_right = obj.scroll_right_limit;
            elseif new_left_limit <= obj.scroll_left_limit
                obj.slider_left = obj.scroll_left_limit;
                obj.slider_right = obj.slider_left + obj.bar_width;
            else % not at a boundary
                obj.slider_left = new_left_limit;
                obj.slider_right = new_right_limit;
            end
            
            %Update the scrollbar position
            %--------------------------------------------
            p = [obj.slider_left, obj.slider_bottom, obj.bar_width, obj.slider_height];
            set(obj.slider, 'Position', p);
            obj.prev_mouse_x = cur_mouse_x;
            
            %Change axes if desired
            %------------------------------------------------
            if obj.options.update_on_drag
                obj.updateAxes();
            end
        end
        function updateAxes(obj)
            % convert the left position to a time
            left_time = (obj.slider_left - obj.scroll_left_limit)/obj.width_per_time;
            right_time = (obj.slider_right - obj.scroll_left_limit)/obj.width_per_time;
            
            ax = obj.h_axes;
            xlim_new = [left_time, right_time];
            set(ax,'XLim',xlim_new);
            obj.view_xlim = xlim_new;
        end
    end
    methods % callbacks
        function cb_scrollLeft(obj)
            
            
            % TODO: allow continuous scrolling with this method by looping
            %until mouse up
            fraction_shift = obj.options.scroll_button_factor;
            range_in_view = obj.view_xlim(2) - obj.view_xlim(1);
            amt_to_shift = fraction_shift*range_in_view;
            ax = obj.h_axes;
            xlim = get(ax,'XLim');
            
            new_xmin = xlim(1) - amt_to_shift;
            if ~(new_xmin < obj.x_min)
                set(ax,'XLim',xlim - amt_to_shift);
            else
                xlim(1) = obj.x_min;
                xlim(2) = obj.x_min + range_in_view;
                set(ax,'XLim',xlim);
            end
        end
        function cb_scrollRight(obj)
            % see comments on cb_scrollRight
            fraction_shift = obj.options.scroll_button_factor;
            range_in_view = obj.view_xlim(2) - obj.view_xlim(1);
            amt_to_shift = fraction_shift*range_in_view;
            ax = obj.h_axes;
            xlim = get(ax,'XLim');
            
            new_xmax = xlim(2) + amt_to_shift;
            if ~(new_xmax > obj.x_max)
                set(ax,'XLim',xlim + amt_to_shift);
            else
                xlim(2) = obj.x_max;
                xlim(1) = obj.x_max - range_in_view;
                set(ax,'XLim',xlim);
            end
        end
    end
end