function h = mouse_position_figure_V2

%Next steps:
%-----------
%1) Enable moving on mouse down and disable on mouse up - move into a
%class that contains:
%- all known lines
%- all known axes
%- mouse state
%- callbacks
%2) Identify which line is selected on mouse click
%2.5) Build in boundaries on moving lines - might need to be updated
%   after building in support for moving lines
%3) Build in logic for pushing groups of lines
%4) Build in logic for resizing axes based on line positions


f = figure;
h = annotation('line',[0 1],[0.5 0.5],'Linewidth',2);
set(h,'Units','pixels');

set(f,'WindowButtonDownFcn', @(~,~) mouseClicked(h, f));
set(f,'WindowButtonUpFcn', @(~,~) mouseReleased(h,f));
%{
try 
    set(f,'WindowButtonMotionFcn',@(src,ev) moveLine(src,ev));
catch
        set(f,'WindowButtonMotionFcn',@(src,ev) moveLine(h,f));

end
%}
end

function moveLine(h,f)
    %p = h.Position;
    temp = get(f, 'CurrentPoint');
    h.Position(2) = temp(2);
    %disp(h.Position)
end
function mouseClicked(h, f)
disp('clicked')
set(f,'WindowButtonMotionFcn',@(~,~) moveLine(h,f));
end
function mouseReleased(h,f)
disp('released')
set(f,'WindowButtonMotionFcn','');
end
%{
      WindowButtonDownFcn: ''
    WindowButtonMotionFcn: ''
        WindowButtonUpFcn: ''
        WindowKeyPressFcn: ''
      WindowKeyReleaseFcn: ''
     WindowScrollWheelFcn: ''
%}


% 
% 
% 
% 
% 
% 
% 
% 
% 
% while(1)
%     pause(0.1);
% 
%     %This seems to only be accurate if the mouse is down
%     %It does update properly if the mouse is clicked and moving a line ...
%     c = get (gcf, 'CurrentPoint');
%     set(h,'y',[c(2) c(2)]);
% 
% end
% delete(h);
% 
% 
% end
% 
% function x = constrain(x,h_axes)
% %Format of x
% %   
% %   [x1  y1]
% %    x2  y2]
% xlim = get(h_axes,'xlim');
% ylim = get(h_axes,'ylim');
% 
% x(1:2) = xlim;
% %Keep this at the top
% x(3:4) = ylim(2);
% 
% end

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