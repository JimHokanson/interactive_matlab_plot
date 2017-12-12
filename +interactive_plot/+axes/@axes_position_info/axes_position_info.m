classdef axes_position_info < handle
    %
    %   Class:
    %   interactive_plot.axes.axes_position_info
    
    properties
        axes_handles
        n_axes
        n_lines
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
            obj.n_axes = length(obj.axes_handles);
            obj.n_lines = obj.n_axes + 1;
            
        end
        function [h_I,is_line] = getActiveAxes(obj,x,y)
            %
            %   Outputs:
            %   --------
            %   h_I :
            %   is_line : logical
            %       Whether or not the index refers to an axes or a line
            
            %Merged top/bottom positions of axes
            %13 14 15 => indices
            %0.3027    0.1929    0.1899 => observed values
            %
            %   0.2476 => observed mouse value
            %
            %   top - odd
            %   bottom - even index
            
            
            %axes
            %axes 1 top     1 (1 is index)
            %axes 1 bottom  2 (2 is index)
            %
            %line 1
            %
            %axes 2 top     3
            %axes 2 bottom  4
            
            I = find(obj.tops_and_bottoms < y,1);
            
            if mod(I,2) 
                %odd
                %- detected top of an axes
                %- mouse is between bottom of one axes and top of the next
                h_I = (I+1)/2;
                is_line = true;
                
                %fprintf('%d I:\n',I);

                
                %3 => line is #2, where #1 is the top line
            else
                %even - detected bottom of axes
                %- mouse is between top and bottom of an axes
                %- on a line
                h_I = (I/2);
                is_line = false;
                top_distance = obj.tops_and_bottoms(I-1) - y;
                bottom_distance = y - obj.tops_and_bottoms(I);
                
                p1 = get(obj.axes_handles{1},'Position');
                p2 = getpixelposition(obj.axes_handles{1});
                pixels_per_norm = p2(4)/p1(4);
                top_pixel_distance = top_distance * pixels_per_norm;
                bottom_pixel_distance = bottom_distance * pixels_per_norm;
                %fprintf('I: %d, top: %g, bottom %g \n',I,top_distance,bottom_distance)
                %fprintf('Top bottom: %g   %g  \n',top_pixel_distance,bottom_pixel_distance);
                %TODO: Improve this logic - if line is big enough we don't
                %need this ...
                if top_pixel_distance < 2
                    is_line = true;
                    %h_I doesn't change ...
                elseif bottom_pixel_distance < 2
                    is_line = true;
                    h_I = h_I + 1;
                end
                if is_line && (h_I == 1 || h_I == obj.n_lines)
                    is_line = false;
                end
                %The big issue is that h_I for lines can't be on the
                %borders ...
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

