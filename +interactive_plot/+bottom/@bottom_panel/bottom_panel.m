classdef bottom_panel < handle
    %
    %   Class:
    %   interactive_plot.bottom_panel
    
    properties
        mouse_man
        options
        settings
        render_params
        fig_handle
        axes_handles
        right_panel
        
        %Processor Classes
        %--------------------
        scroll_bar %interactive_plot.bottom.scroll_bar
        x_zoom  %interactive_plot.bottom.x_zoom
        
        
        %Positions
        %--------------------
        scroll_left_limit
        scroll_right_limit
        scroll_bottom
        scroll_height
        scroll_width
        small_button_width
        small_button_height
        
        %Handles to created objects
        %--------------------------
        scroll_background_bar
        slider
        left_button
        right_button
        auto_scroll_button
        zoom_out_button
        zoom_in_button
        x_disp_handle
        x_options_button
        x_options
        
        %State
        %----------------------------
        auto_scroll_enabled = false
    end
    
    properties (Dependent)
        x_max
        x_min
    end
    
    methods
        function value = get.x_max(obj)
            value = obj.scroll_bar.x_max;
        end
        function value = get.x_min(obj)
            value = obj.scroll_bar.x_min;
        end
    end
    
    methods
        function obj = bottom_panel(shared)
            
            options = shared.options;
            render_params = shared.render_params;
            
            obj.settings = shared.session.settings;
            obj.mouse_man = shared.mouse_manager;
            obj.options = shared.options;
            obj.fig_handle = shared.fig_handle;
            obj.axes_handles = shared.axes_handles;
            
            
            
            % We are assuming at this point all figure units are normalized
            
            %obj.small_button_width = render_params.small_button_width;
            %obj.small_button_height = render_params.small_button_height;
            
            p_axes = get(obj.axes_handles{1},'Position');
            x = p_axes(1);
            y = render_params.scroll_bar_bottom; % y position of the bottom of the scroll bar
            button_width = render_params.small_button_width;
            button_height = render_params.small_button_height;
            
            p_button = [x y button_width button_height];
            
            %X Options Button
            %-------------------------------------------
            obj.x_options_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '...',...
                'units', 'normalized', 'Position',p_button,...
                'Visible', 'on');
            
            %Create scrollbar
            %----------------------------------------
            if options.streaming
                n_buttons_rightside = 4;
            else
                n_buttons_rightside = 3;
            end
            
            obj.scroll_left_limit = x + 2*button_width;
            obj.scroll_right_limit = p_axes(1) + p_axes(3) - n_buttons_rightside*button_width;
            obj.scroll_bottom = y;
            obj.scroll_height = render_params.scroll_bar_height;
            obj.scroll_width = obj.scroll_right_limit - obj.scroll_left_limit;
            
            p_scroll = [obj.scroll_left_limit, obj.scroll_bottom, ...
                obj.scroll_width, obj.scroll_height];
            
            %Background - doesn't move
            obj.scroll_background_bar = annotation('rectangle', p_scroll, 'FaceColor', 'w');
            
            %Foreground
            obj.slider = annotation('rectangle', p_scroll, 'FaceColor', 'k');
            
            %Scroll Bar Buttons
            %--------------------------------------------------------- 
            p_button(1) = obj.scroll_left_limit - button_width;
            
            % uicontrol push buttons don't look quite as good in this case,
            % but they have a visible response when clicked and are
            % slightly easier to work with
            obj.left_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '<',...
                'units', 'normalized', 'Position',p_button,...
                'Visible', 'on');
            
            p_button(1) = obj.scroll_right_limit;
            
            obj.right_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '>',...
                'units', 'normalized', 'Position',p_button,...
                'Visible', 'on');
            
            %Auto Scroll Button
            %---------------------------------------------
            if options.streaming
                
                p_button(1) = obj.scroll_right_limit + button_width;
                
                obj.auto_scroll_button = uicontrol(obj.fig_handle,...
                    'Style', 'togglebutton', 'String', '~',...
                    'units', 'normalized', 'Position',p_button,...
                    'Visible','on','callback', @(~,~) obj.cb_scrollStatusChanged);
                
                obj.auto_scroll_enabled = true;
            end
            
            %X Zoom Button
            %-------------------------------------------------
            p_button(1) = obj.scroll_right_limit + (n_buttons_rightside-2)*button_width;
            
            obj.zoom_out_button = interactive_plot.utils.ip_button(...
                obj.fig_handle,p_button,'-');
            
            p_button(1) = obj.scroll_right_limit + (n_buttons_rightside-1)*button_width;
            
            obj.zoom_in_button = interactive_plot.utils.ip_button(...
                obj.fig_handle,p_button,'+');
            
            %X Numeric Display
            %--------------------------------------------
            %p = [0 0.04 0.003 0.003];
            
            %Position to the right of the zoom in button
            
            %Annotation text position - 2nd element is top????
            
            p_x_disp = [p_axes(1) + p_axes(3) + 0.01, 0.03 0.003, 0.003];
            
            %This background matches the default figure color background
            %...
         	bc = [0.9400    0.9400    0.9400];
            obj.x_disp_handle = annotation(obj.fig_handle,'textbox',p_x_disp,...
                    'Units', 'normalized', ...
                    'String','Testing','FontSize',8,...
                    'margin',2,'FitBoxToText','on',...
                    'EdgeColor','k',... %This is arbitrary and will likely change
                    'BackgroundColor',bc);
            
            %Processors
            %------------------------------------------------
            obj.x_zoom = interactive_plot.bottom.x_zoom(obj,obj.zoom_out_button,...
                obj.zoom_in_button,shared);
            obj.scroll_bar = interactive_plot.bottom.scroll_bar(...
                shared,obj);
            obj.x_options = interactive_plot.bottom.x_axis_options(...
                shared,obj.x_options_button);
        end
        function linkObjects(obj,right_panel)
           obj.right_panel = right_panel; 
        end
    end
    methods
        function setXDisplayString(obj,str)
            obj.x_disp_handle.String = str;
        end
        function disableAutoScroll(obj)
            %
            %   Called on scrolling initialization
            
            logic_value = false;
            is_cb = false;
            h__processNewAutoScrollValue(obj,logic_value,is_cb)
        end
       	function cb_scrollStatusChanged(obj)
            logic_value = ~get(obj.auto_scroll_button,'Value');
            is_cb = true;
            h__processNewAutoScrollValue(obj,logic_value,is_cb)
            
        end
    end   
end

function h__processNewAutoScrollValue(obj,logic_value,is_cb)
    
    obj.auto_scroll_enabled = logic_value;
    obj.settings.auto_scroll_enabled = logic_value;
    if ~logic_value
       %Clear all y-display strings 
       obj.right_panel.clearDisplayStrings();
    end
    if is_cb
        h__setAutoScrollString(obj);
    elseif ~isempty(obj.auto_scroll_button)
        set(obj.auto_scroll_button,'Value',logic_value);
        h__setAutoScrollString(obj);
    end
    
end

function h__setAutoScrollString(obj)
if obj.auto_scroll_enabled
    set(obj.auto_scroll_button,'String','~'); 
else
    set(obj.auto_scroll_button,'String','`');
end
end
