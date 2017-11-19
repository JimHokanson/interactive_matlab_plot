classdef axis_resizer < handle
    %
    %   Class:
    %   interactive_plot.axis_resizer
    
    %   On click - engage mouse move callbacks
    %   resize plot actively with movement
    %
    %   - center - pan
    %   - top - shrink or expand keeping bottom fixed
    %   - bottom - shrink or expand keeping bottom fixed
    %   
    
    properties
        parent %interactive.plot
        fig_h
        
        %For axis resizing
        axes_handles
        start_y_click_position %figure based, normalized 
        clicked_ax
        
        
        %TODO: Move to another class for pan
        top_y_start
        bottom_y_start
        ylim_start
        y_range
        m
        b
    end
    
    methods
        function obj = axis_resizer(parent)
             obj.parent = parent;
             obj.axes_handles = parent.axes_handles;
             obj.fig_h = parent.fig_handle;
             
%             obj.fig_h = fig_handle;
%             obj.ax = axes;
%             obj.y_position = y_position;
            
            %TODO: Register mouse moving to this class
        end
        function registerResizeCall(obj,y_position,type)
            %
            %   Inputs
            %   ------
            %   type :
            %       1 - up
            %       2 - down
            %       3 - pan
            
            obj.start_y_click_position = y_position;
            
            %TODO: This could be faster ...
            ax = obj.axes_handles;
            for i = 1:length(ax)
                cur_ax = ax{i};
                p = get(cur_ax,'Position');
                y_bottom = p(2);
                y_top = y_bottom + p(4);
                if y_position > y_bottom && y_position < y_top
                    obj.clicked_ax = cur_ax;
                    break;
                end
            end
            
            if type == 1
                obj.parent.mouse_manager.initializeUpScale();
            elseif type == 2
                obj.parent.mouse_manager.initializeDownScale();
            else
                obj.top_y_start = y_top;
                obj.bottom_y_start = y_bottom;
                ylim = get(cur_ax,'ylim');
                obj.y_range = ylim(2)-ylim(1);
                obj.ylim_start = ylim;
                
                %how much mouse movement to ylim movement?
                %y = m*x + b
                %ylim(2) = m*y_top + b
                %ylim(1) = m*y_bottom + b
                
                %As we move the mouse, we need to shift the 
                %current axes by a given amount ...
                
                obj.m = obj.y_range/(y_top - y_bottom);
                %obj.b = ylim(2) - obj.m*y_top;
                
                
                obj.parent.mouse_manager.initializeAxisPan();
            end
        end
        function processPan(obj)
            cur_mouse_coords = get(obj.fig_h, 'CurrentPoint');
            y = cur_mouse_coords(2);
            %x = cur_mouse_coords(1);
            
            y_delta = y - obj.start_y_click_position
            %ylim_new = zeros(1,2);
            %TODO: Just hold onto original ylim
            %ylim_new = obj.bottom_y_start - obj.m*y_delta;
            
            ylim_new = obj.ylim_start - obj.m*y_delta;
            set(obj.clicked_ax,'ylim',ylim_new);
        end
        function processUpScale(obj)
            
        end
     	function processDownScale(obj)
            
        end
    end
    
end

%{
set(hFig, 'Pointer', 'crosshair');

?arrow? (the default Matlab pointer), 
?crosshair?, 
?fullcrosshair? (used for ginput), 
?ibeam?, 
?watch?, 
?topl?, 
?topr?, 
    ?botl?, 
?botr?, 
?left?, 
?top?, 
?right?, 
?bottom?, 
?circle?, 
?cross?, 
?fleur?, and 
?custom?.
    
setptr(gcf, 'hand');
setptr(gcf, 'file', 'my137byteFile.data');
    
    Using setptr enables access to a far greater variety of pointer shapes, 
    in addition to all the standard shapes above: 
?hand?, 
?hand1?, 
?hand2?,
    ?closedhand?, 
?glass?, 
?glassplus?, 
?glassminus?, 
?lrdrag?, 
?ldrag?, 
    ?rdrag?, 
?uddrag?, 
?udrag?, 
?ddrag?, 
?add?, 
?addzero?, 
?addpole?, 
?eraser?, 
?help?, 
?modifiedfleur?, 
?datacursor?, and ?rotate?. 
    It also has a few entirely-undocumented shapes: ?forbidden?, and 
    ?file? (which expects a cursor data filepath as the following argument):
    
    https://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions


%}

%{
case 'rotate'
      cdata = [...
      NaN NaN NaN NaN NaN   2 NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN   2   1   2   1   1   1   1 NaN  NaN NaN NaN NaN
      NaN NaN NaN   2   1   1   1   2   2   2   2   1    1 NaN NaN NaN
      NaN NaN   2   1   1   1   1   2 NaN NaN NaN   2    2   1 NaN NaN
      NaN NaN   2   2   2   2   2 NaN NaN NaN NaN NaN  NaN   1 NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN   2 NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   1 NaN
      NaN NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   2 NaN
      NaN NaN   2 NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   1 NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   2 NaN
      NaN NaN NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN  NaN   1 NaN NaN
      NaN NaN NaN   2 NaN NaN NaN NaN NaN NaN NaN NaN  NaN   2 NaN NaN
      NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN   1  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN   2 NaN NaN   1 NaN NaN   2  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN   2 NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      ];
      hotspot = [8,8];
      mac_curs = 0;
    
    case 'help'
     d = ['000040006000707C78FE7CC67EC67F0C7F987C306C3046000630033003000000'...
          'C000E000F07CF8FEFDFFFFFFFFEFFFDEFFFCFFF8FE78EF78CF7887F807F80380'...
          '00010001']';
   case 'file'
       f=fopen(fname);
       d=fread(f);
       if length(d)~=137
           error(message('MATLAB:setptr:WrongLengthFile'))
       end
       d(length(d))=[];
   case 'forbidden'     
       d=['07C01FF03838703C607CC0E6C1C6C386C706CE067C0C781C38381FF007C00000'...
          '1FF03FF87FFCF87EF0FFE1FFE3EFE7CFEF8FFF0FFE1FFC3E7FFC3FF81FF00FE0'...
          '00070007']'; 

%}