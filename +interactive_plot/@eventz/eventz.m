classdef eventz < handle
    %
    %   Class:
    %   interative_plot.eventz
    %
    %   This class holds events that we can listen for.
    %
    %
    
    events
        calibration %Sent out whenever a calibration occurs
        figure_size_changed
    end
    
    properties
        fh
    end
    
    methods
        function obj = eventz(fh)
            obj.fh = fh;
        end
        function notify(obj,event_name,event_data)
            %builtin('notify',obj,event_name,interactive_plot.event_data(event_data));
            %obj.fh(obj,event_name,interactive_plot.event_data(event_data));
        	notify@handle(obj,event_name,interactive_plot.event_data(event_data));
        end
    end
    
end

