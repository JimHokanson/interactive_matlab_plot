function mouse_position_figure
close all
%This is a brief test of moving a line as the mouse moves ...
    ax1 = subplot(2,1,1);
    plot(1:100,1:100);
    ax2 = subplot(2,1,2);
    plot(1:100,100:-1:1);
    
    %Yikes, this caused a resize of the axes :/
    h = imline(ax2,[-10 110], [95 95],'PositionConstraintFcn',@(x)constrain(x,ax2));
    setColor(h,[0 0 0]);
    set(ax2,'xlim',[0 100]);



%TODO: works on current figure, need to make sure this is accurate ...
h = annotation('line',[0 1],[0.5 0.5],'Linewidth',2);

WindowButtonMotionFcn







set(h,'Units','pixels');
while(1)
    pause(0.1);

    %This seems to only be accurate if the mouse is down
    %It does update properly if the mouse is clicked and moving a line ...
    c = get (gcf, 'CurrentPoint');
    set(h,'y',[c(2) c(2)]);

end
delete(h);


end

function x = constrain(x,h_axes)
%Format of x
%   
%   [x1  y1]
%    x2  y2]
xlim = get(h_axes,'xlim');
ylim = get(h_axes,'ylim');

x(1:2) = xlim;
%Keep this at the top
x(3:4) = ylim(2);

end

%              LineStyle: '-'
%              LineWidth: 2
%                      X: [0 1]
%                      Y: [0.5 0.5]
%                  Color: [0 0 0]
%               Position: [0 0.5 1 0]
%                  Units: 'normalized'
%               Children: [0×0 GraphicsPlaceholder]
%                 Parent: [1×1 AnnotationPane]
%                Visible: 'on'
%       HandleVisibility: 'on'
%          UIContextMenu: [0×0 GraphicsPlaceholder]
%          ButtonDownFcn: ''
%             BusyAction: 'queue'
%           BeingDeleted: 'off'
%          Interruptible: 'on'
%              CreateFcn: ''
%              DeleteFcn: ''
%                   Type: 'lineshape'
%                    Tag: ''
%               UserData: []
%               Selected: 'off'
%     SelectionHighlight: 'on'
%                HitTest: 'on'
%          PickableParts: 'visible'