classdef calibration_gui < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        h
        h_fig
        is_ok = false
        x_data
        y_data
        x1
        x2
        y1
        y2
        axes_y_min
        axes_x_min
        axes_x_max
        axes_height
        mouse_x_initial
        sel_x_start
        sel_x_end
        %selected_data = interactive_plot.data_selection
        h_fig_rect
    end
    
    methods
        function obj = calibration_gui(s)
            %
            %   Inputs
            %   ------
            %   s : struct
            %       .x 
            %       .y
            
            root = fileparts(which('interactive_plot.calibration_gui'));
            gui_path = fullfile(root,'calibration_gui.fig');
            
            h_fig = openfig(gui_path);
            set(h_fig,'Units','normalized');
            obj.h_fig = h_fig;
            obj.h = guihandles(h_fig);
            
            obj.x_data = s.x;
            obj.y_data = s.y_raw;
            
            ax = obj.h.axes1;
            plot(ax,s.x,s.y_raw)
            ylim = get(ax,'YLim');
            y_range = ylim(2)-ylim(1);
            add_factor = y_range*0.1;
            set(ax,'YLim',[ylim(1)-add_factor ylim(2)+add_factor]);
            
            set(obj.h.axes1,'Units','normalized')
            p = get(obj.h.axes1,'Position');
            
            obj.axes_x_min = p(1);
            obj.axes_x_max = p(1) + p(3);
            obj.axes_y_min = p(2);
            obj.axes_height = p(4);
        
            %Setup Callbacks
            %-------------------
            %DONE axes1
            %DONE avg1
            %DONE avg2
            %x1
            %x2
            %y1
            %y2
            %cancel_button
            %ok_button
            
            set(obj.h.avg1,'Callback',@(~,~) obj.averageData(1));
            set(obj.h.avg2,'Callback',@(~,~) obj.averageData(2));
            
            set(obj.h.cancel_button,'Callback',@(~,~) obj.closeFigure(0));
            set(obj.h.ok_button,'Callback',@(~,~) obj.closeFigure(1));
            
            set(obj.h.axes1,'ButtonDownFcn',@(~,~) obj.mouseDown)
            
            uiwait(h_fig);
        end
        function closeFigure(obj,is_good)
            if is_good
                fields = {'x1','x2','y1','y2'};
                for i = 1:4
                    cur_name = fields{i};
                    obj.(cur_name) = str2double(get(obj.h.(cur_name),'String'));
                    value = obj.(cur_name);
                    if isnan(value)
                        errordlg('Not all values have been set')
                        break;
                    end
                end
                obj.is_ok = true;
            else
                obj.is_ok = false;
            end
            
            close(obj.h_fig);
        end
        function mouseDown(obj)
            %
            
            if ~isempty(obj.h_fig_rect)
                delete(obj.h_fig_rect);
            end
            
            set(obj.h_fig,'WindowButtonMotionFcn',@(~,~) obj.mouseMove());
            set(obj.h_fig,'WindowButtonUpFcn',@(~,~) obj.mouseUp());
            
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            x = cur_mouse_coords(1);
            
            obj.mouse_x_initial = x
  
            obj.h_fig_rect = annotation('rectangle',[x obj.axes_y_min 0.001 obj.axes_height],'Color','red');

        end
        function mouseMove(obj)
            cur_mouse_coords = get(obj.h_fig, 'CurrentPoint');
            
            mouse_x = cur_mouse_coords(1);
            if mouse_x < obj.axes_x_min
                mouse_x = obj.axes_x_min;
            end
            if mouse_x > obj.axes_x_max
                mouse_x = obj.axes_x_max;
            end
            
            x = min(mouse_x,obj.mouse_x_initial);
            width = abs(mouse_x - obj.mouse_x_initial);
            
            set(obj.h_fig_rect,'Position',[x obj.axes_y_min width obj.axes_height],...
                'FaceColor',[0.1 0.1 0.1],'FaceAlpha',0.1);
            
        end
        function mouseUp(obj)
            %Get selected data
            %clear callbacks
            
            x_fig_range = obj.axes_x_max - obj.axes_x_min;
            xlim = get(obj.h.axes1,'XLim');
            x_axes_range = xlim(2)-xlim(1);
            
            p = get(obj.h_fig_rect,'Position');
            x_fig_offset = p(1) - obj.axes_x_min;
            
            x_axes_per_fix = x_axes_range/x_fig_range;
            
            start_x = xlim(1) + x_fig_offset*x_axes_per_fix;
            width_x = p(3)*x_axes_per_fix;
            end_x = start_x + width_x;
            
            obj.sel_x_start = start_x;
            obj.sel_x_end = end_x;
            
                        
            set(obj.h_fig,'WindowButtonMotionFcn','');
            set(obj.h_fig,'WindowButtonUpFcn','');
        end
        function averageData(obj,I)
            %1) get selected data
            
            y_data_local = obj.y_data(obj.x_data >= obj.sel_x_start & obj.x_data <= obj.sel_x_end);
            
            avg_data = mean(double(y_data_local));
            
            if I == 1
                h_x = obj.h.x1;
            else
                h_x = obj.h.x2;
            end
            set(h_x,'String',sprintf('%g',avg_data));
            
        end
    end
    
end

