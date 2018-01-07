classdef y_axis_options < handle
    %
    %   Class:
    %   interactive_plot.left.y_axis_options
    %
    %   This class handles the button that provides action options for each
    %   y-axis.
    %
    %   Options
    %   -------
    %   1) Autoscale local
    %   2) Autoscale global
    %   2) YLimMode - manual
    %   3) YLimMode - auto
    %   4) Set y-axis manually
    %
    %   See Also
    %   --------
    %   interactive_plot.left.left_panel
    
    
    
    properties
        fig_handle %necessary?
        axes_handles
        line_handles
        options         %interactive_plot.options
        axes_action_manager
        axes_props
        
        context_menu
        cal_dependent_menus
        
        current_I
        
        buttons
    end
    
    methods
        function obj = y_axis_options(shared,buttons)
            %
            %   obj = interactive_plot.y_axis_options(handles,options,buttons)
         
            obj.fig_handle = shared.fig_handle;
            obj.axes_handles = shared.axes_handles;
            obj.line_handles = shared.handles.line_handles;
            obj.buttons = buttons;
            obj.options = shared.options;
            obj.axes_props = shared.session.settings.axes_props;
            
            c = uicontextmenu('Parent',obj.fig_handle);
            
            m_temp = cell(1,3); 
            
            uimenu(c,'Label','autoscale view','Callback',@(~,~)obj.autoscale(1));
            uimenu(c,'Label','autoscale global','Callback',@(~,~)obj.autoscale(0));
            uimenu(c,'Label','ylim manual','Callback',@(~,~)obj.setYLimMode('manual'));
         	uimenu(c,'Label','ylim auto','Callback',@(~,~)obj.setYLimMode('auto'));
            uimenu(c,'Label','new calibration','Callback',@(~,~)obj.newCalibration());
            m_temp{1} = uimenu(c,'Label','adjust cal offset','Callback',@(~,~)obj.adjustCalibrationOffset());
            m_temp{2} = uimenu(c,'Label','adjust cal gain','Callback',@(~,~)obj.adjustCalibrationGain());
            m_temp{3} = uimenu(c,'Label','edit cal','Callback',@(~,~)obj.editCalibration());
            
            obj.context_menu = c;
            obj.cal_dependent_menus = [m_temp{:}];
            
            n_buttons = length(buttons);
            
            for i = 1:n_buttons
                cur_button = buttons{i};
                cur_button.setCallback(@(~,~)obj.buttonClicked(i));
            end
         
        end
        function linkObjects(obj,axes_action_manager)
           obj.axes_action_manager = axes_action_manager;
        end
    end
    %Calibration callbacks ================================================
    methods
        function newCalibration(obj)
            obj.axes_action_manager.calibrateData();
        end
        function adjustCalibrationOffset(obj)
            
        end
        function adjustCalibrationGain(obj)
            
        end
        
        function editCalibration(obj)
            
        end
    end
    
    %Other menu callbacks =================================================
    methods
         function autoscale(obj,view_only,I)
             %
             %
             %  Uses global option
             %  .auto_scale_padding
             %
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
    end
    
    methods
        function buttonClicked(obj,I)
            drawnow('nocallbacks')
            %disp('button clicked')
            obj.current_I = I;
            current_button = obj.buttons{I}.h;
            p = getpixelposition(current_button);
            %Position must be in pixel units for context menu
            %The context menu only takes in a xy of the upper left corner
            
            visible = obj.axes_props.has_calibration(I);
            if visible
                v_value = 'on';
            else
                v_value = 'off';
            end
            set(obj.cal_dependent_menus,'Visible',v_value);
            
            set(obj.context_menu,'Visible','on','Position',p(1:2))
            
            %This seems to help with reliability of the context menu
            %showing up ...
            drawnow('nocallbacks')
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

