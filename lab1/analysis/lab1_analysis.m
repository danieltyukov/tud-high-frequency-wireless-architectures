%% lab1_analysis.m — EE4730 Time-Domain Lab (Lab 1) processing pipeline
% Daniel Tyukov (5714699) — TU Delft Microelectronics
%
% Assignment 1: waveform-averaging / SNR study of the aligned THz path.
% Assignment 2: dielectric-slab characterization (eps_r, tan d, dB/lambda)
% using the transmission-line extraction of Processing_TimeDomain_2026.pdf:
%   eps_r  = (c0*(tau_dif + tau_0)/d)^2          (peak time delay)
%   |H(f)| fitted with the slab transmission-line model -> tan d(f)
%
% Raw measurement files are read-only; all outputs go to figs/ and results/.

clear; close all; clc;

c0   = 299792458;            % m/s
eta0 = 376.730313668;        % Ohm
THz  = 1e12;

here   = fileparts(mfilename('fullpath'));
dataA1 = fullfile(here, '..', 'Assignment Data', 'Assignment1');
dataA2 = fullfile(here, '..', 'Assignment Data', 'Assignment2');
figdir = fullfile(here, 'figs');
resdir = fullfile(here, 'results');
if ~exist(figdir,'dir'), mkdir(figdir); end
if ~exist(resdir,'dir'), mkdir(resdir); end

set(groot,'defaultAxesFontSize',10, 'defaultLineLineWidth',1.1, ...
    'defaultAxesXGrid','on', 'defaultAxesYGrid','on', ...
    'defaultFigureColor','w', 'defaultAxesBox','on');
col = lines(7);

%% ------------------------------------------------------------------------
%  ASSIGNMENT 1 — averaging vs SNR
%  ------------------------------------------------------------------------
A1 = struct('name', {'calibration','50sampling','100sampling','1000sampling'}, ...
            'N',    {1, 50, 100, 1000}, ...
            'winApplied', {false, true, true, false});  % Tukey baked into file?

fprintf('=== Assignment 1: traces ===\n');
for k = 1:numel(A1)
    [t_ps, y] = read_td(fullfile(dataA1, ['Assignment1_' A1(k).name '.txt']));
    t_ps = t_ps + 327;                       % bring time axis to zero
    A1(k).t = t_ps;  A1(k).y = y;
    % windows must be identical for a fair spectral comparison: apply
    % Tukey(0.1) here only to the traces ScanControl saved unwindowed
    if A1(k).winApplied
        yw = y;
    else
        yw = y .* tukeywin_local(numel(y), 0.1);
    end
    [f, S] = spec(t_ps, yw);
    A1(k).f = f;  A1(k).S = S;
    dB = 20*log10(abs(S));
    A1(k).dB = dB;
    A1(k).floor = median(dB(f > 8*THz & f < 14*THz));
    A1(k).pk_dB = max(dB(f < 5*THz));
    A1(k).DR    = A1(k).pk_dB - A1(k).floor;
    % time-domain noise in a pre-pulse window clear of the Tukey taper and
    % of the coherent baseline structure near 27 ps
    nz = y(t_ps > 8 & t_ps < 25);
    A1(k).sigma = std(nz);
    A1(k).pk_t  = max(abs(y));
    A1(k).SNRt  = 20*log10(A1(k).pk_t / A1(k).sigma);
    fprintf('  N=%4d: peak=%.3f a.u., sigma=%.2e, SNR_t=%.1f dB, floor=%.1f dB, DR=%.1f dB\n', ...
        A1(k).N, A1(k).pk_t, A1(k).sigma, A1(k).SNRt, A1(k).floor, A1(k).DR);
end

