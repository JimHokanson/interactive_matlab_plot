function obj = standard1(varargin)
%
%   obj = interactive_plot.examples.standard1

f = figure;

N_PLOTS = 8;

n_points = 1000;
ax_ca = cell(1,N_PLOTS);
for i = 1:N_PLOTS
    ax_ca{i} = subplot(N_PLOTS,1,i);
    y = linspace(0,i,n_points);
    plot(round(y))
    set(gca,'ylim',[-4 4]);
end
axes_names = [];

obj = interactive_plot(f,ax_ca,varargin{:},'axes_names',axes_names);

end

