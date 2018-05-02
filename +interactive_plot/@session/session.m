classdef session < handle
    %
    %   Class:
    %   interactive_plot.session
    %
    %   Holder of session data.
    %
    %   See Also
    %   --------
    %   interactive_plot.settings
    %   interactive_plot.comments
    
    %Update the menu to allow:
    %1) Saving the settings, saving the session
    
    %Need autosave functionality ...
    
    properties (Hidden)
        shared  %for creating comments after the fact ...
    end
    
    properties
        settings    %interactive_plot.settings
        
        %Data that is specific to this session
        comments    %interactive_plot.comments
        
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
            obj.shared = shared;
            
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
        function saveCalibrations(obj,varargin)
            %
            %   saveCalibrations(obj,varargin)
            %   
            %   Optional Inputs
            %   ---------------
            %   save_path : string (default 'prompt')
            %       If 'prompt' the user is prompted via GUI to select
            %       the save location.
            
           in.save_path = 'prompt';
           in = interactive_plot.sl.in.processVarargin(in,varargin);
           
           if strcmp(in.save_path,'prompt')
               save_path = uigetdir('','Choose a save directory');
               if isnumeric(save_path)
                   return
               end
           else
               error('Not yet implemented')
           end
           
           if ~exist(save_path,'dir')
               mkdir(save_path)
           end
           
           ax_props = obj.settings.axes_props;
           %Note this is a method call ...
           s = struct(ax_props);
           cals = s.calibrations;
           date_string = datestr(now,'yyyy_mm_dd__HH_MM_SS');
           for i = 1:length(cals)
              cur_cal = cals{i};
              if ~isempty(cur_cal)
                  %temp fix 
                 chan_name = cur_cal.chan_name;
                 chan_name = regexprep(chan_name,'\s','_');
                 cur_cal.chan_name = chan_name;
                 file_name = sprintf('%s__%s__ip_calibration.mat',cur_cal.chan_name,date_string);
                 file_path = fullfile(save_path,file_name);
                 save(file_path,'-struct','cur_cal');
              end
           end
        end
        function s = struct(obj)
            %
            %   Returns data to save as a structure
            %
            %   See Also
            %   --------
            %   interactive_plot>getSessionData
            
            s.VERSION = 1;
            s.type = 'interactive_plot.session';
            s.settings = struct(obj.settings);
            s.comments = struct(obj.comments);
        end
    end
    
    %Pass through methods =================================================
    methods
        function addComments(obj,times,strings)
            if isempty(obj.comments)
                obj.comments = interactive_plot.comments(obj.shared);
            end
            obj.comments.addComments(times,strings);
        end
        function addComment(obj,time,str)
            if isempty(obj.comments)
                obj.comments = interactive_plot.comments(obj.shared);
            end
            
            obj.comments.addComment(time,str)
        end
    end
    
end

