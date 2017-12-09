classdef axes_position_info < handle
    %
    %   Class:
    %   interactive_plot.axes.axes_position_info
    
    properties
        axes_handles
        
        %These are assumed to be ordered from top to bottom
        top_axes_boundary
        bottom_axes_boundary
        axes_tops
        axes_bottoms
        
        %top1
        %bottom1
        %top2
        %bottom2
        %top3
        %bottom3
        
        left_axes_edge
        right_axes_edge
    end
    
    properties
        tops_and_bottoms
    end
    
    methods
        function obj = axes_position_info(axes_handles)
            %
            %   obj = interactive_plot.axes.axes_position_info(axes_handles)
            
            obj.axes_handles = axes_handles;
            obj.logAxesPositions();
            
        end
        function [h_I,is_line] = getActiveAxes(obj,x,y)
            %NYI
            
            %13 14 15
            %0.3027    0.1929    0.1899
            %
            %   0.2476
            
            
            %axes
            %axes 1 top     1
            %axes 1 bottom  2
            %
            %line 1
            %
            %axes 2 top     3
            %axes 2 bottom  4
            
            I = find(obj.tops_and_bottoms < y,1);
            
            %odd
            if mod(I,2) 
                %even
                %- on an axes
                h_I = (I+1)/2;
                is_line = false;
            else
                %even
                %- on a line
                h_I = (I/2);
                is_line = true;
            end
        end
        function logAxesPositions(obj)
            n_axes = length(obj.axes_handles);
            tops = zeros(1,n_axes);
            bottoms = zeros(1,n_axes);
            for i = 1:n_axes
                cur_axes = obj.axes_handles{i};
                p = cur_axes.Position;
                tops(i) = p(2) + p(4);
                bottoms(i) = p(2);
            end
            
            obj.axes_tops = tops;
            obj.axes_bottoms = bottoms;
            h__logTopBottomOrdered(obj);
            obj.left_axes_edge = p(1);
            obj.right_axes_edge = p(1)+p(3);
        end
       	function updateAxesTopAndBottoms(obj,tops,bottoms)
            n_axes = length(obj.axes_handles);
            for i = 1:n_axes
                cur_axes = obj.axes_handles{i};
                %Update bottom and height simultaneously
                p = cur_axes.Position;
                p(2) = bottoms(i);
                p(4) = tops(i)-bottoms(i);
                cur_axes.Position = p;
            end
            
            obj.axes_tops = tops;
            obj.axes_bottoms = bottoms;
            h__logTopBottomOrdered(obj);
            obj.left_axes_edge = p(1);
            obj.right_axes_edge = p(1)+p(3);
        end
    end
    
end

function h__logTopBottomOrdered(obj)
%tops_and_bottoms
tops = obj.axes_tops;
bottoms = obj.axes_bottoms;
n_values = 2*length(tops);
temp = zeros(1,n_values);
temp(1:2:end) = tops;
temp(2:2:end) = bottoms;
obj.tops_and_bottoms = temp;

end

