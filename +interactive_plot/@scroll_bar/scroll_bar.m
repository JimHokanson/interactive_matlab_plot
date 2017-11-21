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
        zoom_in_button
        zoom_out_button
        background_bar
        slider
        
        base_y = 0.01;
        left_limit % the edges of the background bar
        right_limit
        bar_height = 0.04;
        bar_width
        button_width = 0.02;
        
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
            
            % assume that at this point all figure units are normalized
            
            %Create scrollbar
            %----------------------------------------
            %- limits
            axes_handles = obj.parent.axes_handles;
            temp1 = axes_handles{1};
            p = temp1.Position;
            obj.left_limit = p(1) + obj.button_width;
            obj.right_limit = p(1) + p(3) - 3*obj.button_width;
            
            %Background - doesn't move
            obj.bar_width = obj.right_limit - obj.left_limit;
            obj.background_bar = annotation(...
                'rectangle', [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height], ...
                'FaceColor', 'w');
            
            %Buttons
            %-----------------------------------------
            H = obj.bar_height;
            L = obj.button_width;
            x1 = obj.left_limit - L;
            x2 = obj.right_limit;
            x3 = obj.right_limit + L;
            x4 = obj.right_limit + 2*L;
            y = obj.base_y;
            
            obj.left_button = annotation('textbox',...
                [x1, y, L, H], 'String','<', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');
            obj.right_button = annotation('textbox',...
                [x2, y, L, H], 'String','>', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');
            % NYI
            %--------------------------
            obj.zoom_out_button = annotation('textbox',...
                [x3, y, L, H], 'String','-', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');
            obj.zoom_in_button = annotation('textbox',...
                [x4, y, L, H], 'String','+', 'VerticalAlignment',...
                'middle', 'HorizontalAlignment', 'center');
            
            
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
                'rectangle', [obj.left_limit, obj.base_y, obj.bar_width, obj.bar_height], ...
                'FaceColor', 'k');
            obj.slider_left_x = obj.left_limit;
            obj.slider_right_x = obj.right_limit;
            
            
            ax = obj.parent.axes_handles{1};
            
            % add an action listener which updates the size of the scroll
            % bar when the zoom is changed
            addlistener(ax, 'XLim', 'PostSet', @(~,~) obj.xLimChanghed);
            
            %  Add callback for on click on rectangle to engage mouse movement
            set(obj.slider, 'ButtonDownFcn', @(~,~) obj.parent.mouse_manager.initializeScrolling);
        end
        function xLimChanghed(obj)
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
            catch ME
                %JAH: This is temporary until Greg fixes this code
                %   - most likely we need to verify handles are valid or
                %   destory the listener earlier than we currently are
                %   
                fprintf(2,'Caught error on on time range change\n')
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
        end
    end
end