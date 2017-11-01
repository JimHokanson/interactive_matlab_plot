classdef interactive_plot
    %
    %   Class:
    %   interactive_plot
    
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
    
    %{
    ax1 = subplot(2,1,1);
    plot(1:100,1:100);
    ax2 = subplot(2,1,2);
    plot(1:100,100:-1:1);
    
    %Yikes, this caused a resize of the axes :/
    h = imline(ax2,[-10 110], [95 95]);
    setColor(h,[0 0 0]);
    set(ax2,'xlim',[0 100]);
    
    
    'PositionConstraintFcn'
    
    
    
    %The line can't be grabbed at the very top :/
    %}
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    properties
        axes
    end
    
    methods
        function obj = interactive_plot(axes_handles)
            
        end
        function processButtonUp()
           %Adjust the axes accordingly ... 
        end
    end
    
end

%{
         UIContextMenu: [0×0 GraphicsPlaceholder]
         ButtonDownFcn: ''
            BusyAction: 'queue'
          BeingDeleted: 'off'
         Interruptible: 'on'
             CreateFcn: ''
             DeleteFcn: @imlineAPI/deleteContextMenu
                  Type: 'hggroup'
                   Tag: 'imline'
              UserData: []
              Selected: 'off'
    SelectionHighlight: 'on'
               HitTest: 'on'
         PickableParts: 'visible'
           DisplayName: ''
            Annotation: [1×1 matlab.graphics.eventdata.Annotation]
              Children: [4×1 Line]
                Parent: [1×1 Axes]
               Visible: 'on'
      HandleVisibility: 'on'

%}

