classdef session < handle
    %
    %   Class:
    %   interactive_plot.session
    
    %Update the menu to allow:
    %1) Saving the settings, saving the session
    
    %Need autosave functionality ...
    
    properties
        settings  %interactive_plot.settings
        
        %Data that is specific to this session
        comments
        
        %NYI
        auto_save = false
        auto_save_path
    end
    
    %Constructor ==========================================================
    methods
        function obj = session(shared)
            %
            %   shared : interactive_plot.shared_props
            obj.settings = interactive_plot.settings(shared);
            
            if shared.options.comments
                obj.comments = interactive_plot.comments(shared);
            end
        end
        function load(obj,s)
            load(obj.settings,s.settings);
            if ~isempty(obj.comments)
                load(obj.comments,s.comments);
            end
        end
    end
    
    methods
        function save(obj,varargin)
            %
            %   NYI
            %
            in.file_path = '';
            in.save_data = false;
            in = interactive_plot.sl.in.processVarargin(in,varargin);
            
            
            %File path resolution
            %-----------------------
            %- file_path
            %- interactive_plot.settings
            %- default save location
            
            s = struct(obj);
        end
        function s = struct(obj)
            %
            %   Returns data to save as a structure
            s.VERSION = 1;
            s.type = 'interactive_plot.session';
            s.settings = struct(obj.settings);
            s.comments = struct(obj.comments);
        end
    end
    
    %Pass through methods =================================================
    methods
        function addComment(obj,time,str)
            if isempty(obj.comments)
                error('Unable to add a comment since comments are not enabled')
            end
            
            obj.comments.addComment(time,str)
        end
    end
    
end

