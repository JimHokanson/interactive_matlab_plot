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
    
    methods
        function obj = eventz()
            
        end
        function notify(event_name,event_data)
        	notify(obj.eventz,event_name,interactive_plot.event_data(event_data));
        end
    end
    
end

