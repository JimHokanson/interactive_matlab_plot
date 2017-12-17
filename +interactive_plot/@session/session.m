classdef session < handle
    %
    %   Class:
    %   interactive_plot.session
    
    %Update the menu to allow:
    %1) Saving the settings, saving the session
    
    %Need autosave functionality ...
    
    
    %???? save data
    
    %Put session into shared ...
    
    
    properties
        settings  %interactive_plot.settings
        
        %Data that is specific to this session
        comments
    end
    
    methods
        function obj = session(shared)
            %
            %   shared : interactive_plot.shared_props
            obj.settings = interactive_plot.settings(shared);
            
            if shared.options.comments
                obj.comments = interactive_plot.comments(shared);
            end
        end
        function save(obj,varargin)
            in.file_path = '';
            in.save_data = false;
            in = interactive_plot.sl.in.processVarargin(in,varargin);
            
            
            %File path resolution
            %-----------------------
            %file_path
            %interactive_plot.settings
        end
    end
    
end

