classdef right_panel_layout_manager
    %
    %   Class:
    %   interactive_plot.right_panel_layout_manager
    %
    %   Right hand side:
    %   ---------------
    %   - last % value
    %   - name
    
    %   JAH: I might rename this class ... right_panel?????
    
    properties
        fig_handle
        options  %interactive_plot.options
        axes_handles
        names_handles
    end
    
    methods
        function obj = right_panel_layout_manager(fig_handle,axes_handles,options)
            %
            %   obj =
            %   interactive_plot.right_panel_layout_manager(fig_handle,axes_handles,options)
            
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
            names_handles = cell(1,n_axes);
            for i = 1:length(axes_handles)
                ax = axes_handles{i};
                axes_right_edge = ax.Position(1) + ax.Position(3);
                top = ax.Position(2) + ax.Position(4);
                
                x = axes_right_edge + 0.005;
                
                %JAH: This needs to be fixed, ideally we want a certain
                %amount down from the top ...
                y = top - 0.05;
                
                names_handles{i} = uicontrol(fig_handle,'Style','text',...
                    'Units', 'normalized', 'Position', [x y 0.06 0.04], ...
                    'String',axes_names{i},'FontSize',10);
            end
            
            obj.names_handles = names_handles;
        end
    end
end

