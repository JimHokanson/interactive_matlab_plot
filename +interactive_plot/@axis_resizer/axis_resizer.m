classdef axis_resizer
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
        start_y_position %figure based, normalized 
        
    end
    
    methods
        function obj = axis_resizer(parent)
             obj.parent = parent;
             obj.axes_handles = parent.axes_handles;
             
%             obj.fig_h = fig_handle;
%             obj.ax = axes;
%             obj.y_position = y_position;
            
            %TODO: Register mouse moving to this class
        end
        function registerResizeCall(obj,y_position)
            %- called from defaul motion callback
            %TODO: Log position
            %disp(y_position);
            
            obj.parent.mouse_manager.initializeAxisResize();
        end
        function processResize(obj)
            
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