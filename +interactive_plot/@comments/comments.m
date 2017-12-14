classdef comments < handle
    %
    %   Class:
    %   interactive_plot.comments
    
    properties
        axes_handles
        
        sorted_ids
        
        %Unsorted
        %--------------
        strings
        times
        id
    end
    
    methods
        function obj = comments(shared)
            obj.axes_handles = shared.handles.axes_handles;
        end
        function addComment(obj,time,str)
            
        end
    end
    
end

