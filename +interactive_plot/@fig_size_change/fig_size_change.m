classdef fig_size_change < handle
    %
    %   Class:
    %   interactive_plot.fig_size_change
    %
    %   JAH: This might not be necessary with xy_positions
    
    properties
        parent
        fig_handle
        right_panel
        left_panel
    end
    
    methods
        function obj = fig_size_change(parent)
            %
            %   obj = interactive_plot.fig_size_change(parent)
            
            obj.parent = parent;
            obj.fig_handle = parent.fig_handle;
            set(obj.fig_handle,'SizeChangedFcn',@(~,~)cb_figureSizeChanged(obj));
        end
        function linkObjects(obj,left_panel,right_panel)
            obj.right_panel = right_panel;
            obj.left_panel = left_panel;
        end
        function cb_figureSizeChanged(obj)
            %
            %   Things to change:
            %   - line widths - fixed pixel sizes
            %   - height of scroll bar
            %   - # of pixels on the side of each figure
            %       - this might also require updating the check ranges
            %       on the axis resizer ...
            %
            %   TODO ...
            
            obj.left_panel.figureSizeChanged();
            obj.right_panel.figureSizeChanged();
        end
    end
end

