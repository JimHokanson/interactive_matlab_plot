classdef unit_converter < handle
    %
    %   Class:
    %   interactive_plot.unit_converter
    %
    %   This class is meant to facilitate design of objects in pixel units
    %   while keeping the figure operation as normalized.
    
    properties
        fig_handle
        x_pixels_per_norm
        x_norm_per_pixels
        y_pixels_per_norm
        y_norm_per_pixels
    end
    
    methods
        function obj = unit_converter(fig_handle)
            %
            %   obj = interactive_plot.unit_converter(fig_handle)
            
            obj.fig_handle = fig_handle;
            obj.reinitialize()
        end
        function reinitialize(obj)
            %
            %
            %   For right now this should be called any time the figure
            %   size changes ...
            
            %Is this static - i.e. we only compute once?
            %Does this change if the screen resolution changes?
            
            
            
            %Not sure if there is another way of doing this ...
            set(obj.fig_handle,'Units','pixels');
            p1 = get(obj.fig_handle','Position');
            set(obj.fig_handle,'Units','normalized');
            p2 = get(obj.fig_handle,'Position');
            
            x_pixels = p1(3);
            y_pixels = p1(4);
            x_norm = p2(3);
            y_norm = p2(4);
            
            obj.x_pixels_per_norm = x_pixels/x_norm;
            obj.y_pixels_per_norm = y_pixels/y_norm;
            obj.x_norm_per_pixels = x_norm/x_pixels;
            obj.y_norm_per_pixels = y_norm/y_pixels;
        end
        function pixel_width = getFigureWidthInPixels(obj)
            %Wi
            temp = get(obj.fig_handle,'Position');
            norm_width = temp(3);
            pixel_width = obj.xNormToPixels(norm_width);
        end
        function getFigureHeightInPixels(obj)
            
        end
        function n_value = xPixelsToNorm(obj,p_value)
            n_value = p_value*obj.x_norm_per_pixels;
        end
        function p_value = xNormToPixels(obj,n_value)
            p_value = n_value*obj.x_pixels_per_norm;
            
        end
        function yPixelsToNorm(obj,value)
            
        end
        function yNormToPixels(obj,value)
            
        end
    end
    
end

