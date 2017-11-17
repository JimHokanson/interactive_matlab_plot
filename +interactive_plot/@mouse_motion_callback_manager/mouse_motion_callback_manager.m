classdef mouse_motion_callback_manager < handle
    %
    %   Class:
    %   interactive_plot.mouse_motion_callback_manager
    %
    %   Processors should call this function.
    %
    %   
    
    properties
        fig_handle
        parent %interactive plot class
        axes_handles
        axis_resizer
        
        %Resize limits
        %------------
        x_min = 0
        x_max
        y_min
        y_max
    end
    
    methods
        function obj = mouse_motion_callback_manager(parent)
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            obj.axes_handles = parent.axes_handles;
            obj.axis_resizer = parent.axis_resizer;
                     
            %Determine limits for axis resizer
            %-------------------------------------------------
            temp = get(obj.axes_handles{1},'position');
            obj.x_max = temp(1); %left most part of axis
            obj.initDefaultState();
            obj.y_max = temp(2) + temp(4);
            temp = get(obj.axes_handles{end},'position');
            obj.y_min = temp(2);
            
            
        end
        function initializeLineMoving(obj, id)
            set(obj.fig_handle, 'WindowButtonMotionFcn',@(~,~) obj.parent.line_moving_processor.moveLine(id));
            set(obj.fig_handle, 'WindowButtonUpFcn',  @(~,~) obj.releaseLineMoving());          
        end
        function releaseLineMoving(obj)
            set(obj.fig_handle,'WindowButtonMotionFcn','');
            obj.parent.line_moving_processor.resizePlots();
            obj.initDefaultState();
        end
        function initializeAxisResize(obj)
        	set(obj.fig_handle, 'WindowButtonMotionFcn',...
                @(~,~) obj.axis_resizer.processResize());
         	set(obj.fig_handle, 'WindowButtonUpFcn',  ...
                @(~,~) obj.releaseAxisResize());          

        end
        function releaseAxisResize(obj)
            disp('I ran')
            obj.initDefaultState();
        end
        function initDefaultState(obj)
            %TODO: Anything we want here ...
            set(obj.fig_handle,'WindowButtonMotionFcn',@(~,~) obj.defaultMouseMovingCallback());
        end
        function initializeScrolling(obj)
            % temporary hack. this is not efficient
            %--
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_x = cur_mouse_coords(1);
            obj.parent.scroll_bar.prev_mouse_x = cur_mouse_x;
            %--
            set(obj.fig_handle, 'WindowButtonMotionFcn', @(~,~) obj.parent.scroll_bar.scroll());
            set(obj.fig_handle, 'WindowButtonUpFcn', @(~,~) obj.releaseScrollBar());   
        end
        function releaseScrollBar(obj)
            set(obj.fig_handle, 'WindowButtonMotionFcn', '');
            obj.parent.scroll_bar.updateAxes();
        end
        function defaultMouseMovingCallback(obj)
            %
            %
            %   Window:
            %   ---------
            
            
            %TODO:
            %1) maintain an array of y-positions - this will need to update
            %  if we change the axes size
            %2) when in range (but no mouse click) change the cursor
            %       - top half of each axes - pull down or pan
            %       - bottom half - pull up or pan
            %       - for now toggle between pan and pull every 5% of the
            %       axis
            %
            %   Pull behavior:
            %   - keep extreme the same
            %   - based on where we grab relative to the fixed point, scale
            %   everything else
            %   - if we pass the bottom point ... (not sure what to do)
            
            cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
            cur_mouse_y_pos = cur_mouse_coords(2);
            cur_mouse_x_pos = cur_mouse_coords(1);
            
            
            %Removed x_min check, might want this back to have buttons
            %on far left
            %
            %far left buttons - zoom in, zoom out, autoscale
            if cur_mouse_x_pos < obj.x_max && ...
                    cur_mouse_y_pos > obj.y_min && ...
                    cur_mouse_y_pos < obj.y_max
                
                obj.axis_resizer.registerResizeCall(cur_mouse_y_pos);
            end
        end
    end
end

