classdef y_tick_display < handle
    %
    %   Class:
    %   interactive_plot.left.y_tick_display
    %
    %   JAH TODO: Do we want ticks on the inside or outside????
    %       - presumably this should be an option
    %
    %   Handles placement of y-ticks on the axes
    
    properties
        axes_handles
        h_fig
        L1
        last_rendered_ylims
        n_axes
        n_draws = 0;
        last_ylim
        last_ax_position
    end
    
    methods
        function obj = y_tick_display(shared)
            axes_handles = shared.axes_handles;
            obj.h_fig = shared.fig_handle;
            obj.axes_handles = axes_handles;
            if numel(axes_handles) ~= length(axes_handles)
                error('Assumption violated')
            end
            n_axes = length(axes_handles);
            L1 = cell(1,n_axes);
            obj.last_ylim = cell(1,n_axes);
            obj.last_ax_position = cell(1,n_axes);
            %L2 = cell(1,length(axes_handles));
            
            obj.n_axes = n_axes;
            
            for i = 1:n_axes
                cur_axes = axes_handles{i};
                %We also need a listener on
                %TODO: This needs to use MarkedClean  
                %L1{i} = addlistener(cur_axes,'YLim','PostSet',@(src,ev)obj.drawYTicks(i,cur_axes));
                %L2{i} = addlistener(cur_axes,'SizeChanged',@(src,ev)obj.drawYTicks(i,cur_axes));
            	
                %obj.L3 = addlistener(axes_handle.XRuler,'MarkedClean',@(~,~) obj.cleanListen);

                L1{i} = addlistener(cur_axes.YRuler,'MarkedClean',@(~,~) obj.drawYTicks(i,cur_axes,false));
                
                %No exponents, things are too tight
                yruler = get(cur_axes,'YRuler');
                yruler.Exponent = 0;
                
                obj.drawYTicks(i,cur_axes,true);
            end
            obj.L1 = L1;
        end
        function redrawAll(obj)
            for i = 1:obj.n_axes
                h_axes = obj.axes_handles{i};
                obj.drawYTicks(i,h_axes,true);
            end
        end
        function drawYTicks(obj,axes_I,h_axes,force_redraw)
            %
            %
            %   JAH TODO: 
            %   - add comments to this function to break into parts
            
            BASE_OPTIONS = [1 2 5 10];
            PIXEL_BUFFER = 5; %pixels
            
            
            ylim = get(h_axes,'YLim');
            ypos = get(h_axes,'Position');
            
            if ~force_redraw && ...
                    (isequal(ylim,obj.last_ylim{axes_I}) && ...
                    isequal(ypos,obj.last_ax_position{axes_I}))
                return
            end
            
            obj.last_ylim{axes_I} = ylim;
            obj.last_ax_position{axes_I} = ypos;
            
            obj.n_draws = obj.n_draws + 1;
            
            temp = getpixelposition(h_axes);
            pixel_height = temp(4);
            %Vary the height based on pixels.
            %-------------------------------------
            if pixel_height < 100
                TEXT_SPACING = 20;
            elseif pixel_height < 200
                TEXT_SPACING = 25;
            elseif pixel_height < 300
                TEXT_SPACING = 35;
            else
                TEXT_SPACING = 45;
            end
            
            ylim = get(h_axes,'YLim');

            %# spacing
            
            
            y_range = ylim(2)-ylim(1);
            units_per_pixel = y_range/pixel_height;
            
            useable_pixel_space = pixel_height - PIXEL_BUFFER;
            if useable_pixel_space < 0
                %TODO: short circuit with something logical ...
                return
            end
                        
            %Ideal spacing of y_ticks
            ideal_units_spacing = TEXT_SPACING*units_per_pixel; %units

            %returns first non-zero digit as power of 1 (e.g. 100,10,1,0.1)
            log10_floor = floor(log10(ideal_units_spacing));
            base = 10^log10_floor;
            %4 options
            %   - base
            %   - 2*base
            %   - 5*base
            %   - 10*base
            
            %Converts into a value that is scaled appropriately ...
            options = base*BASE_OPTIONS;
            
            [~,best_option_I] = min(abs(options-ideal_units_spacing));
            
            y_tick_spacing = options(best_option_I);
            
            %??? Now, how do we decide where to place
            
            min_value = ylim(1)+PIXEL_BUFFER*units_per_pixel;
            max_value = ylim(2)-PIXEL_BUFFER*units_per_pixel;
            
            y_tick_start = ceil(min_value/y_tick_spacing)*y_tick_spacing;
            
            y_ticks = y_tick_start:y_tick_spacing:max_value;
            
%             if log10_floor < 0
%                 %format = ['%0.' sprintf('%d',abs(log10_floor)) 'f'];
%                 format = sprintf('%%0.%df',abs(log10_floor));
%             else
%                 format = '%g';
%             end
            
            %disp(format)
                
%             yruler = get(h_axes,'YRuler');
%             yruler.Exponent = 0;
%             yruler.TickLabelFormat = format;
            set(h_axes,'YTick',y_ticks);
            
        end
    end
end

