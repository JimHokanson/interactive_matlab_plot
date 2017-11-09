classdef line_moving_processor
    %
    %   Class:
    %   interactive_plot.line_moving_processor
    
    %{
    Design:
    - each plot gets 2 lines to move, except for the top and bottom
    - moving the lines moves placeholders (need to render lines on the figs
    at their locations)
    - releasing the line stops the movement and changes the axes
    - lines push, but don't pull
    
    Steps
    -----------------------------
    
    
    Line Behavior
    -----------------------------
    1) Axis resize:
 

    TODO:
    1)
    
    %}
    
    properties
        line_handles
    end
    
    methods
        function obj = line_moving_processor()
            %
            %   Setup lines here
        end
        function cb_innerLineMoved(obj)
            %Put code here
        end
        function cb_outerLineMoved(obj)
            %Use different logic for an outer line versus an inner line
            %
            %Don't allow outerline moving by dragging an inner line
            %
            %Focus on inner lines first
        end
    end
end

