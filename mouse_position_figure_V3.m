% in this implementation, you have to click specifically on the line for it
% to move. That way, we don't have to worry about where we click in the
% figure as we go. 
% downside is sometimes you miss the line a little bit and it doesn't work
% another downside is it can get lost at the top of the figure--need to
% limit motion to stay within bounds

function h = mouse_position_figure_V3
f = figure;
h = annotation('line',[0 1],[0.5 0.5],'Linewidth',2);
set(h,'Units','pixels');

set(h, 'ButtonDownFcn', @(~,~) lineClicked(h,f));
set(f,'WindowButtonUpFcn', @(~,~) mouseReleased(f));
end

function lineClicked(h,f)
set(f,'WindowButtonMotionFcn',@(~,~) moveLine(h,f));
end
function moveLine(h,f)
    temp = get(f, 'CurrentPoint');
    h.Position(2) = temp(2);
end
function mouseReleased(f)
set(f,'WindowButtonMotionFcn','');
end