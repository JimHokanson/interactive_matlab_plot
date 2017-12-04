classdef interactive_plot < handle
    %
    %   Class:
    %   interactive_plot
    %
    %   Test Code:
    %   interactive_plot.runTest()
    %
    %   Changes/assumptions
    %   -------------------
    %   1) Figure units changed to normalized
    
    
    %Resizing Issues
    %---------------
    %1) Figure resize - need to redraw lines
    
    
    
    properties
        fig_handle
        axes_handles
        line_handles
        mouse_manager
        line_moving_processor
        axis_resizer    %interactive_plot.axis_resizer
        scroll_bar      %interactive_plot.scroll_bar
        fig_size_change  %interactive_plot.fig_size_change
        y_zoom_buttons  %interactive_plot.y_zoom_buttons
        streaming
        y_tick_display
        right_panel
        axes_action_manager
        xy_positions
        toolbar
        eventz
        
        options  %interactive_plot.options

        %TODO: These need to be removed ...
        %We need these for
        line_thickness = 0.003
        gap_thickness = 0.002
    end
    methods (Static)
        function obj = runTest(type,varargin)
            %
            %   interactive_plot.runTest(*type)
            
            %{
                interactive_plot.runTest(2)
            %}
            
            if nargin == 0
                type = 1;
            end
            
            f = figure;
            
            if type == 1
                N_PLOTS = 8;
                
                n_points = 1000;
                ax_ca = cell(1,N_PLOTS);
                for i = 1:N_PLOTS
                    ax_ca{i} = subplot(N_PLOTS,1,i);
                    y = linspace(0,i,n_points);
                    plot(round(y))
                    set(gca,'ylim',[-4 4]);
                end
            else
                n = 5e7;
                t = linspace(0,100,n);
                y = [(sin(0.10 * t) + 0.05 * randn(1, n))', ...
                    (cos(0.43 * t) + 0.001 * t .* randn(1, n))', ...
                    round(mod(t/10, 5))'];
                y(t > 40 & t < 50,:) = 0;                      % Drop a section of data.
                y(randi(numel(y), 1, 20)) = randn(1, 20);       % Emulate spikes.
                ax_ca = cell(1,3);
                for i = 1:3
                    ax_ca{i} = subplot(3,1,i);
                    plotBig(t,y(:,i));
                end
            end
            
            obj = interactive_plot(f,ax_ca,varargin{:});
        end
    end
    
    %Constructor
    %===========================================
    methods
        function obj = interactive_plot(fig_handle, axes, varargin)
            %
            %   obj = interactive_plot(fig_handle, axes, varargin)
            %
            %   Inputs
            %   ------
            %   fig_handle : handle
            %       Handle to the figure.
            %   axes : cell array {n_rows x n_cols}
            %       Cell array of the handles to all of the axes on the 
            %       plot. Currently the shape of the axes cell matters.
            %
            %   
            %   Optional Inputs
            %   ---------------
            %   update_on_drag : default true
            %       If true plots will be updated as scrolling happens.
            %   scroll : default true
            %       If true a scroll bar is included on the plot.
            %   lines : default true
            %       If true draggable lines are included
            %
            %
            %   Improvements
            %   ------------
            %   1) Support multiple columns
            %   2) Vertical and hortizontal scaling
            %   3) Adjust yticks to not be on the line ...
            %   4) Manual yticks with support for changing via buttons &
            %   mouse
            
            in = interactive_plot.options();
            obj.options = interactive_plot.sl.in.processVarargin(in,varargin);
            
            %JAH: Had remote desktop active
            %TODO: Verify proper renderer
            %Video card info incorrect
            %- opengl info
            
            %TODO: Verify correct setup of the axes handles since these 
            %come from the user, not internally ...
            
            obj.fig_handle = fig_handle;
            obj.axes_handles = axes;
            obj.linkXAxes();
            
            shape = size(obj.fig_handle.Children);
            rows = 1:shape(1);
            %cols = 1:shape(2); % for implementing multiple columns
            
            %Grab line handles
            %------------------------------
            temp = cell(size(obj.axes_handles));
            for i = 1:length(temp)
                temp2 = get(obj.axes_handles{i},'Children');
                %'matlab.graphics.chart.primitive.Line'
                %TODO: Filter out non-lines ...
                obj.line_handles{i} = temp2;
            end
            
            
            % need a gap size between the axes of a few pixels.
            % removeVerticalGap works in normalized units. need to find a
            % conversion factor.
            
            
            % figure out how to ste the gap size in normalized units when
            % given a desired gap size in pixels
            set(obj.fig_handle, 'Units','normalized');
            
            %JAH TODO: Specify top position of top fig and bottom position
            %of the bottom fig ...
            %{
            obj.sp = sl.plot.subplotter.fromFigure(obj.fig_handle, shape);
            obj.sp.removeVerticalGap(rows, cols,...
                'gap_size',obj.line_thickness);
            %}
            
            %Current limitation of the sotftware
            set(obj.fig_handle, 'Units', 'normalized');
            
            %Initial axes rendering
            %------------------------------------------------
            %TODO: Move to options ...
            TOP_POSITION = 0.98;
            BOTTOM_POSITION = 0.08;
                        
            obj.removeVerticalGap(rows,TOP_POSITION,BOTTOM_POSITION,'gap_size',obj.line_thickness);
            
            
            %Object construction
            %-------------------------------------------------
            obj.xy_positions = interactive_plot.xy_positions(obj.axes_handles);
            
            obj.eventz = interactive_plot.eventz();

            obj.line_moving_processor = ...
                interactive_plot.line_moving_processor(obj,obj.xy_positions,obj.options);

            %Left Panel
            %--------------------------------------------------------------
            obj.axis_resizer = interactive_plot.axis_resizer(obj);
            
            %Global
            %--------------------------------------------------------------
            obj.mouse_manager = interactive_plot.mouse_motion_callback_manager(...
                obj,obj.fig_handle,obj.axes_handles,obj.axis_resizer);
            
            
            
            %Bottom Panel
            %--------------------------------------------------------------
            obj.scroll_bar = interactive_plot.scroll_bar(obj,obj.fig_handle,...
                    obj.axes_handles,obj.options);
            
            
            
            
            
            %TODO: This order is getting messy ...
            %We need to have code that explicitly sets all these links ...
            
            
            obj.axes_action_manager = interactive_plot.axes_action_manager(...
                obj.fig_handle,obj.axes_handles,obj.line_handles, ...
                obj.xy_positions,obj.mouse_manager,obj.eventz);
            
            obj.fig_size_change = interactive_plot.fig_size_change(obj);
            
            obj.y_zoom_buttons = interactive_plot.y_zoom_buttons(obj);
            
            obj.streaming = interactive_plot.streaming(...
                obj.options,obj.axes_handles,obj.scroll_bar);
            obj.y_tick_display = interactive_plot.y_tick_display(obj.axes_handles);
            
            obj.right_panel = interactive_plot.right_panel_layout_manager(...
                obj.fig_handle,obj.axes_handles,obj.options);
            
            obj.toolbar = interactive_plot.toolbar(...
                obj.fig_handle,obj.axes_handles,obj.axes_action_manager);
            
            set(obj.fig_handle,'CloseRequestFcn', @(~,~) obj.cb_close);
        end
    end
    
    methods (Hidden)
        function linkXAxes(obj,varargin)
            %
            %
            % obj.linkXAxes
            % Links all of the x-axes
            % Optional Inputs:
            % ----------------
            %   'by_column': this is for later work when we allow multiple
            %   columns. Don't do this for now
            
            in.by_column = false;
            in = sl.in.processVarargin(in,varargin);
            
            h = obj.axes_handles;
            if in.by_column
                for i = 1:obj.n_columns
                    column_h = [h{:,i}];
                    linkaxes(column_h,'x');
                end
            else
                all_handles = [h{:}];
                linkaxes(all_handles,'x');
            end
            
        end
        function dataAdded(obj,new_max_time)
            %Temporary hack
            %Let's view 20 seconds for now ...
            if isvalid(obj.fig_handle)
                obj.streaming.changeMaxTime(new_max_time);
            end
        end
        function removeVerticalGap(obj,rows,top_input,bottom_input,varargin)
            %x Removes vertical gaps from subplots
            %
            %    removeVerticalGap(obj,rows,columns,varargin)
            %
            %    Code modified from Jim Hokanson Matlab Standard Library
            %      -- sl.plot.subplotter
            %
            %    TODO:
            %    -----------
            %    re-implement the code for multiple columns
            %    Remove dependency on standard library
            %
            %    Inputs:
            %    -------
            %    rows : array
            %        Must be more than 1, should be continuous, starts at
            %        the top
            %        The value -1 indicates that all rows should be
            %        compressed.
            %    columns :
            %        NYI!
            %
            %    Optional Inputs:
            %    ----------------
            %    gap_size: default 0.02
            %        The normalized figure space that should be placed
            %        between figures.
            %    remove_x_labels : logical (default true)
            %
            %   TODO: top_input and bottom_input are poor names
            
            in.gap_size = 0.02;
            
            %JAH: This could be exposed to the user
            in.keep_relative_size = true;
            
            %These will always be true (I think) - could be named as
            %constants at the top of the function (with upper casing)
            in.remove_x_labels = true;
            in.remove_x_ticks = true;
            in = sl.in.processVarargin(in,varargin);
            
            if rows == -1
                rows = 1:length(obj.axes_handles);
            end
            % currently only applies to the case for 1 column of data. We
            % would need to update this if we plan to support more columns
            all_axes = cellfun(@(x) sl.hg.axes(x),obj.axes_handles(rows),'un',0);
            all_axes = [all_axes{:}];
            
            all_heights = [all_axes.height];
            pct_all_heights = all_heights./sum(all_heights);
            
            for iRow = 1:length(rows)-1
                cur_row_I = rows(iRow);
                cur_ax = obj.axes_handles{cur_row_I};
                a = sl.hg.axes(cur_ax);
                a.clearLabel('x');
                a.clearTicks('x');
            end
            
