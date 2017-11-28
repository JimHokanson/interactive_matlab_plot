classdef ip_button < handle
    % interactive_plot.ip_button
    %
    % More convinient way to create the buttons on the figure
    %
    % TODO: change the name of this class?
    properties
       fig_handle 
       position %[x, y, w, h]
       text % what is dispalyed on the face of the button
      % type %String ('scroll', 'xzoom', 'yzoom')
       %change this to number system?
       button
       
    end
    methods
        function obj = ip_button(fig_handle, position, text)
            %   Inputs:
            %   ---------
            %   -parent: the parent class (scroll_bar, x_zoom, or y_zoom)
            %   -position: [x,y,w,h] double array
            %   -text: String to be displayed on the button
            %   NYI! -type: String dictating which type of button it is 
            %       ('scroll', 'xzoom', 'yzoom')
            
            obj.fig_handle = fig_handle;
            obj.position = position;
            obj.text = text;
            
           
           % TODO: this is bad formatting 
            obj.button = uicontrol(obj.fig_handle,...
                'Style', 'pushbutton', 'String', obj.text,...
                'units', 'normalized', 'Position',obj.position,...
                'Visible', 'on');
        end
        function setPosition(obj, position_vector)
            set(obj.button, 'Position', position_vector);
        end
    end
end