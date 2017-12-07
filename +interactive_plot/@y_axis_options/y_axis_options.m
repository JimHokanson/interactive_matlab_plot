classdef y_axis_options < handle
    %
    %   Class:
    %   interactive_plot.y_axis_options
    
    %   Options
    %   -------
    %   1) Autoscale
    %   2) YLimMode - manual
    %   3) YLimMode - auto
    %   4) Set y-axis manually
    
    
    properties
        fig_handle %necessary?
        axes_handles
        line_handles
        options
        context_menu
        current_I
        
        buttons
        % best way to store buttons? multidimensional cell array?
    end
    
    methods
        function obj = y_axis_options(handles,options,buttons)
            %
            %   obj = interactive_plot.y_axis_options(handles,options,buttons)
         
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            obj.line_handles = handles.line_handles;
            obj.buttons = buttons;
            obj.options = options;
            
            c = uicontextmenu('Parent',obj.fig_handle);
            
            % Create child menu items for the uicontextmenu
            % JAH: Nest menu's?????
            uimenu(c,'Label','autoscale','Callback',@(~,~)obj.autoscale());
            uimenu(c,'Label','ylim manual','Callback',@(~,~)obj.setYLimMode('manual'));
         	uimenu(c,'Label','ylim auto','Callback',@(~,~)obj.setYLimMode('auto'));
            %uimenu(c,'Label','set ylim','Callback',@(~,~)obj.autoscale());
            
            obj.context_menu = c;
            
            n_buttons = length(buttons);
            
            for i = 1:n_buttons
                cur_button = buttons{i};
                cur_button.setCallback(@(~,~)obj.buttonClicked(i));
            end
         
        end
        function buttonClicked(obj,I)
            disp('button clicked')
            obj.current_I = I;
            current_button = obj.buttons{I}.h;
            p = getpixelposition(current_button)
            %Position must be in pixel units for context menu
            %The context menu only takes in a xy of the upper left corner
            set(obj.context_menu,'Visible','on','Position',p(1:2))
        end
        function autoscale(obj)
            h_line = obj.line_handles{obj.current_I};
            h_axes = obj.axes_handles{obj.current_I};
            y_min = min(get(h_line,'YData'));
            y_max = max(get(h_line,'YData'));
            set(h_axes,'YLim',[y_min y_max]);
        end
        function setYLimMode(obj,mode)
            set(obj.current_axes,'YLimMode',mode);
        end
        function delete(obj)
            delete(obj.context_menu);
        end
    end
    
end 

%{
clf
wtf = uicontrol('Style','pushbutton','Position', [20 340 70 70])
c = uicontextmenu('Parent',gcf);
uimenu(c,'Label','testing')
p = get(wtf,'Position')
set(c,'Position',p(1:2),'Visible','on')

clf
set(gcf,'Units','Normalized')
wtf = uicontrol('Style','pushbutton','Units','normalized','Position',[0.2 0.2 0.3 0.3])
c = uicontextmenu('Parent',gcf);
uimenu(c,'Label','testing')
p = get(wtf,'Position')
set(c,'Position',[20 340],'Visible','on')

%}

