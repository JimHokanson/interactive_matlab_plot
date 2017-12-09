classdef bottom_panel < handle
    %
    %   Class:
    %   interactive_plot.bottom_panel
    
    properties
        mouse_man
        options
        render_params
        fig_handle
        axes_handles
        
        %Processor Classes
        %--------------------
        scroll_bar
        x_zoom
        
        
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
        
        %State
        auto_scroll_enabled
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
        function obj = bottom_panel(handles,mouse_man,options,render_params)
            obj.mouse_man = mouse_man;
            obj.options = options;
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            
            p = get(handles.axes_handles{1},'Position');
            
            % We are assuming at this point all figure units are normalized
            
            obj.small_button_width = render_params.small_button_width;
            obj.small_button_height = render_params.small_button_height;
            
            %Create scrollbar
            %----------------------------------------
            obj.scroll_left_limit = p(1) + render_params.small_button_width;
            
            if options.streaming
                n_buttons_rightside = 4;
            else
                n_buttons_rightside = 3;
            end
            obj.scroll_right_limit = p(1) + p(3) - n_buttons_rightside*obj.small_button_width;
            obj.scroll_bottom = render_params.scroll_bar_bottom;
            obj.scroll_height = render_params.scroll_bar_height;
            
            %Background - doesn't move
            obj.scroll_width = obj.scroll_right_limit - obj.scroll_left_limit;
            p1 = [obj.scroll_left_limit, obj.scroll_bottom, ...
                obj.scroll_width, obj.scroll_height];
            obj.scroll_background_bar = annotation('rectangle', p1, 'FaceColor', 'w');
            
            obj.slider = annotation('rectangle', p1, 'FaceColor', 'k');
            
            %Scroll Bar Buttons
            %-----------------------------------------
            bar_height = obj.scroll_height;
            button_width = obj.small_button_width;
            x1 = obj.scroll_left_limit - button_width; % position of scroll left button
            x2 = obj.scroll_right_limit; % position of scroll right button
            y = obj.scroll_bottom; % y position of the bottom of the scroll bar
            
            % uicontrol push buttons don't look quite as good in this case,
            % but they have a visible response when clicked and are
            % slightly easier to work with
            obj.left_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '<',...
                'units', 'normalized', 'Position',[x1, y, button_width, bar_height],...
                'Visible', 'on');
            %'callback', @(~,~) obj.cb_scrollLeft()
            
            obj.right_button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', '>',...
                'units', 'normalized', 'Position',[x2, y, button_width, bar_height],...
                'Visible', 'on');
            
            %Auto Scroll Button
            %---------------------------------------------
            
            if options.streaming
                
                H = obj.small_button_height;
                L = obj.small_button_width;
                
                % numbering (x3,x4) is based on the buttons which already exist
                % (created in the scroll_bar class which is the parent of this
                % class)
                x = obj.scroll_right_limit + L; % position of x zoom out button
                y = obj.scroll_bottom; % y position of the bottom of the scroll bar
                
                obj.auto_scroll_button = uicontrol(obj.parent.fig_handle,...
                    'Style', 'togglebutton', 'String', '~',...
                    'units', 'normalized', 'Position',[x, y, L, H],...
                    'Visible', 'on');
                %'callback', @(~,~) obj.cb_scrollStatusChanged
                
                obj.auto_scroll_enabled = false;
            end
            
            %X Zoom Button
            %-------------------------------------------------
            H = obj.small_button_height;
            L = obj.small_button_width;
            
            % numbering (x3,x4) is based on the buttons which already exist
            % (created in the scroll_bar class which is the parent of this
            % class)
            x3 = obj.scroll_right_limit + (n_buttons_rightside-2)*L; % position of x zoom out button
            x4 = obj.scroll_right_limit + (n_buttons_rightside-1)*L; % position of x zoom in button
            y = obj.scroll_bottom; % y position of the bottom of the scroll bar
            
            obj.zoom_out_button = interactive_plot.ip_button(...
                obj.fig_handle,[x3,y,L,H],'-');
            
            obj.zoom_in_button = interactive_plot.ip_button(...
                obj.fig_handle,[x4, y, L, H],'+');
            
            obj.x_zoom = interactive_plot.x_zoom(obj,obj.zoom_out_button,...
                obj.zoom_in_button,handles,options);
            obj.scroll_bar = interactive_plot.scroll_bar(...
                obj.mouse_man,handles,options,obj);
        end
    end
    methods
       	function cb_scrollStatusChanged(obj)
            obj.auto_scroll_enabled = ~get(obj.scroll_button,'Value');
            if obj.auto_scroll_enabled
                set(obj.auto_scroll_button,'String','~'); 
            else
                set(obj.auto_scroll_button,'String','`');
            end
        end
    end
    
end

