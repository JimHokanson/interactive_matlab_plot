classdef auto_scroll < handle
    %
    %   Class:
    %   interactive_plot.auto_scroll
    %
    %   Controller for allowing the plot to scroll as more data arrives ...
    
    properties
        parent
        scroll_button
        scroll_enabled = true;
    end
    
    methods
        function obj = auto_scroll(parent)
            
            %TODO: Fix links back to the parent like the other classes
            obj.parent = parent;
            
            H = obj.parent.bar_height;
            L = obj.parent.button_width;
            
            % numbering (x3,x4) is based on the buttons which already exist
            % (created in the scroll_bar class which is the parent of this
            % class)
            x = obj.parent.right_limit + L; % position of x zoom out button
            y = obj.parent.base_y; % y position of the bottom of the scroll bar
            
            obj.scroll_button = uicontrol(obj.parent.fig_handle,...
                'Style', 'togglebutton', 'String', '~',...
                'units', 'normalized', 'Position',[x, y, L, H],...
                'Visible', 'on', 'callback', @(~,~) obj.cb_scrollStatusChanged);
        end
        function cb_scrollStatusChanged(obj)
            obj.scroll_enabled = ~get(obj.scroll_button,'Value');
            if obj.scroll_enabled
                set(obj.scroll_button,'String','~'); 
            else
                set(obj.scroll_button,'String','`');
            end
        end
    end
end

