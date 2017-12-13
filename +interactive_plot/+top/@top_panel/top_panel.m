classdef top_panel
    %
    %   Class:
    %   interactive_plot.top.top_panel
    
    properties
        axes_handles
        streaming_enabled
        h_comment_string
        h_add_comment
        
        %Object Handles
        %--------------
        comments %interactive_plot.comments
        
    end
    
    methods
        function obj = top_panel(shared)
            %
            %   obj = interactive_plot.top.top_panel(shared)
            
            %TODO: Place comments in here, if options calls for it
            
            if shared.options.comments
                obj.comments = interactive_plot.comments();
            end
        end
    end
    
end