%             %Assuming all columns are the same ...
%             top_axes    = all_axes(1);
%             bottom_axes = all_axes(end);
            
          	top_position = top_input;
            bottom_position = bottom_input;
            
%             top_position = top_axes.position.top;
%             bottom_position = bottom_axes.position.bottom;
            
            %TODO: This algorithm makes everything the same size. We need
            %to divy up based on the height
            
            if in.keep_relative_size
                total_height = top_position - bottom_position;
                gap_height   = (length(rows)-1)*in.gap_size;
                available_height = total_height - gap_height;
                new_heights = available_height*pct_all_heights;
                
                temp_start_heights = [0 cumsum(new_heights(1:end-1)+in.gap_size)];
                new_tops = top_position - temp_start_heights;
                new_bottoms = new_tops - new_heights;
            else
                %Add 1 due to edges
                %
                %        top     row 1   TOP OF TOP AXES
                %
                %        bottom  row 1  & top row 2
                %
                %        bottom  row 2  & top row 3
                %
                %        bottom  row 3   BOTTOM OF BOTTOM AXES
                %
                %    fill in so that each axes has the same height and so that
                %    all axes span from the top of the top axes to the bottom of
                %    the bottom axes
                temp = linspace(bottom_position,top_position,length(rows)+1);
                new_bottoms = temp(end-1:-1:1);
                new_tops = temp(end:-1:2);
            end
            
            for iRow = 1:length(rows)
                cur_row_I = rows(iRow);
                cur_new_top = new_tops(iRow);
                cur_new_bottom = new_bottoms(iRow);
                
                cur_ax = obj.axes_handles{cur_row_I};
                temp = get(cur_ax,'Position');
                %LBWH
                temp(2) = cur_new_bottom;
                temp(4) = cur_new_top-cur_new_bottom;
                set(cur_ax,'Position',temp);
                
                % TODO: removed code for multiple columns. Eventually
                % re-implement this
            end
            %TODO: Verify continuity of rows
            %TODO: Verify same axes if removing x labels ...
        end
        function cb_close(obj)
            delete(obj.scroll_bar.ax_listener);
            delete(obj.fig_handle);
        end
    end
end
