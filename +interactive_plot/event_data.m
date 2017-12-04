classdef (ConstructOnLoad) event_data < event.EventData
    %
    %   ??? Why ??? - apparently so that you know what the original value
    %   was ...
    %
    %   https://www.mathworks.com/help/matlab/matlab_oop/class-with-custom-event-data.html
    %
    %   Class:
    %   interactive_plot.event_data
    
   properties
      value
   end
   
   methods
      function obj = event_data(value)
         obj.value = value;
      end
   end
end