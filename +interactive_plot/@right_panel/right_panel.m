classdef right_panel < handle
    %
    %   Class:
    %   interactive_plot.right_panel_layout_manager
    %
    %   Right hand side:
    %   ---------------
    %   - last % value
    %   - name
    
    properties
        fig_handle
        options  %interactive_plot.options
        axes_handles
        channel_names
        name_text_handles
        default_name_heights_norm
        default_name_heights_pixel
    end
    
    methods
        function obj = right_panel(handles,options)
            %
            %   obj =
            %   interactive_plot.right_panel_layout_manager(fig_handle,axes_handles,options)
            
            obj.fig_handle = handles.fig_handle;
            obj.axes_handles = handles.axes_handles;
            obj.options = options;
            obj.initializeNames();
            
            n_axes = length(obj.axes_handles);
            for i = 1:n_axes
                ax = obj.axes_handles{i};
                addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(i));
            end
            for i = 1:n_axes
                obj.yLimChanged(i);
            end
        end
        function initializeNames(obj)
            n_axes = length(obj.axes_handles);
            axes_names = obj.options.axes_names;
            if isempty(axes_names)
                axes_names = cell(1,n_axes);
                axes_names(:) = {''};
            else
                %TODO: This could be made optional
                % - spaces replaced as well with newlines ...
                %names = regexprep(names,'_','\n');
            end
            
            obj.channel_names = axes_names;
            
            names_handles = cell(1,n_axes);
            h1 = zeros(1,n_axes);
            h2 = zeros(1,n_axes);
            for i = 1:n_axes            
                cur_string = axes_names{i};
                if ~isempty(cur_string)
                        %p = [0 0 0.1 0.1];
                    names_handles{i} = uicontrol(obj.fig_handle,'Style','text',...
                        'Units', 'normalized', ...
                        'String',axes_names{i},'FontSize',10,...
                        'HorizontalAlignment','left');
                    p1 = get(names_handles{i},'position');
                    p2 = getpixelposition(names_handles{i});
                    
                    h1(i) = p1(4);
                    h2(i) = p2(4);
                end
            end
            
            obj.default_name_heights_norm = h1;
            obj.default_name_heights_pixel = h2;
            obj.name_text_handles = names_handles;
        end
        function yLimChanged(obj,index)
            h__rerender(obj,index);
        end
    end
end

function h__rerender(obj,index)

h_axes = obj.axes_handles{index};
h_name = obj.name_text_handles{index};

name_height_norm = obj.default_name_heights_norm(index);
name_height_pixel = obj.default_name_heights_pixel(index);

%These should be linked ...
%For some reason the height is slightly off so we pad here
%Can't pad in height directly since we need bottom + height to not be
%at the top of the axes
name_padding_pixels = 10;
name_padding_norm = 0.005;

total_height = name_height_pixel + name_padding_pixels;

X_OFFSET = 5; %pixels
MIN_AXES_HEIGHT = total_height; %pixels

p = get(h_axes,'Position');
axes_right_edge = p(1)+p(3);
top = p(2)+p(4);

p_pixel = getpixelposition(h_axes);
axes_height_pixel = p_pixel(4);

norm_per_pixels_x = p(4)./axes_height_pixel;

if axes_height_pixel < MIN_AXES_HEIGHT
    bottom = top - 0.01;
    name_output_height = 0.0001;
    name_visible = 'off';
else
    bottom = top - name_height_norm - name_padding_norm;
    name_output_height = name_height_norm;
    name_visible = 'on';
end

x = axes_right_edge + X_OFFSET*norm_per_pixels_x;
                
width = 1 - x;

p2 = [x bottom width name_output_height];

set(h_name,'Position',p2,'Visible',name_visible);
end

