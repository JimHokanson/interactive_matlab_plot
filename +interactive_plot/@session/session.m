classdef session < handle
    %
    %   Class:
    %   interactive_plot.session
    
    %Update the menu to allow:
    %1) Saving the settings, saving the session
    
    %Need autosave functionality ...
    
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
        function addComment(obj,time,str)
            if isempty(obj.comments)
                error('Unable to add a comment since comments are not enabled')
            end
            
            obj.comments.addComment(time,str)
        end
    end
    
end

