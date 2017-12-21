classdef y_axis_options < handle
    %
    %   Class:
    %   interactive_plot.y_axis_options
    
    %   Options
    %   -------
    %   1) Autoscale local
    %   2) Autoscale global
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
            
            uimenu(c,'Label','autoscale view','Callback',@(~,~)obj.autoscale(1));
            uimenu(c,'Label','autoscale global','Callback',@(~,~)obj.autoscale(0));
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
            drawnow()
            %disp('button clicked')
            obj.current_I = I;
            current_button = obj.buttons{I}.h;
            p = getpixelposition(current_button);
            %Position must be in pixel units for context menu
            %The context menu only takes in a xy of the upper left corner
            set(obj.context_menu,'Visible','on','Position',p(1:2))
            drawnow()
            %This seems to help with reliability of the context menu
            %showing up ...
            
        end
        function autoscale(obj,view_only,I)
            if nargin == 2
                I = obj.current_I;
            end
            h_line = obj.line_handles{I};
            h_axes = obj.axes_handles{I};
            y_data = get(h_line,'YData');
            if view_only
                xlim = get(h_axes,'XLim');
                x_data = get(h_line,'XData');
                I1 = find(x_data >= xlim(1),1);
                I2 = find(x_data <= xlim(2),1,'last');
                if isempty(I1) || isempty(I2)
                    y_min = 0;
                    y_max = 1;
                else
                    y_min = min(y_data(I1:I2));
                    y_max = max(y_data(I1:I2));
                end
            else
                %For a global view we need to be looking at all the data
                s = interactive_plot.data_interface.getRawLineData(h_line);
                y_data = s.y_final;
                y_min = min(y_data);
                y_max = max(y_data);
            end
            
            y_range = y_max - y_min;
            extra = y_range*obj.options.auto_scale_padding;
            y_max = y_max + extra;
            y_min = y_min - extra;
            if y_max == y_min
                y_max = 0.0001 + y_min;
            end
            set(h_axes,'YLim',[y_min y_max]);
        end
        function setYLimMode(obj,mode)
            current_axes = obj.axes_handles{obj.current_I};
            set(current_axes,'YLimMode',mode);
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

