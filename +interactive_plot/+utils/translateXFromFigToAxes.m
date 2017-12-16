function x_axes = translateXFromFigToAxes(h_axes,x_fig)
%
%   x_axes = interactive_plot.utils.translateXFromFigToAxes(h_axes,x_fig)

xlim = get(h_axes,'XLim');

p_axes = get(h_axes,'position');
            
x1 = p_axes(1);
x2 = p_axes(1)+p_axes(3);
y1 = xlim(1);
y2 = xlim(2);

m = (y2 - y1)./(x2 - x1);
b = y2 - m*x2;

x_axes = m*x_fig + b;  

end