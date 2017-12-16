classdef top_panel < handle
    %
    %   Class:
    %   interactive_plot.top.top_panel
    
    properties
        top_for_axes
        fig_handle
        axes_handles
        streaming_enabled
        h_comment_string
        h_add_comment
        
        %Object Handles
        %--------------
        comments %interactive_plot.comments
        axes_action_manager
    end
    
    methods
        function obj = top_panel(shared)
            %
            %   obj = interactive_plot.top.top_panel(shared)
            
            %TODO: Place comments in here, if options calls for it
            
            obj.fig_handle = shared.handles.fig_handle;
            obj.axes_handles = shared.handles.axes_handles;
            if shared.options.comments
                obj.top_for_axes = 0.95;
                obj.h_comment_string = uicontrol(...
                    obj.fig_handle,'Style','edit','units','normalized',...
                    'position',[0.02 0.96 0.9 0.04],...
                    'String','','HorizontalAlignment','left');
                obj.h_add_comment = uicontrol(...
                    obj.fig_handle,'Style','pushbutton','units','normalized',...
                    'position',[0.93 0.96 0.06 0.04],...
                    'String','Add','Callback',@(~,~)obj.addComment());
                obj.comments = interactive_plot.comments(shared);
            else
                obj.top_for_axes = 1;
            end
        end
        function linkObjects(obj,axes_action_manager)
            obj.axes_action_manager = axes_action_manager; 
        end
        function addComment(obj)
            %Add at end if aam has no x_point selected
            x_clicked = obj.axes_action_manager.x_clicked;
            if isempty(x_clicked)
                xlim = get(obj.axes_handles{1},'XLim');
                x_clicked = xlim(2);
            end
                string_to_add = get(obj.h_comment_string,'String');
                obj.comments.addComment(x_clicked,string_to_add);
                set(obj.h_comment_string,'String','');
            
        end
    end
    
end

