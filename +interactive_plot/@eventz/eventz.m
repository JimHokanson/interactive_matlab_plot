classdef eventz < handle
    %
    %   Class:
    %   interative_plot.eventz
    %
    %   This class holds events that we can listen for.
    %
    %   Usage:
    %   addlistener(iplot.eventz,'session_updated',@my_callback)
    %
    %   Inputs to my_callback are:
    %   1) This class
    %   2) interactive_plot.event_data
    %       - see the property .value in the event_data class for the 
    %       real event data.
    %
    %   
    
    events
        calibration %Sent out whenever a calibration occurs
        figure_size_changed %Is this implemented????
        session_updated
    end
    
    properties
        fh
    end
    
    methods
        function obj = eventz(fh)
            obj.fh = fh;
        end
        function notify(obj,event_name,event_data)
            %
            %   Inputs
            %   ------
            %   event_name : string
            %       Must be one of the events in this class.
            %   event_data :
            %       Can be whatever, generally a structure ...
            
            %Call parent method
        	notify@handle(obj,event_name,interactive_plot.event_data(event_data));
        end
    end
    
end

