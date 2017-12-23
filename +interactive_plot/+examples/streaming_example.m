classdef streaming_example < handle
    %
    %   Class:
    %   interactive_plot.examples.streaming_example
    %
    %   This example demonstrates how to "collect" and plot streaming
    %   data using interactive_plot.
    %
    %
    %   See Also
    %   --------
    %   big_plot.streaming_data
    
    properties
        h_fig
        timer
        last_t = 0;
        
        dt = 1/1000
        xy %cell of big_plot.streaming_data
        big %cell of big_plot
        ax
        ip
    end
    
    methods
        function obj = streaming_example(varargin)
            %
            %   interactive_plot.examples.streaming_example
            %
            %   Optional Inputs
            %   ---------------
            %   period : (default 0.1) (s)
            %       How often to plot data.
            %   streaming_window_size : (default 100)
            %   n_chans : (default 2)
            %       # of rows to plot
            
            
            %plotting a bit faster than "real time"
            %- currently adding 1 second every 0.1 s
            in.period = 0.1;
            in.streaming_window_size = 100;
            in.n_chans = 2;
            in = interactive_plot.sl.in.processVarargin(in,varargin);
            
            
            %Initialization of our streaming data
            %-------------------------------------
            obj.dt = 1/1000;
            n_samples_init = 1e6;
            
            n_chans = in.n_chans;
            
            temp = cell(1,n_chans);
            for i = 1:n_chans
                temp{i} = big_plot.streaming_data(obj.dt,n_samples_init);
            end
            obj.xy = temp;
            
            %Plotting the data
            %------------------
            obj.h_fig = figure;
            
            temp1 = cell(1,n_chans);
            temp2 = cell(1,n_chans);
            for i = 1:n_chans
               temp1{i} = subplot(n_chans,1,i);
               temp2{i} = plotBig(obj.xy{i},'obj',true);
               set(gca,'ylim',[-1.2 1.2])
            end
            
            obj.big = temp2;
            obj.ax = temp1;
            
            %Making the plot "interactive"
            obj.ip = interactive_plot(obj.h_fig,obj.ax,...
                'streaming',true,...
                'streaming_window_size',in.streaming_window_size,...
                'comments',true);
            
            %Initialization of our data generator
            %------------------------------------
            %- Conceptually this could come from a DAQ or other streaming
            %data source
            h_timer = timer;
            h_timer.Period = in.period;
            h_timer.ExecutionMode = 'fixedRate';
            h_timer.TimerFcn = @(~,~)obj.cb_timer;
            start(h_timer);
            obj.timer = h_timer;
        end
        function cb_timer(obj)
            if isvalid(obj.h_fig)
                try
                    start_t = obj.last_t + obj.dt;
                    %Add 1 second of data ...
                    %- Ideally this could be exposed to the user
                    t = start_t:obj.dt:(obj.last_t + 1);
                    obj.last_t = t(end);
                    
                    w1 = 2*pi*0.2;
                    w2 = 2*pi*0.02;
                    w3 = 2*pi*0.002;
                    y1 = sin(w1.*t).*sin(w2.*t).*sin(w3.*t);
                    
                    w = 2*pi*0.01;
                    f = 0.2*sin(w*t) + 0.25;
                    y2 = sin(f.*t);
                    
                    %These are the lines that are needed to make 
                    %streaming work ...
                    for i = 1:length(obj.xy)
                        if mod(i,2)
                            obj.xy{i}.addData(y1);
                        else
                            obj.xy{i}.addData(y2);
                        end
                    end
                    
                    obj.ip.dataAdded(obj.last_t);
                    %Note that this code is not explicitly calling drawnow
                    %...
                catch ME
                    fprintf(2,'Caught error while running timer\n');
                    disp(ME)
                    ME.stack(1)
                    obj.killTimer();
                end
            else
                obj.killTimer();
            end
        end
        function killTimer(obj)
            try %#ok<TRYNC>
                stop(obj.timer);
            end
            try %#ok<TRYNC>
                delete(obj.timer);
            end
        end
        function delete(obj)
            obj.killTimer();
        end
    end
    
end

