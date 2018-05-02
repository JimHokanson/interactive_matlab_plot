function initialize(obj,shared,fig_handle,axes_handles)

shared.render_params = interactive_plot.render_params;
shared.fig_handle = fig_handle;
obj.fig_handle = fig_handle;

%Current limitation of the software
set(fig_handle,'Units','normalized');
set(fig_handle,'CloseRequestFcn', @(~,~) obj.cb_close);

%TODO: Verify correct setup of the axes handles since these
%come from the user, not internally ...
shared.axes_handles = axes_handles;
shared.handles = interactive_plot.handles(fig_handle,axes_handles);

all_axes = [axes_handles{:}];
linkaxes(all_axes,'x');

%Non-rendered components
%--------------------------------------------------------------
shared.mouse_manager = interactive_plot.mouse_manager(shared.handles);
shared.eventz = interactive_plot.eventz(@notify);
shared.session = interactive_plot.session(shared);
obj.session = shared.session;
obj.eventz = shared.eventz;

%Top Components
%--------------------------------------------------------------
shared.toolbar = interactive_plot.toolbar(shared);

obj.top_panel = interactive_plot.top.top_panel(shared);
%refresh(fig_handle)
%These make the whole process feel much more snappy
drawnow('nocallbacks')

%Center
obj.axes_panel = interactive_plot.axes.axes_panel(...
    shared,obj.top_panel.top_for_axes);
%refresh(fig_handle)
drawnow('nocallbacks')

%Left
obj.left_panel = interactive_plot.left.left_panel(shared);
%refresh(fig_handle)
drawnow('nocallbacks')

%Right
obj.right_panel = interactive_plot.right.right_panel(shared);
%refresh(fig_handle)
drawnow('nocallbacks')

%We do this later so that the lines draw over the text objects
%...
obj.axes_panel.createLines();
%refresh(fig_handle)
drawnow('nocallbacks')

%Bottom
obj.bottom_panel = interactive_plot.bottom.bottom_panel(...
    shared);
%refresh(fig_handle)
drawnow('nocallbacks')

obj.streaming = interactive_plot.streaming(...
    shared,obj.bottom_panel);

obj.menu = interactive_plot.fig_menu(shared);


%Some final parts ...
%------------------------
obj.fig_size_change = interactive_plot.fig_size_change(obj);
fsc = obj.fig_size_change;
fsc.linkObjects(obj.left_panel,obj.right_panel);

shared.toolbar.linkComponents(...
    obj.axes_panel.axes_action_manager,...
    obj.left_panel,...
    obj.axes_panel)
shared.mouse_manager.linkObjects(...
    obj.axes_panel.axes_action_manager,...
    obj.left_panel.y_axis_resizer);
obj.top_panel.linkObjects(...
    obj.axes_panel.axes_action_manager);
obj.left_panel.y_axis_options.linkObjects(...
    obj.axes_panel.axes_action_manager);
shared.mouse_manager.updateAxesLimits();
obj.bottom_panel.linkObjects(obj.right_panel);

%Link right hand text display to the axes manager
obj.axes_panel.axes_action_manager.linkObjects(obj.right_panel,obj.bottom_panel);

end