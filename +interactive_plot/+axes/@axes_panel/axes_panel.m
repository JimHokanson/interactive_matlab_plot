classdef axes_panel < handle
    %
    %   Class:
    %   interactive_plot.axes_panel
    
    % - line-moving
    % - axes action manager
    
    properties
        shared
        axes_handles
        
        line_moving_processor
        axes_action_manager
        
        axes_props
        axes_position_info
    end
    
    methods
        function obj = axes_panel(shared)
            %
            %   obj = interactive_plot.axes_panel(shared)
            
            obj.axes_handles = shared.handles.axes_handles;
            obj.shared = shared;
            
            obj.removeVerticalGap();
            
            obj.axes_position_info = interactive_plot.axes.axes_position_info(obj.axes_handles);

          	obj.axes_action_manager = interactive_plot.axes.axes_action_manager(...
                shared,obj.axes_position_info);
            
        end
        function createLines(obj)
            obj.line_moving_processor = ...
                interactive_plot.axes.line_moving_processor(obj.shared,obj.axes_position_info);
            
            %Linking ... - needed to instantiate line moving
            %when over the lines +/- some buffer
            obj.axes_action_manager.line_moving_processor = ...
                obj.line_moving_processor;
        end
        function removeVerticalGap(obj)
            %x Removes vertical gaps from subplots
            
            rows = 1:length(obj.axes_handles);
            gap_size = obj.shared.render_params.line_thickness;
            
            
            % currently only applies to the case for 1 column of data. We
            % would need to update this if we plan to support more columns
            n_axes = length(obj.axes_handles);
            all_heights = zeros(1,n_axes);
            for i = 1:n_axes
                p = get(obj.axes_handles{i},'Position');
                all_heights(i) = p(4);
            end
            
            pct_all_heights = all_heights./sum(all_heights);
            
            for iRow = 1:length(rows)-1
                cur_row_I = rows(iRow);
                cur_ax = obj.axes_handles{cur_row_I};
                set(cur_ax,'XTick',[]);
                xlabel(cur_ax,'')
            end
            
            top_position = obj.shared.render_params.top_axes_top_position;
            %GHG TODO: this needs to be based on the outer position of the
            %axes so that the x-ticks are not covered
            bottom_position = obj.shared.render_params.bottom_axes_bottom_position;
            
            total_height = top_position - bottom_position;
            gap_height   = (length(rows)-1)*gap_size;
            available_height = total_height - gap_height;
            new_heights = available_height*pct_all_heights;
            
            temp_start_heights = [0 cumsum(new_heights(1:end-1)+gap_size)];
            new_tops = top_position - temp_start_heights;
            new_bottoms = new_tops - new_heights;
            
            
            for iRow = 1:length(rows)
                cur_row_I = rows(iRow);
                cur_new_top = new_tops(iRow);
                cur_new_bottom = new_bottoms(iRow);
                
                cur_ax = obj.axes_handles{cur_row_I};
                temp = get(cur_ax,'Position');
                %LBWH
                temp(2) = cur_new_bottom;
                temp(4) = cur_new_top-cur_new_bottom;
                set(cur_ax,'Position',temp);
                
                % TODO: removed code for multiple columns. Eventually
                % re-implement this
            end
        end
    end
    
end

