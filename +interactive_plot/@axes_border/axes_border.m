classdef axes_border < handle
    %
    %   Class:
    %   interactive_plot.axes_border
    %
    %       JAH: I think this is old and can be deleted ...
    
    properties
        parent
        id
    end
    
    methods
        function obj = axes_border(parent,h_axes,id)
            %
            %   TODO: Draw the line
            %   Callback on axes
            
            %Create a line for the plot, hide it
            %unhide on moving ...
        end
    end
    
end

function x = constrain(x,h_axes)

%On moving, 


%Format of x
%   
%   [x1  y1]
%    x2  y2]
xlim = get(h_axes,'xlim');
ylim = get(h_axes,'ylim');

x(1:2) = xlim;
%Keep this at the top
x(3:4) = ylim(2);

end