function obj = standard2(varargin)
%
%   obj = interactive_plot.examples.standard2

f = figure;


n = 5e6;
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
axes_names = {'sin','cos','step'};

obj = interactive_plot(f,ax_ca,varargin{:},'axes_names',axes_names);

end

