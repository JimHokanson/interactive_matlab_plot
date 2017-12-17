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
       textbox_margin = 2
    end
    properties
        fig_handle
        options  %interactive_plot.options
        axes_handles
        settings
        
        channel_names
        name_text_handles
        
        default_name_heights_norm
        default_name_heights_pixel
        
        y_display_handles
    end
    
    methods
        function obj = right_panel(shared)
            %
            %   obj =
            %   interactive_plot.right_panel_layout_manager(fig_handle,axes_handles,options)
            
            obj.settings = shared.session.settings;
            obj.fig_handle = shared.fig_handle;
            obj.axes_handles = shared.axes_handles;
            obj.options = shared.options;
            obj.initializeTextBoxes();
            %obj.initializeYDisplay();
            
            n_axes = length(obj.axes_handles);
            for i = 1:n_axes
                ax = obj.axes_handles{i};
                addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(i));
                %We also need to listen if the axes size changed ...
            end
            %addlistener(obj.fig_handle,'Position','PostSet',@(~,~)obj.figureSizeChanged());
           	%set(obj.fig_handle,'SizeChangedFcn',@(~,~)cb_figureSizeChanged(obj));

            obj.figureSizeChanged();
        end
        function initializeTextBoxes(obj)
            local_units = 'pixels';
            n_axes = length(obj.axes_handles);
            
            axes_names = obj.settings.axes_props.names;
           
            
            obj.channel_names = axes_names;
            
            names_handles = cell(1,n_axes);
            disp_handles = cell(1,n_axes);
            for i = 1:n_axes
                cur_string = axes_names{i};
                %p = [0 0 0.1 0.1];
                
                %p = [0 0 0.1 0.1];
                p = [0 0 0.003 0.03];
                bc = [0.9400    0.9400    0.9400];
                names_handles{i} = annotation(obj.fig_handle,'textbox',p,...
                    'Units', local_units, ...
                    'String',cur_string,'FontSize',8,...
                    'margin',obj.textbox_margin,'FitBoxToText','on',...
                    'EdgeColor','r',... %This is arbitrary and will likely change
                    'BackgroundColor',bc);
                
                disp_handles{i} = annotation(obj.fig_handle,'textbox',p,...
                    'Units', local_units, ...
                    'String','','FontSize',8,...
                    'margin',obj.textbox_margin,'FitBoxToText','on',...
                    'BackgroundColor',bc);
            end
            obj.name_text_handles = names_handles;
            obj.y_display_handles = disp_handles;
        end
        function figureSizeChanged(obj)
            n_axes = length(obj.axes_handles);
            for i = 1:n_axes
                obj.yLimChanged(i);
            end
        end
        function yLimChanged(obj,index)
            h__rerender(obj,index);
        end
    end
end

function h__rerender(obj,index)

h_axes = obj.axes_handles{index};
h_name = obj.name_text_handles{index};
h_disp = obj.y_display_handles{index};

p_name = get(h_name,'Position');
p_disp = get(h_disp,'Position');
p_axes = get(h_axes,'Position');
axes_right_edge = p_axes(1)+p_axes(3);
top = p_axes(2)+p_axes(4);

p_pixel = getpixelposition(h_axes);
axes_height_pixel = p_pixel(4);
axes_width_pixel = p_pixel(3);

% norm_per_pixels_x = p_axes(3)./axes_width_pixel;
% norm_per_pixels_y = p_axes(4)./axes_height_pixel;


x = p_pixel(1) + p_pixel(3) + 2;
top_pixel = p_pixel(2)+p_pixel(4);

bottom_name = top_pixel - p_name(4) - 1;
bottom_disp = bottom_name - p_disp(4)-2;

p_name_new = [x bottom_name p_name(3) p_name(4)];
set(h_name,'Position',p_name_new);
p_disp_new = [x bottom_disp p_disp(3) p_disp(4)];
set(h_disp,'Position',p_disp_new);



% % keyboard
% % 
% % margin_offset = obj.textbox_margin*norm_per_pixels_y;
% % 
% % norm_x_offset = 5*norm_per_pixels_x;
% % 
% % bottom_name = top - p_name(4) - margin_offset;
% % %For disp we remove bottom margin of name and top margin of disp
% % %as well as add 1 pixel for good measure
% % bottom_disp = bottom_name - p_disp(4) - 2*margin_offset - norm_per_pixels_y;
% % 
% % x = axes_right_edge + norm_x_offset;
% % p_name_new = [x bottom_name p_name(3) p_name(4)];
% % set(h_name,'Position',p_name_new);
% % p_disp_new = [x bottom_disp p_disp(3) p_disp(4)];
% % set(h_disp,'Position',p_disp_new);

%fprintf('Name: %s, Disp: %s\n',mat2str(p_name_new,3),mat2str(p_disp_new,3));
end



% function h__rerender(obj,index)
%
% h_axes = obj.axes_handles{index};
% h_name = obj.name_text_handles{index};
% h_disp = obj.y_display_handles{index};
%
% name_height_norm = obj.default_name_heights_norm(index);
% name_height_pixel = obj.default_name_heights_pixel(index);
%
% %These should be linked ...
% %For some reason the height is slightly off so we pad here
% %Can't pad in height directly since we need bottom + height to not be
% %at the top of the axes
% name_padding_pixels = 10;
% name_padding_norm = 0.005;
%
% total_height = 2*name_height_pixel + 2*name_padding_pixels;
%
% X_OFFSET = 5; %pixels
% MIN_AXES_HEIGHT = total_height; %pixels
%
% p = get(h_axes,'Position');
% axes_right_edge = p(1)+p(3);
% top = p(2)+p(4);
%
% p_pixel = getpixelposition(h_axes);
% axes_height_pixel = p_pixel(4);
% axes_width_pixel = p_pixel(3);
%
% norm_per_pixels_x = p(3)./axes_width_pixel;
%
% %-----------------------------------------------------
% %TODO: Make this staggered ...
% % if axes_height_pixel < MIN_AXES_HEIGHT
% %     name_bottom = top - 0.01;
% %     name_output_height = 0.0001;
% %     disp_output_height = 0.0001;
% %     name_visible = 'off';
% %     disp_bottom = top - 0.02;
% %     disp_visibile = 'off';
% % else
%     name_bottom = top - name_height_norm - name_padding_norm;
%     name_output_height = name_height_norm;
%     disp_output_height = name_height_norm;
%     name_visible = 'on';
%     disp_bottom = top - 2*(name_height_norm - name_padding_norm);
%     disp_visibile = 'on';
% % end
%
% x = axes_right_edge + X_OFFSET*norm_per_pixels_x;
%
% width = 1 - x;
%
% p2 = [x name_bottom width name_output_height];
%
% set(h_name,'Position',p2,'Visible',name_visible);
%
% p2 = [x disp_bottom width disp_output_height];
% set(h_disp,'Position',p2,'Visible',disp_visibile);
% end

