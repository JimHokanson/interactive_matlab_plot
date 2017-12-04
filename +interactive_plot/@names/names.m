classdef names
    %
    %   Class:
    %   interactive_plot.names
    
    properties
        fig_handle
        axes_handles
        channel_names
        names_handles
        extents
    end
    
    methods
        function obj = names(fig_handle,axes_handles,options)
            %
            %   obj = interactive_plot.names(fig_handle,axes_handles)
            obj.fig_handle = fig_handle;
            obj.axes_handles = axes_handles;
            n_axes = length(axes_handles);
            axes_names = options.axes_names;
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
            extents = cell(1,n_axes);
            for i = 1:length(axes_handles)
                ax = axes_handles{i};
            
                cur_string = axes_names{i};
                if ~isempty(cur_string)
                    %p = [0 0 0.1 0.1];
                    p = h__getPosition(ax);
                names_handles{i} = uicontrol(fig_handle,'Style','text',...
                    'Units', 'normalized', 'Position', p, ...
                    'String',axes_names{i},'FontSize',10);
                %h__getExtent(names_handles{i});
                addlistener(ax, 'Position', 'PostSet', @(~,~) obj.yLimChanged(k));
                
                end
            end
            
            obj.names_handles = names_handles;
        end
        function yLimChanged(obj,index)
            h_axes = obj.axes_handles{index};
            p = h__getPosition(h_axes);
            set(h_axes,'Position',p);
        end
    end
    
end

function x = h__getExtent(h_string)
%JAH: Working on this ...
x = [];
keyboard
end

function p2 = h__getPosition(h_axes)

%TODO: Incorporate extents

%Todo: Do the setting within here
%- Do 2 passes
%- set position
%- get extent
%- adjust position
%
%although we will know the extent, so 
MIN_AXES_HEIGHT = 20;

HEIGHT = 0.04;

p = get(h_axes,'Position');
axes_right_edge = p(1)+p(3);
top = p(2)+p(4);

p_pixel = getpixelposition(h_axes);

if p_pixel < MIN_AXES_HEIGHT
    height = 0;
else
    height = HEIGHT;
end

%TODO: Make this in terms of pixels ...
x = axes_right_edge + 0.001;
                
%JAH: This needs to be fixed, ideally we want a certain
%amount down from the top ...
y = top - 0.05;
                
width = 1 - x;

p2 = [x y height width];
end

%