% --- validate own FFT pipeline against the two ScanControl FFT exports
fprintf('\n=== FFT pipeline validation vs ScanControl ===\n');
valid = {'50sampling','100sampling'};
fig = figure('Position',[100 100 760 300]);
tl = tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
for k = 1:2
    [fm_THz, dBm] = read_td(fullfile(dataA1, ['Assignment1_' valid{k} '_fft.txt']));
    j = find(strcmp({A1.name}, valid{k}));
    fi = A1(j).f/THz;  dBi = A1(j).dB;
    dBmi = interp1(fm_THz, dBm, fi, 'linear', NaN);
    m = fi > 0.1 & fi < 2 & ~isnan(dBmi);
    offs = median(dBi(m) - dBmi(m));
    rmsd = rms(dBi(m) - dBmi(m) - offs);
    fprintf('  %s: offset %.2f dB, rms deviation %.3f dB (0.1-2 THz)\n', valid{k}, offs, rmsd);
    nexttile; hold on;
    plot(fm_THz, dBm + offs, 'Color', col(1,:), 'DisplayName','ScanControl (+offset)');
    plot(fi, dBi, '--', 'Color', col(2,:), 'DisplayName','this pipeline');
    xlim([0 4]); xlabel('Frequency (THz)'); ylabel('Amplitude (dB)');
    title(sprintf('N = %s, rms dev. %.2f dB', extractBefore(valid{k},'sampling'), rmsd));
    legend('Location','northeast');
end
savefig_both(fig, figdir, 'fig_fft_validation');

% --- export the two missing FFTs (computed, clearly marked as such)
for nm = {'calibration','1000sampling'}
    j = find(strcmp({A1.name}, nm{1}));
    fid = fopen(fullfile(resdir, ['Assignment1_' nm{1} '_fft_computed.txt']), 'w');
    fprintf(fid, '# COMPUTED by lab1_analysis.m (not an instrument capture)\n');
    fprintf(fid, '# FFT of Assignment1_%s.txt, Tukey alpha=0.1, Nfft=4096\n', nm{1});
    fprintf(fid, '# Frequency [THz]\tTHz Signal [dB]\n');
    fprintf(fid, '%.8f\t%.8f\n', [A1(j).f.'/THz; A1(j).dB.']);
    fclose(fid);
end

