classdef calibration_gui < handle
    %
    %   Class:
    %   interactive_plot.calibration_gui
    %
    %   See Also
    %   interactive_plot.calibration
    
    properties
        h_fig
        h_axes
        h_avg
        h_in
        h_out
        h_name
        h_units
        h_cancel
        h_ok
        
        is_ok = false
        x_data
        y_data
        units
        name
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
            
%             root = fileparts(which('interactive_plot.calibration_gui'));
%             gui_path = fullfile(root,'calibration_gui.fig');
%             

            %==============================================================
            h_fig = figure();
            obj.h_fig = h_fig;
            set(h_fig,'Units','normalized');
            obj.h_axes = axes('Parent',h_fig,'Units','normalized',...
                'Position',[0.07 0.07 0.88 0.68]);
            
            for i = 1:2
                if i == 1
                    B1 = 0.90;
                else
                    B1 = 0.80;
                end
                H1 = 0.08;
                C_WIDTH = 0.12;
                LEFT = 0.03;
                BUFFER = 0.01;
                obj.h_avg(i) = uicontrol('style','pushbutton','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 C_WIDTH H1],...
                    'String','Average','FontSize',12);
                LEFT = LEFT + C_WIDTH + BUFFER;
                
                obj.h_in(i) = uicontrol('style','edit','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 C_WIDTH H1],...
                    'HorizontalAlignment','left');
                LEFT = LEFT + C_WIDTH;
                uicontrol('style','text','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 0.05 H1],...
                    'String','TO','FontSize',12);
                LEFT = LEFT + 0.05;
                
                obj.h_out(i) = uicontrol('style','edit','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 C_WIDTH H1],...
                    'HorizontalAlignment','left');
                
                
                %Name and Units
                %---------------------------------------------
                LEFT = LEFT + C_WIDTH + 3*BUFFER;
                if i == 1
                    str = 'Name';
                else
                    str = 'Units';
                end
                uicontrol('style','text','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 0.1 H1],...
                    'String',str,'FontSize',12,'HorizontalAlignment','right');
                
                LEFT = LEFT + 0.1;
                temp = uicontrol('style','edit','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 2*C_WIDTH H1],...
                    'HorizontalAlignment','left');
            
                if i == 1
                    obj.h_name = temp;
                else
                    obj.h_units = temp;
                end
                
                %Ok and Cancel buttons
                %---------------------------------------------
                
                LEFT = LEFT + 2*C_WIDTH + 3*BUFFER;
                if i == 1
                    str = 'Cancel';
                else
                    str = 'OK';
                end
                temp = uicontrol('style','pushbutton','Parent',h_fig,...
                    'Units','normalized','Position',[LEFT B1 C_WIDTH H1],...
                    'String',str,'FontSize',12);
                
                if i == 1
                    obj.h_cancel = temp;
                else
                    obj.h_ok = temp;
                end
            end
            %==============================================================
            
            
            obj.x_data = s.x;
            obj.y_data = s.y_raw;
            
            ax = obj.h_axes;
            plot(ax,s.x,s.y_raw)
            ylim = get(ax,'YLim');
            y_range = ylim(2)-ylim(1);
            add_factor = y_range*0.1;
            set(ax,'YLim',[ylim(1)-add_factor ylim(2)+add_factor]);
            
            p = get(ax,'Position');
            
            %Needed for selection highlighting
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
            
            set(obj.h_avg(1),'Callback',@(~,~) obj.averageData(1));
            set(obj.h_avg(2),'Callback',@(~,~) obj.averageData(2));
            
            set(obj.h_cancel,'Callback',@(~,~) obj.closeFigure(0));
            set(obj.h_ok,'Callback',@(~,~) obj.closeFigure(1));
            
            set(obj.h_axes,'ButtonDownFcn',@(~,~) obj.mouseDown)
            
            uiwait(h_fig);
        end
        function closeFigure(obj,is_good)
            if is_good
                hs = {obj.h_in(1) obj.h_in(2) obj.h_out(1) obj.h_out(2)};
                fields = {'x1','x2','y1','y2'};
                for i = 1:4
                    cur_name = fields{i};
                    obj.(cur_name) = str2double(get(hs{i},'String'));
                    value = obj.(cur_name);
                    if isnan(value)
                        errordlg('Not all values have been set')
                        break;
                    end
                end
                
                if obj.x1 == obj.x2
                    errordlg('Input values are the same')
                end
                
                if obj.y1 == obj.y2
                    errordlg('Output values are the same')
                end
                
                obj.units = get(obj.h_units,'String');
                obj.name = get(obj.h_name,'String');
                
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
            
            obj.mouse_x_initial = x;
  
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
            xlim = get(obj.h_axes,'XLim');
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
            
            h_x = obj.h_in(I);
            set(h_x,'String',sprintf('%g',avg_data));
            
        end
    end
    
end

