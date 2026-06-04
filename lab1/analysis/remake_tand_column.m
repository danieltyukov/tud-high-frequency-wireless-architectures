% remake_tand_column.m — column-width version of fig_a2_tand for the
% IEEE two-column report (smaller canvas, same data from lab1_results.mat)
clear; close all;
here = fileparts(mfilename('fullpath'));
load(fullfile(here, 'results', 'lab1_results.mat'));
THz = 1e12;
f = A1(3).f;
col = lines(7);

fig = figure('Position', [100 100 430 330], 'Color', 'w');
hold on; box on; grid on;
for k = 1:numel(slab)
    fb = f(slab(k).band)/THz;
    plot(fb, movmean(slab(k).tand_f, 9), 'Color', col(k,:), 'LineWidth', 1.0, ...
        'DisplayName', sprintf('%s (%s)', slab(k).name, slab(k).mat));
end
set(gca, 'YScale', 'log', 'FontSize', 9);
ylim([1e-3 1]); xlim([0 3]);
xlabel('Frequency (THz)'); ylabel('tan\delta');
legend('Location', 'northeast', 'NumColumns', 2, 'FontSize', 7.2);
exportgraphics(fig, fullfile(here, 'figs', 'fig_a2_tand_col.pdf'), 'ContentType', 'vector');
exportgraphics(fig, fullfile(here, 'figs', 'fig_a2_tand_col.png'), 'Resolution', 220);
fprintf('written fig_a2_tand_col\n');
