function [x,y] = getCurrentMousePoint(fig_handle,varargin)
%
%   [x,y] = interactive_plot.utils.getCurrentMousePoint(fig_handle,varargin)
%
%   Optional Inputs
%   ---------------
%   pixels : default false

%We currently assume that we are working with normalized units

in.pixels = false;
in = interactive_plot.sl.in.processVarargin(in,varargin);

cur_mouse_coords = get(fig_handle, 'CurrentPoint');
y = cur_mouse_coords(2);
x = cur_mouse_coords(1);
if in.pixels
    p = getpixelposition(fig_handle);
    y = p(4)*y;
    x = p(3)*x;
end

end