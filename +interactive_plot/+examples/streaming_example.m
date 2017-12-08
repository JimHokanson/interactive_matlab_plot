classdef streaming_example < handle
    %
    %   Class:
    %   interactive_plot.examples.streaming_example
    
    properties
        h_fig
        timer
        last_t = 0;
        
        dt = 1/1000
        xy1
        xy2
        ax
        ip
    end
    
    methods
        function obj = streaming_example()
            %
            %   interactive_plot.examples.streaming_example
            
            %plotting a bit faster than "real time"
            PERIOD = 0.1;
            N_SECONDS_KEEP = 100;
            
            obj.dt = 1/1000;
            n_samples_init = 1e6;
            obj.xy1 = big_plot.streaming_data(obj.dt,n_samples_init);
            obj.xy2 = big_plot.streaming_data(obj.dt,n_samples_init);
            
            obj.h_fig = figure;
            ax(1) = subplot(2,1,1);
            plotBig(obj.xy1)
            set(gca,'ylim',[-1.2 1.2])
            ax(2) = subplot(2,1,2);
            plotBig(obj.xy2)
            set(gca,'ylim',[-1.2 1.2])
            obj.ax = ax;
            obj.ip = interactive_plot(obj.h_fig,num2cell(ax),...
                'streaming',true,'streaming_window_size',N_SECONDS_KEEP);
            
            
            h_timer = timer;
            h_timer.Period = PERIOD;
            h_timer.ExecutionMode = 'fixedRate';
            h_timer.TimerFcn = @(~,~)obj.cb_timer;
            start(h_timer);
            obj.timer = h_timer;
        end
        function cb_timer(obj)
            if isvalid(obj.h_fig)
                try
                    start_t = obj.last_t + obj.dt;
                    t = start_t:obj.dt:(obj.last_t + 1);
                    obj.last_t = t(end);
                    
                    w1 = 2*pi*0.2;
                    w2 = 2*pi*0.02;
                    w3 = 2*pi*0.002;
                    y1 = sin(w1.*t).*sin(w2.*t).*sin(w3.*t);
                    
                    w = 2*pi*0.01;
                    f = 0.2*sin(w*t) + 0.25;
                    y2 = sin(f.*t);
                    
                    obj.xy1.addData(y1);
                    obj.xy2.addData(y2);
                    
                    obj.ip.dataAdded(obj.last_t);
                    
                catch ME
                    fprintf(2,'Caught error while running timer\n');
                    disp(ME)
                    ME.stack(1)
                    obj.killTimer();
                end
            end
        end
        function killTimer(obj)
            try %#ok<TRYNC>
                stop(obj.timer);
                delete(obj.timer);
            end
        end
        function delete(obj)
            obj.killTimer();
        end
    end
    
end