% --- A1 figure: time traces + noise zoom
fig = figure('Position',[100 100 760 300]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; hold on;
for k = 1:numel(A1)
    plot(A1(k).t, A1(k).y, 'Color', col(k,:), 'DisplayName', sprintf('N = %d', A1(k).N));
end
xlim([38 56]); xlabel('Time (ps)'); ylabel('THz signal (a.u.)');
title('(a) Pulse after alignment'); legend('Location','southeast');
nexttile; hold on;
for k = 1:numel(A1)
    plot(A1(k).t, A1(k).y, 'Color', col(k,:), 'DisplayName', sprintf('N = %d', A1(k).N));
end
xlim([10 30]); ylim([-4e-3 4e-3]); xlabel('Time (ps)'); ylabel('THz signal (a.u.)');
title('(b) Pre-pulse noise'); legend('Location','southeast');
savefig_both(fig, figdir, 'fig_a1_time');

% --- A1 figure: spectra with noise floors + DR vs N
fig = figure('Position',[100 100 860 300]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile([1 1]); hold on;
for k = 1:numel(A1)
    plot(A1(k).f/THz, A1(k).dB, 'Color', col(k,:), 'DisplayName', sprintf('N = %d', A1(k).N));
end
for k = 1:numel(A1)
    plot([7 14], A1(k).floor*[1 1], 'k:', 'HandleVisibility','off', 'LineWidth', 1.4);
end
xlim([0 14]); ylim([-80 5]);
xlabel('Frequency (THz)'); ylabel('Amplitude (dB)');
title('(a) Amplitude spectra and noise floors');
legend('Location','northeast');
nexttile; hold on;
plot([A1.N], [A1.DR], 'o-', 'Color', col(1,:), 'MarkerFaceColor', col(1,:), ...
    'DisplayName','measured');
Nax = logspace(0, 3.1, 20);
plot(Nax, A1(1).DR + 10*log10(Nax), '--', 'Color', [.4 .4 .4], ...
    'DisplayName','DR_1 + 10log_{10}N');
set(gca,'XScale','log');
xlabel('Number of averages N'); ylabel('Dynamic range (dB)');
title('(b) Dynamic range vs averaging');
legend('Location','southeast');
savefig_both(fig, figdir, 'fig_a1_spectra');

%% ------------------------------------------------------------------------
%  ASSIGNMENT 2 — slab characterization
%  ------------------------------------------------------------------------
% reference: the 100-average trace (same averaging + window as slab scans)
jref = find(strcmp({A1.name},'100sampling'));
tref = A1(jref).t;  yref = A1(jref).y;
fref = A1(jref).f;  Sref = A1(jref).S;
dBref = A1(jref).dB;  floor_ref = A1(jref).floor;
tau_ref = peaktime(tref, yref);
fprintf('\n=== Assignment 2: reference pulse (N=100) peak at %.3f ps ===\n', tau_ref);

mat_names = {'Silicon','GaAs','HDPE','Teflon','Gore-Tex','Polyamide','Ceramic'};
mat_eps   = [11.90 12.40 2.30 2.10 1.35 3.40 7.55];

slab = struct( ...
  'file',  {'Slab1_7.5','Slab2_0.8','Slab3_4.8','Slab4_525u','Slab5_525u','Slab6_2.04'}, ...
  'd',     {7.5e-3, NaN, 4.8e-3, 525e-6, 525e-6, 2.04e-3}, ...   % slab 2 resolved below
  'name',  {'Slab 1','Slab 2','Slab 3','Slab 4','Slab 5','Slab 6'});

% load all slabs, peak delays
for k = 1:numel(slab)
    [t_ps, y] = read_td(fullfile(dataA2, [slab(k).file '.txt']));
    t_ps = t_ps + 327;
    slab(k).t = t_ps;  slab(k).y = y;
    [f, S] = spec(t_ps, y);          % window already applied by ScanControl
    slab(k).f = f;  slab(k).S = S;
    slab(k).dB = 20*log10(abs(S));
    slab(k).floor = median(slab(k).dB(f > 8*THz & f < 14*THz));
    slab(k).tau = peaktime(t_ps, y) - tau_ref;   % ps
end

%% --- Slab 2: resolve the 0.8 mm vs 3.08 mm thickness conflict from the data
% For a candidate thickness d, the delay fixes n(d) = 1 + c*tau/d; only the
% true d also reproduces (i) the Fabry-Perot ripple in |H(f)| and (ii) the
% arrival time of the first internal echo, t_echo = 2(d + c*tau)/c.
k2 = 2;
H2 = slab(k2).S ./ Sref;
band2 = pick_band(fref, slab(k2).dB, slab(k2).floor, dBref, floor_ref) ...
        & fref < 1.5*THz;                       % high-SNR part only
H2s = movmean(abs(H2), 5);                      % suppress water-vapour spikes
dgrid = (0.3:0.01:4.5)*1e-3;
cost_d = zeros(size(dgrid));
for i = 1:numel(dgrid)
    n_i = 1 + c0*slab(k2).tau*1e-12/dgrid(i);
    cost_d(i) = fit_tand_cost(fref(band2), H2s(band2), dgrid(i), n_i^2);
end
[~, imin] = min(cost_d);
d2_best = dgrid(imin);
[~, i08]  = min(abs(dgrid - 0.8e-3));
[~, i308] = min(abs(dgrid - 3.08e-3));
fprintf('\n=== Slab 2 thickness scan (candidates 0.80 / 3.08 mm) ===\n');
fprintf('    best d = %.2f mm | rms |H| residual: 0.80mm -> %.4f, 3.08mm -> %.4f, best -> %.4f\n', ...
    d2_best*1e3, cost_d(i08), cost_d(i308), cost_d(imin));
if abs(d2_best - 3.08e-3) < abs(d2_best - 0.8e-3)
    slab(k2).d = 3.08e-3;
else
    slab(k2).d = 0.8e-3;
end
fprintf('    -> using d = %.2f mm for slab 2\n', slab(k2).d*1e3);

% time-domain echo check: subtract the (shifted, scaled) reference pulse and
% look for the internal echo at the two candidate arrival times
[pk2, ~] = min(slab(k2).y);  [pkr, ~] = min(yref);
y_ref_sh = interp1(tref + slab(k2).tau, yref*(pk2/pkr), slab(k2).t, 'linear', 0);
resid2 = slab(k2).y - y_ref_sh;
t2pk = peaktime(slab(k2).t, slab(k2).y);
techo = @(dc) 2*(dc + c0*slab(k2).tau*1e-12)/c0*1e12;   % ps after main pulse
fprintf('    expected echo: d=0.80mm -> +%.1f ps | d=3.08mm -> +%.1f ps\n', ...
    techo(0.8e-3), techo(3.08e-3));
for dc = [0.8e-3 3.08e-3]
    w = abs(slab(k2).t - t2pk - techo(dc)) < 1.5;
    fprintf('    residual envelope near +%.1f ps: max|resid| = %.4f a.u.\n', ...
        techo(dc), max(abs(resid2(w))));
end

fig = figure('Position',[100 100 980 300]);
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; hold on;
plot(dgrid*1e3, cost_d, 'Color', col(1,:));
xline(0.8,  '--', 'Color', col(2,:), 'Label','0.80 mm', 'LabelVerticalAlignment','middle');
xline(3.08, '--', 'Color', col(5,:), 'Label','3.08 mm', 'LabelVerticalAlignment','middle');
plot(d2_best*1e3, cost_d(imin), 'v', 'Color', col(5,:), 'MarkerFaceColor', col(5,:));
xlabel('Assumed thickness d (mm)'); ylabel('rms |H| fit residual');
title('(a) Thickness scan, delay-consistent n(d)');
nexttile; hold on;
fb = fref(band2)/THz;
plot(fb, abs(H2(band2)), 'Color', [.6 .6 .6], 'DisplayName','measured');
cands = [0.8e-3, 3.08e-3]; cc = [col(2,:); col(5,:)];
for q = 1:2
    n_c = 1 + c0*slab(k2).tau*1e-12/cands(q);
    tand_c = fit_tand_scalar(fref(band2), H2s(band2), cands(q), n_c^2);
    Hm = tl_model(fref(band2), cands(q), n_c^2, tand_c);
    plot(fb, abs(Hm), '--', 'Color', cc(q,:), 'LineWidth', 1.4, ...
        'DisplayName', sprintf('model d = %.2f mm', cands(q)*1e3));
end
xlabel('Frequency (THz)'); ylabel('|H(f)|'); ylim([0.6 1.1]);
title('(b) Etalon ripple comparison'); legend('Location','southwest');
nexttile; hold on;
plot(slab(k2).t - t2pk, abs(resid2), 'Color', col(1,:));
% predicted echo amplitude per candidate: |Gamma_int|^2 x main peak
for q = 1:2
    n_c = 1 + c0*slab(k2).tau*1e-12/cands(q);
    Aech = ((n_c-1)/(n_c+1))^2 * abs(pk2);
    xline(techo(cands(q)), '--', 'Color', cc(q,:));
    plot(techo(cands(q)), Aech, 'v', 'Color', cc(q,:), 'MarkerFaceColor', cc(q,:));
    text(techo(cands(q))+0.6, Aech, sprintf('predicted echo, d = %.2f mm', cands(q)*1e3), ...
        'FontSize', 8, 'Color', cc(q,:));
end
set(gca,'YScale','log'); ylim([2e-4 0.3]);
xlim([3 32]); xlabel('Time after main pulse (ps)');
ylabel('|sample - scaled reference| (a.u.)');
title('(c) Internal-echo search');
savefig_both(fig, figdir, 'fig_slab2_dscan');

%% --- per-slab extraction
fprintf('\n=== Slab extraction ===\n');
T_post = 100 - tau_ref;   % ps of usable window after the reference pulse
for k = 1:numel(slab)
    d = slab(k).d;
    n_delay  = 1 + c0*slab(k).tau*1e-12/d;
    eps_del  = n_delay^2;
    H = slab(k).S ./ Sref;
    band = pick_band(fref, slab(k).dB, slab(k).floor, dBref, floor_ref);
    fb = fref(band);  Hb = abs(H(band));

    % does the first internal echo fall inside the scan window?
    t_echo = 2*n_delay*d/c0*1e12;     % ps after the main transmitted pulse
    useFP  = t_echo < (T_post - 8);   % keep margin for the Tukey taper
    slab(k).useFP = useFP;

    % eps_r is taken from the time delay (course method, constant in f).
    % Where the etalon ripple is in-window the ripple period provides an
    % independent eps_r estimate ("sweep the permittivity"), reported as a
    % cross-check; for low index contrast that sweep is ill-conditioned
    % (level changes degenerate with tan d), so it is not used for slabs
    % with weak ripple.
    eps_use = eps_del;
    eps_swp = NaN;
    if useFP
        egrid = eps_del * linspace(0.85, 1.15, 121);
        cost_e = zeros(size(egrid));
        Hs = movmean(Hb, 5);
        for i = 1:numel(egrid)
            cost_e(i) = fit_tand_cost(fb, Hs, d, egrid(i));
        end
        [~, ie] = min(cost_e);
        eps_swp = egrid(ie);
    end

    % per-frequency loss tangent at the delay permittivity (grid + local
    % refinement; fminbnd alone stalls on the flat |H|=0 plateau of thick
    % slabs)
    tand_f = zeros(size(fb));
    for i = 1:numel(fb)
        tand_f(i) = invert_tand(fb(i), Hb(i), d, eps_use, useFP);
    end
    Hfit = abs(tl_model(fb, d, eps_use, tand_f, useFP));
    [tand_s, rmsr] = fit_tand_scalar(fb, Hb, d, eps_use, useFP);
    tand_sm = movmean(tand_f, 9);
    tand_05 = interp1(fb, tand_sm, 0.5*THz, 'linear', NaN);
    tand_10 = interp1(fb, tand_sm, 1.0*THz, 'linear', NaN);
    tand_med = median(tand_f);

    [~, im] = min(abs(eps_use - mat_eps));
    slab(k).n_delay = n_delay;  slab(k).eps_del = eps_del;
    slab(k).eps_swp = eps_swp;  slab(k).band = band;
    slab(k).tand_f = tand_f;    slab(k).tand_med = tand_med;
    slab(k).tand_05 = tand_05;  slab(k).tand_10 = tand_10;
    slab(k).tand_s = tand_s;    slab(k).rms = rmsr;
    slab(k).dBlam = 20*log10(exp(1))*pi*tand_05;   % = 27.29 * tan d @ 0.5 THz
    slab(k).H = H;  slab(k).Hfit = Hfit;
    slab(k).mat = mat_names{im};  slab(k).eps_tab = mat_eps(im);
    fprintf(['  %s d=%5.2fmm tau=%6.2fps n=%.3f eps=%6.3f eps_sweep=%6.3f ' ...
             'tand(0.5/1.0THz)=%.4f/%.4f dB/lam=%.2f rms=%.3f FP=%d band=[%.2f %.2f] -> %s (%.2f, %+.1f%%)\n'], ...
        slab(k).name, d*1e3, slab(k).tau, n_delay, eps_use, eps_swp, ...
        tand_05, tand_10, slab(k).dBlam, rmsr, useFP, fb(1)/THz, fb(end)/THz, ...
        slab(k).mat, slab(k).eps_tab, 100*(eps_use-slab(k).eps_tab)/slab(k).eps_tab);
end

% Si wafers: equivalent conductivity / resistivity from tan d(f)
fprintf('\n=== Si wafers: equivalent conductivity ===\n');
for k = [4 5]
    fb = fref(slab(k).band);
    sig = 2*pi*fb .* 8.8541878128e-12 * slab(k).eps_del .* slab(k).tand_f;
    slab(k).sigma = median(sig);  slab(k).rho = 1/slab(k).sigma*100;  % Ohm*cm
    fprintf('  %s: sigma = %.2f S/m -> rho = %.1f Ohm*cm\n', slab(k).name, slab(k).sigma, slab(k).rho);
end

%% --- A2 figure: time-domain waterfall
fig = figure('Position',[100 100 760 420]);
hold on;
offs = 4.5;
plot(tref, yref, 'k');
text(36.5, 1.3, sprintf('reference  (\\tau_{dif} = 0)'), 'FontSize', 9);
for k = 1:numel(slab)
    plot(slab(k).t, slab(k).y - offs*k, 'Color', col(k,:));
    text(36.5, -offs*k + 1.3, sprintf('%s, d = %.3g mm, \\tau_{dif} = %.2f ps', ...
        slab(k).name, slab(k).d*1e3, slab(k).tau), 'FontSize', 9);
end
xline(tau_ref, ':', 'Color', [.4 .4 .4]);
xlim([36 100]); ylim([-offs*6-3.6 3]);
set(gca,'YTick',[]);
xlabel('Time (ps)'); ylabel('THz signal (a.u., offset)');
savefig_both(fig, figdir, 'fig_a2_time');

%% --- A2 figure: |H| fits (2x3)
fig = figure('Position',[100 100 860 460]);
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
for k = 1:numel(slab)
    nexttile; hold on;
    fb = fref(slab(k).band)/THz;
    plot(fb, abs(slab(k).H(slab(k).band)), 'Color', col(k,:), 'DisplayName','measured');
    plot(fb, slab(k).Hfit, 'k--', 'DisplayName','TL model');
    ylim([0 1.15]); xlabel('Frequency (THz)'); ylabel('|H(f)|');
    title(sprintf('%s: \\epsilon_r = %.2f, tan\\delta = %.3f', ...
        slab(k).name, slab(k).eps_del, slab(k).tand_med), 'FontWeight','normal');
    legend('Location','southwest','FontSize',8);
end
savefig_both(fig, figdir, 'fig_a2_Hfits');

%% --- A2 figure: tan d (f)
fig = figure('Position',[100 100 760 330]);
hold on;
for k = 1:numel(slab)
    fb = fref(slab(k).band)/THz;
    plot(fb, movmean(slab(k).tand_f, 9), 'Color', col(k,:), ...
        'DisplayName', sprintf('%s (%s)', slab(k).name, slab(k).mat));
end
set(gca,'YScale','log'); ylim([1e-3 1]);
xlabel('Frequency (THz)'); ylabel('tan\delta');
legend('Location','northeast','NumColumns',2);
savefig_both(fig, figdir, 'fig_a2_tand');

%% --- results table
res = table({slab.name}.', [slab.d].'*1e3, [slab.tau].', [slab.n_delay].', ...
    [slab.eps_del].', [slab.eps_swp].', [slab.tand_05].', [slab.tand_10].', ...
    [slab.dBlam].', [slab.rms].', {slab.mat}.', [slab.eps_tab].', ...
    'VariableNames', {'slab','d_mm','tau_ps','n','eps_delay','eps_sweep', ...
    'tand_0p5THz','tand_1THz','dB_per_lambda','rms_fit','material','eps_table'});
disp(res);
writetable(res, fullfile(resdir,'slab_summary.csv'));
A1res = table([A1.N].', [A1.sigma].', [A1.SNRt].', [A1.floor].', [A1.DR].', ...
    'VariableNames', {'N','sigma_t','SNR_t_dB','floor_dB','DR_dB'});
writetable(A1res, fullfile(resdir,'a1_summary.csv'));
save(fullfile(resdir,'lab1_results.mat'), 'A1', 'slab', 'res');
fprintf('\nDone. Figures in %s, results in %s\n', figdir, resdir);

%% ========================= local functions =============================
function [f, S] = spec(t_ps, y)
    dt = mean(diff(t_ps))*1e-12;
    Nfft = 4096;
    Y = fft(y(:), Nfft);
    f = (0:Nfft/2-1).'/(Nfft*dt);
    S = Y(1:Nfft/2);
end

function w = tukeywin_local(N, a)
    % Tukey (tapered cosine) window without the Signal Processing Toolbox
    w = ones(N,1);
    x = linspace(0,1,N).';
    i1 = x < a/2;
    i2 = x >= 1 - a/2;
    w(i1) = 0.5*(1 + cos(2*pi/a*(x(i1) - a/2)));
    w(i2) = 0.5*(1 + cos(2*pi/a*(x(i2) - 1 + a/2)));
end

function tp = peaktime(t_ps, y)
    % time of the dominant (negative) lobe with parabolic refinement
    [~, i] = min(y);
    dt = t_ps(2) - t_ps(1);
    den = y(i-1) - 2*y(i) + y(i+1);
    tp = t_ps(i) + dt/2*(y(i-1) - y(i+1))/den;
end

function band = pick_band(f, dBs, floor_s, dBr, floor_r)
    % contiguous band where sample and reference are >15 dB above their floors
    THz = 1e12;
    ok = f > 0.15*THz & f < 3*THz & ...
         movmean(dBs,7) > floor_s + 15 & movmean(dBr,7) > floor_r + 15;
    i0 = find(ok, 1);
    iend = find(~ok & (1:numel(ok)).' > i0, 1) - 1;
    if isempty(iend), iend = find(ok, 1, 'last'); end
    band = false(size(f));
    band(i0:iend) = true;
end

function H = tl_model(f, d, eps_r, tand, useFP)
    % slab transmission transfer function, per Processing_TimeDomain_2026
    % (air / slab / air; H = Vout+/Vin+ referenced to the same air span)
    if nargin < 5, useFP = true; end
    c0 = 299792458;  eta0 = 376.730313668;
    w = 2*pi*f(:);  tand = tand(:);
    kz0 = w/c0;
    beta = w/c0*sqrt(eps_r);
    alph = w/c0*sqrt(eps_r).*tand/2;
    kzs = beta - 1i*alph;
    Zs = eta0/sqrt(eps_r)*(1 + 1i*tand/2);
    GB = (eta0 - Zs)./(eta0 + Zs);            % slab -> air
    if useFP
        ZinA = Zs.*(eta0 + 1i*Zs.*tan(kzs*d))./(Zs + 1i*eta0.*tan(kzs*d));
        GA = (ZinA - eta0)./(ZinA + eta0);
        Vr = exp(1i*kzs*d).*exp(-1i*kz0*d).*(1 + GB.*exp(-2i*kzs*d)) ...
             ./ ((1 + GB).*(1 + GA));
        H = 1./Vr;
    else
        % first transit only (internal echo outside the scan window)
        Gab = (Zs - eta0)./(Zs + eta0);       % air -> slab
        H = (1 + Gab).*(1 + GB).*exp(-1i*(kzs - kz0)*d);
    end
end

function [tand, r] = fit_tand_scalar(f, Hmeas, d, eps_r, useFP)
    % best single tan d over the band; grid search avoids the flat |H|=0
    % plateau of thick lossy slabs that defeats fminbnd's bracketing
    if nargin < 5, useFP = true; end
    tg = [0, logspace(-4, 0, 160)];
    R = zeros(size(tg));
    for i = 1:numel(tg)
        R(i) = rms(abs(tl_model(f, d, eps_r, tg(i)*ones(size(f)), useFP)) - Hmeas(:));
    end
    [r, j] = min(R);
    tand = tg(j);
end

function td = invert_tand(f, Hmeas, d, eps_r, useFP)
    % per-frequency tan d such that |H_model| = |H_meas| (monotonic in tan d)
    tg = [0, logspace(-4.5, 0, 400)];
    g = abs(tl_model(f*ones(size(tg)), d, eps_r, tg, useFP));
    [~, j] = min(abs(g(:) - Hmeas));
    td = tg(j);
end

function r = fit_tand_cost(f, Hmeas, d, eps_r, useFP)
    if nargin < 5, useFP = true; end
    [~, r] = fit_tand_scalar(f, Hmeas, d, eps_r, useFP);
end

function savefig_both(fig, figdir, name)
    exportgraphics(fig, fullfile(figdir, [name '.pdf']), 'ContentType','vector');
    exportgraphics(fig, fullfile(figdir, [name '.png']), 'Resolution', 220);
end
