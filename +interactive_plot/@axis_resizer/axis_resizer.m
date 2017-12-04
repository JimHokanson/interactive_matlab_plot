classdef axis_resizer < handle
    %
    %   Class:
    %   interactive_plot.axis_resizer
    %
    %   JAH: ???? - new name???
    %   mouse_vertical_zoom_and_pan
    %
    %   This class allows the user to vertically pan and zoom on an axes
    %   by clicking and dragging the mouse. The distinction of using the
    %   mouse is added because I want to add buttons that also zoom as
    %   well.
    %
    %   See Also
    %   --------
    %   interactive_plot
    %
    %
    
    %JAH Status:
    %This class works but the names are a mess
    %
    % - I needed to be better about y values that are from the figure
    %   and that are from the axes, ideally the variables would be renamed
    % - The variables are somewhat shared but somewhat not, presumably
    %   this could be changed ...
    
    %   On click - engage mouse move callbacks
    %   resize plot actively with movement
    %
    %   - center - pan
    %   - top - shrink or expand keeping bottom fixed
    %   - bottom - shrink or expand keeping bottom fixed
    %   
    
    properties
        parent %interactive.plot
        fig_h
        
        %For axis resizing
        axes_handles
        start_y_click_position %figure based, normalized 
        clicked_ax
        
        
        %TODO: Move to another class for pan
        top_y_start %fig coords
        bottom_y_start %fig coords
        ylim_start
        bottom_ylim_start
        top_ylim_start
        y_diff_fig_start %
        y_range_axes_start
        
        
        
        m
        b
    end
    
    methods
        function obj = axis_resizer(parent)
             obj.parent = parent;
             obj.axes_handles = parent.axes_handles;
             obj.fig_h = parent.fig_handle;
             
%             obj.fig_h = fig_handle;
%             obj.ax = axes;
%             obj.y_position = y_position;
            
            %TODO: Register mouse moving to this class
        end
        function registerResizeCall(obj,y_position,type)
            %
            %   Inputs
            %   ------
            %   type :
            %       1 - up
            %       2 - down
            %       3 - pan
            
            obj.start_y_click_position = y_position;
            
            %TODO: This could be faster ...
            %- should use xy_positions
            %Determining which axes object is "active"
            %---------------------------------------------
            ax = obj.axes_handles;
            for i = 1:length(ax)
                cur_ax = ax{i};
                p = get(cur_ax,'Position');
                y_bottom = p(2);
                y_top = y_bottom + p(4);
                if y_position > y_bottom && y_position < y_top
                    obj.clicked_ax = cur_ax;
                    break;
                end
            end
            
            %Custom code depending upon action type
            %-------------------------------------------
            obj.top_y_start = y_top;
            obj.bottom_y_start = y_bottom; 
            ylim = get(cur_ax,'ylim');
            obj.ylim_start = ylim;
            obj.bottom_ylim_start = ylim(1);
            obj.top_ylim_start = ylim(2);
            obj.y_range_axes_start = ylim(2)-ylim(1);
            
            if type == 2
                obj.y_diff_fig_start = obj.top_y_start - obj.start_y_click_position;
                obj.parent.mouse_manager.initializeScaleTopFixed();
                
                %- what % of original
                %
                %T    T
                %
                %     M2 - mouse    1/2  of previous T-M difference
                %
                %M1
                %
                %B    2xB    %this must have grown by 2x
                %
                %
                %
                %What % of original relative to top?
                %- 50%, then 2x as large
                %- 200%, then 0.5x as large
                
                
                
                
            elseif type == 1
              	obj.y_diff_fig_start = obj.start_y_click_position - obj.bottom_y_start;
                obj.parent.mouse_manager.initializeScaleBottomFixed();
            else
                
                                
                
                %how much mouse movement to ylim movement?
                %y = m*x + b
                %ylim(2) = m*y_top + b
                %ylim(1) = m*y_bottom + b
                
                %As we move the mouse, we need to shift the 
                %current axes by a given amount ...
                
                obj.m = obj.y_range_axes_start/(y_top - y_bottom);
                %obj.b = ylim(2) - obj.m*y_top;
                
                
                obj.parent.mouse_manager.initializeAxisPan();
            end
            
        end
        function processPan(obj)
            cur_mouse_coords = get(obj.fig_h, 'CurrentPoint');
            y = cur_mouse_coords(2);
            %x = cur_mouse_coords(1);
            
            y_delta = y - obj.start_y_click_position;
            %ylim_new = zeros(1,2);
            %TODO: Just hold onto original ylim
            %ylim_new = obj.bottom_y_start - obj.m*y_delta;
            
            ylim_new = obj.ylim_start - obj.m*y_delta;
            set(obj.clicked_ax,'ylim',ylim_new);
        end
        function processScaleTopFixed(obj)
            %
            %   Approach:
            %   - wherever the mouse moves, adjust the bottom
            %   accordingly so that the original axes value where
            %   we originally clicked moves to the location where the mouse
            %   currently is
            %   - see more in comments above
            %
            
            MAX_SCALE = 5;
            
            cur_mouse_coords = get(obj.fig_h, 'CurrentPoint');
            y = cur_mouse_coords(2);
            if y >= obj.top_y_start
                %do nothing
                %JAH: Eventually we could do more here ...
                return
            end
            
            y_delta = obj.top_y_start - y;
            y_ratio  = obj.y_diff_fig_start/y_delta;
            if y_ratio > MAX_SCALE
                y_ratio = MAX_SCALE;
            end
            
            y2 = obj.top_ylim_start - y_ratio*obj.y_range_axes_start;
            ylim_new1 = [y2 obj.top_ylim_start];
                        
            set(obj.clicked_ax,'ylim',ylim_new1);
            
        end
     	function processScaleBottomFixed(obj)
            MAX_SCALE = 5;
            
            cur_mouse_coords = get(obj.fig_h, 'CurrentPoint');
            y = cur_mouse_coords(2);
            if y <= obj.bottom_y_start
                %do nothing
                return
            end
            
            y_delta = y - obj.bottom_y_start;
            y_ratio  = obj.y_diff_fig_start/y_delta;
            if y_ratio > MAX_SCALE
                y_ratio = MAX_SCALE;
            end
            
            y2 = obj.bottom_ylim_start + y_ratio*obj.y_range_axes_start;
            ylim_new2 = [obj.bottom_ylim_start y2];
            
            set(obj.clicked_ax,'ylim',ylim_new2);
        end
    end
    
end
