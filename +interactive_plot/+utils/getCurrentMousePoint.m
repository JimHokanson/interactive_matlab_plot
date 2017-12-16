function [x,y] = getCurrentMousePoint(fig_handle)
%
%   [x,y] = interactive_plot.utils.getCurrentMousePoint(fig_handle)
cur_mouse_coords = get(fig_handle, 'CurrentPoint');
y = cur_mouse_coords(2);
x = cur_mouse_coords(1);
end