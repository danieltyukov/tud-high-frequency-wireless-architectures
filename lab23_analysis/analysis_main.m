%% EE4730 Communications Lab (Lab 2 & 3) — full analysis
% Group G2 data, 140-220 GHz (WR-5.1, Keysight N5224B + VDI extenders)
% Measurements:
%   #1 Horn-to-Horn   R = 10.5 cm  -> horn gain vs f (Friis, 2 identical antennas)
%   #2 Horn-to-Probe  R = 17.6 cm  -> horn far-field pattern (H-plane), directivity, probe gain
%   #3 Lens-to-Probe  (near-field) -> lens aperture field, NF->FF pattern, directivity
%   #4 Lens-to-Lens   R = 11.5 cm  -> quasi-optical link coupling vs Friis
% Time-gating applied to all S21 data to remove multipath.

clear; close all; clc;
c0 = 299792458;
datadir = '../Lab2&3_Com_2026_G2/';
figdir  = 'figs/';
set(groot,'defaultAxesFontSize',11,'defaultLineLineWidth',1.2,...
    'defaultAxesXGrid','on','defaultAxesYGrid','on');

%% ------------------------------------------------------------------ load
[fH, S_h2h] = read_s2p([datadir '1_Horn2Horn_10p5.s2p']);   % 801x1, 2x2x801
[fL, S_l2l] = read_s2p([datadir 'Lens2Lens_11p5cm.s2p']);
h2p = load([datadir 'G2_Horn2probe_17p6.mat']);  h2p = h2p.sdata;
l2p = load([datadir 'G2_Lens2probe.mat']);       l2p = l2p.sdata;

f   = fH;                       % same grid everywhere: 140:0.1:220 GHz
df  = f(2)-f(1);                % 100 MHz
Nf  = numel(f);
lam = c0./f;

R_h2h = 0.105;   % m
R_h2p = 0.176;   % m
R_l2l = 0.115;   % m

% scan axes (mm, relative)
x_h2p = h2p.xpos_rel(:);        % 0..200 mm, 5 mm step
x_l2p = l2p.xpos_rel(:);        % 0..40 mm, 1 mm step
S21_h2p = cell2mat(cellfun(@(z) z(:).', h2p.S21(:), 'uni', 0)); % 41 x 801
S21_l2p = cell2mat(cellfun(@(z) z(:).', l2p.S21(:), 'uni', 0));
S22_h2p = cell2mat(cellfun(@(z) z(:).', h2p.S22(:), 'uni', 0));
S11_l2p = cell2mat(cellfun(@(z) z(:).', l2p.S11(:), 'uni', 0));

%% ----------------------------------------------- time-domain + gating set-up
% band-limited impulse response: t axis 0..1/df = 10 ns, resolution ~1/B = 12.5 ps
t = (0:Nf-1).'/(Nf*df);         % s

s21_hh = squeeze(S_h2h(2,1,:));
s21_ll = squeeze(S_l2l(2,1,:));

% boresight traces of the scans (band-mean power is robust against spikes)
[~,i0_h2p] = max(mean(abs(S21_h2p).^2,2));
[~,i0_l2p] = max(mean(abs(S21_l2p).^2,2));
fprintf('boresight index  H2P: %d (x=%g mm)   L2P: %d (x=%g mm)\n', ...
    i0_h2p, x_h2p(i0_h2p), i0_l2p, x_l2p(i0_l2p));

% quick look at impulse responses to place gates (peak restricted to 0.2-2 ns)
h_hh  = ifft(s21_hh);
h_ll  = ifft(s21_ll);
h_h2p = ifft(S21_h2p(i0_h2p,:).');
h_l2p = ifft(S21_l2p(i0_l2p,:).');
tsearch = t > 0.2e-9 & t < 2e-9;
tpk_hh  = peaktime(t, h_hh,  tsearch);
tpk_ll  = peaktime(t, h_ll,  tsearch);
tpk_h2p = peaktime(t, h_h2p, tsearch);
tpk_l2p = peaktime(t, h_l2p, tsearch);
fprintf('peak delays [ns]:  H2H %.3f (R/c=%.3f)  L2L %.3f (R/c=%.3f)  H2P %.3f (R/c=%.3f)  L2P %.3f\n', ...
    tpk_hh*1e9, R_h2h/c0*1e9, tpk_ll*1e9, R_l2l/c0*1e9, tpk_h2p*1e9, R_h2p/c0*1e9, tpk_l2p*1e9);

% gate parameters (s): half-width and taper fraction (Tukey-edge)
gate_hw  = 0.25e-9;
gate_tap = 0.5;

s21_hh_g  = timegate(s21_hh,  df, tpk_hh,  gate_hw, gate_tap);
s21_ll_g  = timegate(s21_ll,  df, tpk_ll,  gate_hw, gate_tap);

% gate the scan traces: gate centre follows the geometric delay r'(x)/c
% offset (cables/horn length) estimated from the boresight trace
xc_h2p = x_h2p(i0_h2p);
rp_h2p = sqrt(R_h2p^2 + ((x_h2p-xc_h2p)*1e-3).^2);     % slant range per position
off_h2p = tpk_h2p - R_h2p/c0;
S21_h2p_g = zeros(size(S21_h2p));
for i = 1:numel(x_h2p)
    S21_h2p_g(i,:) = timegate(S21_h2p(i,:).', df, rp_h2p(i)/c0 + off_h2p, gate_hw, gate_tap).';
end
% lens NF scan: collimated beam -> constant delay across the aperture
S21_l2p_g = zeros(size(S21_l2p));
for i = 1:numel(x_l2p)
    S21_l2p_g(i,:) = timegate(S21_l2p(i,:).', df, tpk_l2p, gate_hw, gate_tap).';
end

% band edges suffer from gate roll-off -> evaluation band for derived quantities
fmask = f >= 143.5e9 & f <= 216.5e9;
% narrow RFI/extender spur around 211 GHz contaminates low-level scan traces;
% the gate smears it by ~1/T_gate = 2 GHz on each side. Wider mask for the
% low-SNR horn-probe-derived quantities, narrow mask for the lens scan.
frfi   = f >= 206.5e9 & f <= 215.5e9;
frfi_n = f >= 210.2e9 & f <= 212.8e9;

%% ------------------------------------------------- FIG: time domain + gates
fig = figure('Visible','off','Position',[100 100 900 360]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
plot(t*1e9, 20*log10(abs(h_hh)),'DisplayName','|h(t)| Horn\rightarrowHorn'); hold on;
plot(t*1e9, 20*log10(abs(h_ll)),'DisplayName','|h(t)| Lens\rightarrowLens');
g = gatewin(t, tpk_hh, gate_hw, gate_tap);
plot(t*1e9, 20*log10(max(g,1e-6))-10,'k--','DisplayName','gate (H2H, -10 dB offset)');
xlim([0 5]); ylim([-110 0]); xlabel('Time [ns]'); ylabel('[dB]');
legend('Location','northeast'); title('(a) Impulse responses and gate');
nexttile;
plot(t*1e9, 20*log10(abs(h_h2p)),'DisplayName','Horn\rightarrowProbe (boresight)'); hold on;
plot(t*1e9, 20*log10(abs(h_l2p)),'DisplayName','Lens\rightarrowProbe (boresight)');
xlim([0 5]); ylim([-110 -10]); xlabel('Time [ns]'); ylabel('[dB]');
legend('Location','northeast'); title('(b) Scan boresight impulse responses');
exportgraphics(fig, [figdir 'fig_timedomain.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_timedomain.pdf'], 'ContentType','vector');

%% --------------------------------------------- FIG: gating effect on S21
fig = figure('Visible','off','Position',[100 100 900 360]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
plot(f/1e9, 20*log10(abs(s21_hh)), 'Color',[.4 .6 .9],'DisplayName','raw'); hold on;
plot(f/1e9, 20*log10(abs(s21_hh_g)),'r','DisplayName','time-gated');
xlabel('Frequency [GHz]'); ylabel('|S_{21}| [dB]'); title('(a) Horn\rightarrowHorn, R = 10.5 cm');
legend('Location','best'); xlim([140 220]);
nexttile;
plot(f/1e9, 20*log10(abs(s21_ll)), 'Color',[.4 .6 .9],'DisplayName','raw'); hold on;
plot(f/1e9, 20*log10(abs(s21_ll_g)),'r','DisplayName','time-gated');
xlabel('Frequency [GHz]'); ylabel('|S_{21}| [dB]'); title('(b) Lens\rightarrowLens, R = 11.5 cm');
legend('Location','best'); xlim([140 220]);
exportgraphics(fig, [figdir 'fig_gating_s21.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_gating_s21.pdf'], 'ContentType','vector');

%% ------------------------------------------------------- horn gain (Friis)
% two identical antennas: G = 0.5*(S21dB - 20log10(lambda/(4 pi R)))
fspl_h2h = 20*log10(lam/(4*pi*R_h2h));
Gh_raw  = 0.5*(20*log10(abs(s21_hh))   - fspl_h2h);
Gh      = 0.5*(20*log10(abs(s21_hh_g)) - fspl_h2h);

% Eravant SAR-2013-05-S2 typical gain anchor points (datasheet curve)
f_ds = [140 160 180 200 220]*1e9;  G_ds = [19.0 20.2 21.0 21.5 21.9];

fig = figure('Visible','off','Position',[100 100 560 380]);
plot(f/1e9, Gh_raw, 'Color',[.4 .6 .9],'DisplayName','raw'); hold on;
plot(f/1e9, Gh, 'r','DisplayName','time-gated');
plot(f_ds/1e9, G_ds, 'ko--','DisplayName','datasheet (typ.)');
xlabel('Frequency [GHz]'); ylabel('Gain [dBi]'); xlim([140 220]); ylim([14 24]);
legend('Location','southeast'); title('Horn gain from Horn\rightarrowHorn (Friis)');
exportgraphics(fig, [figdir 'fig_horn_gain.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_horn_gain.pdf'], 'ContentType','vector');

Gh_165 = interp1(f, Gh, 165e9);
fprintf('Horn gain @165 GHz (gated): %.2f dBi\n', Gh_165);

%% --------------------------------------- horn radiation pattern (H-plane)
% refine boresight with a parabolic fit of gated power at 165 GHz
[~,if0] = min(abs(f-165e9));
xc_h2p = parapeak(x_h2p, 20*log10(abs(S21_h2p_g(:,if0))));
rp_h2p = sqrt(R_h2p^2 + ((x_h2p-xc_h2p)*1e-3).^2);
fprintf('H2P refined boresight: x = %.1f mm\n', xc_h2p);

% planar -> spherical:  tan(th) = x/R ; E(th) ∝ S21(x) * (r''/R) * exp(jk(r''-R))
th_h2p = atan((x_h2p - xc_h2p)*1e-3 / R_h2p);          % rad
k0  = 2*pi*f/c0;
Eh  = zeros(numel(x_h2p), Nf);
for i = 1:numel(x_h2p)
    Eh(i,:) = S21_h2p_g(i,:) .* (rp_h2p(i)/R_h2p) .* exp(1j*k0.'.*(rp_h2p(i)-R_h2p));
end

% horn directivity vs f (phi-symmetry approx):  D = 2|E|max^2 / int |E|^2 sin th dth
D_horn = dir_from_cut(th_h2p, Eh);

% probe gain: boresight Friis with known horn gain
fspl_h2p = 20*log10(lam/(4*pi*R_h2p));
Gp = 20*log10(abs(S21_h2p_g(i0_h2p,:).')) - fspl_h2p - Gh;
Gp_165 = interp1(f, Gp, 165e9);
fprintf('Probe gain @165 GHz: %.2f dBi\n', Gp_165);

% equivalent uniform-aperture diameter from measured directivity @165 GHz
D165 = interp1(f, D_horn, 165e9);
Deq_horn = (c0/165e9/pi) * sqrt(10^(D165/10));
fprintf('Horn directivity @165 GHz: %.2f dBi -> D_eq = %.2f mm\n', D165, Deq_horn*1e3);

% pattern figure: 150/165/195 GHz + Airy of equal-directivity aperture
thp = linspace(-pi/2, pi/2, 721);
airy_h = airycut(thp, Deq_horn, c0/165e9);
fplot_list = [150e9 165e9 195e9];
cols = [0.55 0.75 1.0; 1 0 0; 0.4 0.65 0.35];
fig = figure('Visible','off','Position',[100 100 560 380]);
hold on;
for q = 1:numel(fplot_list)
    [~,iq] = min(abs(f-fplot_list(q)));
    En = abs(Eh(:,iq))/max(abs(Eh(:,iq)));
    plot(rad2deg(th_h2p), 20*log10(En), 'o-','Color',cols(q,:), ...
        'DisplayName',sprintf('measured %g GHz', fplot_list(q)/1e9));
end
plot(rad2deg(thp), 20*log10(abs(airy_h)), 'k--','DisplayName',sprintf('Airy @165, D_{eq} = %.1f mm', Deq_horn*1e3));
xlabel('\theta [deg]'); ylabel('Normalized pattern [dB]');
xlim([-35 35]); ylim([-40 2]); legend('Location','south'); grid on;
title('Horn H-plane pattern vs ideal aperture (Airy)');
exportgraphics(fig, [figdir 'fig_horn_pattern.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_horn_pattern.pdf'], 'ContentType','vector');

% directivity + gain vs frequency (RFI band masked in directivity)
D_horn_p = D_horn; D_horn_p(frfi) = NaN;
fig = figure('Visible','off','Position',[100 100 560 380]);
plot(f(fmask)/1e9, D_horn_p(fmask), 'b','DisplayName','D_{horn} (pattern integration)'); hold on;
plot(f(fmask)/1e9, Gh(fmask), 'r','DisplayName','G_{horn} (Friis H2H)');
D_airy_h = 10*log10((pi*Deq_horn./lam).^2);
plot(f(fmask)/1e9, D_airy_h(fmask), 'k--','DisplayName','ideal aperture (Airy), D_{eq}@165');
xlabel('Frequency [GHz]'); ylabel('[dBi]'); xlim([140 220]);
legend('Location','southeast'); title('Horn: directivity and gain vs frequency');
exportgraphics(fig, [figdir 'fig_horn_dir_gain.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_horn_dir_gain.pdf'], 'ContentType','vector');

% probe gain figure (RFI band masked)
Gp_p = Gp; Gp_p(frfi) = NaN;
fig = figure('Visible','off','Position',[100 100 560 380]);
plot(f(fmask)/1e9, Gp_p(fmask), 'r');
xlabel('Frequency [GHz]'); ylabel('Gain [dBi]'); xlim([140 220]);
title('Open-ended WR-5.1 probe gain (Friis, horn reference)');
exportgraphics(fig, [figdir 'fig_probe_gain.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_probe_gain.pdf'], 'ContentType','vector');

%% ---------------------------------------------- lens focal-plane scan (#5)
% The scan shows an Airy-like spot (FWHM ~7 mm, SLL ~ -17 dB): focal-plane
% field of the lens system focused at F = 11.5 cm. For large f-numbers the
% focal field maps to the far-field pattern via sin(th) = x/F  (lens = FT).
F_l2p = 0.115;   % m
D_L   = 30e-3;   % lens antenna diameter

% sub-mm boresight from a parabolic fit of the gated focal spot
xc_l2p = parapeak(x_l2p, 20*log10(abs(S21_l2p_g(:,if0))));
fprintf('L2P refined focal-spot centre: x = %.2f mm\n', xc_l2p);
th_l2p = asin((x_l2p - xc_l2p)*1e-3 / F_l2p);          % rad

% focal-spot cut: amplitude + phase at 165 GHz
fig = figure('Visible','off','Position',[100 100 900 360]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
Efoc = S21_l2p_g(:,if0);
plot(x_l2p-xc_l2p, 20*log10(abs(Efoc)/max(abs(Efoc))), 'ro-'); hold on;
xlabel('x - x_0 [mm]'); ylabel('|E_{focal}| [dB]'); title('(a) Focal-plane amplitude, 165 GHz');
ylim([-35 2]);
nexttile;
ph = rad2deg(unwrap(angle(Efoc)));
plot(x_l2p-xc_l2p, ph - ph(i0_l2p), 'bo-');
xlabel('x - x_0 [mm]'); ylabel('\angle E_{focal} [deg]'); title('(b) Focal-plane phase, 165 GHz');
exportgraphics(fig, [figdir 'fig_lens_nf.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_lens_nf.pdf'], 'ContentType','vector');

% directivity vs frequency from the angular cut
Elens = S21_l2p_g;              % rows = positions = angles, cols = freq
D_lens = dir_from_cut(th_l2p, Elens);

% lens pattern at 150/165/195 GHz vs Airy D = 30 mm
fig = figure('Visible','off','Position',[100 100 560 380]);
hold on;
for q = 1:numel(fplot_list)
    [~,iq] = min(abs(f-fplot_list(q)));
    Eln = abs(Elens(:,iq))/max(abs(Elens(:,iq)));
    plot(rad2deg(th_l2p), 20*log10(Eln), 'o-','Color',cols(q,:), ...
        'DisplayName',sprintf('measured %g GHz', fplot_list(q)/1e9));
end
thq = linspace(-pi/8, pi/8, 721);
airy_l = airycut(thq, D_L, c0/165e9);
plot(rad2deg(thq), 20*log10(abs(airy_l)), 'k--','DisplayName','Airy @165, D_L = 30 mm');
xlabel('\theta [deg]'); ylabel('Normalized pattern [dB]');
xlim([-12 12]); ylim([-40 2]); legend('Location','south'); grid on;
title('Lens antenna H-plane pattern vs ideal aperture (Airy)');
exportgraphics(fig, [figdir 'fig_lens_pattern.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_lens_pattern.pdf'], 'ContentType','vector');

% lens directivity vs f + ideal pi^2 D^2/lam^2 (RFI band masked)
D_lens_p = D_lens; D_lens_p(frfi_n) = NaN;
fig = figure('Visible','off','Position',[100 100 560 380]);
plot(f(fmask)/1e9, D_lens_p(fmask), 'r','DisplayName','D_{lens} (focal-plane scan)'); hold on;
D_airy_l = 10*log10((pi*D_L./lam).^2);
plot(f(fmask)/1e9, D_airy_l(fmask), 'k--','DisplayName','max: \pi^2D_L^2/\lambda^2');
xlabel('Frequency [GHz]'); ylabel('Directivity [dBi]'); xlim([140 220]);
legend('Location','southeast'); title('Lens directivity vs frequency');
exportgraphics(fig, [figdir 'fig_lens_dir.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_lens_dir.pdf'], 'ContentType','vector');

Dl_165 = interp1(f, D_lens, 165e9);
fprintf('Lens directivity @165 GHz: %.2f dBi (ideal: %.2f dBi)\n', Dl_165, ...
    10*log10((pi*D_L/(c0/165e9))^2));

%% --------------------------------------------- coupling comparison + QO theory
% measured couplings (gated)
Cou_hh = 20*log10(abs(s21_hh_g));
Cou_ll = 20*log10(abs(s21_ll_g));

% Friis predictions at 165 GHz vs R, using measured gains/directivities
lam0 = c0/165e9;  k00 = 2*pi/lam0;
Rv = logspace(log10(0.02), log10(2), 200);
Friis_ll = 2*Dl_165 + 20*log10(lam0./(4*pi*Rv));
Friis_hh = 2*Gh_165 + 20*log10(lam0./(4*pi*Rv));

% QO coupling: two uniform-phase circular apertures D=30mm, Fresnel propagation
N = 1024; L = 0.25;                       % m window
dx = L/N; xg = (-N/2:N/2-1)*dx;
[X,Y] = meshgrid(xg); RHO = hypot(X,Y);
A1 = double(RHO <= D_L/2);
FA = fftshift(fft2(ifftshift(A1)));
kx = 2*pi*(-N/2:N/2-1)/(N*dx); [KX,KY] = meshgrid(kx);
KZ2 = k00^2 - KX.^2 - KY.^2; prop_ok = KZ2 > 0;
Cou_qo = zeros(size(Rv));
for q = 1:numel(Rv)
    H = zeros(N); H(prop_ok) = exp(-1j*sqrt(KZ2(prop_ok))*Rv(q));
    E2 = fftshift(ifft2(ifftshift(FA.*H)));
    Cou_qo(q) = abs(sum(E2(:).*conj(A1(:))))^2 / (sum(abs(A1(:)).^2)^2);
end

fig = figure('Visible','off','Position',[100 100 620 420]);
semilogx(Rv, Friis_ll, 'b--','DisplayName','Friis, lens directivities'); hold on;
semilogx(Rv, 10*log10(Cou_qo), 'b','DisplayName','QO theory: two 30 mm uniform apertures');
semilogx(Rv, Friis_hh, 'Color',[1 .6 .2],'LineStyle','--','DisplayName','Friis, horn gains');
Cou_ll_165 = interp1(f, Cou_ll, 165e9);
Cou_hh_165 = interp1(f, Cou_hh, 165e9);
semilogx(R_l2l, Cou_ll_165, 'bs','MarkerSize',10,'MarkerFaceColor','b','DisplayName','measured Lens\rightarrowLens');
semilogx(R_h2h, Cou_hh_165, 'o','MarkerSize',10,'Color',[1 .6 .2],'MarkerFaceColor',[1 .6 .2],'DisplayName','measured Horn\rightarrowHorn');
yline(0,'k:','HandleVisibility','off');
Rf_lens = 2*D_L^2/lam0; xline(Rf_lens,'k-.',{'R_f lens'},'HandleVisibility','off');
xlabel('Link distance R [m]'); ylabel('Coupling P_{rx}/P_{tx} [dB]');
ylim([-50 15]); legend('Location','southwest');
title('Coupling of the different setups @ 165 GHz');
exportgraphics(fig, [figdir 'fig_coupling.png'], 'Resolution', 200);
exportgraphics(fig, [figdir 'fig_coupling.pdf'], 'ContentType','vector');

fprintf('Coupling @165 GHz:  H2H %.1f dB   L2L %.1f dB\n', Cou_hh_165, Cou_ll_165);
fprintf('Friis L2L @11.5cm with D_lens: %.1f dB (unphysical > 0!)\n', ...
    2*Dl_165 + 20*log10(lam0/(4*pi*R_l2l)));
Cou_qo_115 = interp1(Rv, 10*log10(Cou_qo), R_l2l);
fprintf('QO theory L2L @11.5cm: %.2f dB\n', Cou_qo_115);

% lens loss / gain estimate from the QO link budget:
% measured = QO diffraction term + 2x (ohmic + reflection) loss per antenna
loss_per_lens = (Cou_ll_165 - Cou_qo_115)/2;     % dB (negative)
G_lens_165 = Dl_165 + loss_per_lens;
fprintf('Estimated loss per lens antenna: %.2f dB -> G_lens @165 GHz ~ %.1f dBi\n', ...
    -loss_per_lens, G_lens_165);

%% ------------------------------------------------------------- summary save
HPBW_horn = hpbw_from_cut(th_h2p, abs(Eh(:,if0)));
HPBW_lens = hpbw_from_cut(th_l2p, abs(Elens(:,if0)));
fprintf('HPBW @165 GHz: horn %.1f deg, lens %.2f deg\n', rad2deg(HPBW_horn), rad2deg(HPBW_lens));
eta_ap = 10^(Dl_165/10) / (pi*D_L/(c0/165e9))^2;
fprintf('Lens aperture efficiency @165 GHz: %.2f\n', eta_ap);

save('results.mat','f','Gh','Gp','D_horn','D_lens','Cou_hh','Cou_ll', ...
     'th_h2p','Eh','th_l2p','Elens','Rv','Cou_qo','Friis_ll','Friis_hh', ...
     'Gh_165','Gp_165','D165','Dl_165','Deq_horn','Cou_hh_165','Cou_ll_165', ...
     'HPBW_horn','HPBW_lens','x_l2p','xc_l2p','S21_l2p_g','if0','eta_ap', ...
     'Cou_qo_115','loss_per_lens','G_lens_165');
disp('DONE');

%% ===================================================================== fns
function [fr, S] = read_s2p(fn)
    raw = readmatrix(fn, 'FileType','text', 'CommentStyle','!', 'NumHeaderLines',0);
    raw(any(isnan(raw),2),:) = [];
    fr = raw(:,1);
    S = zeros(2,2,numel(fr));
    % touchstone order: S11 S21 S12 S22 (dB, deg)
    idx = {[2 3],[4 5],[6 7],[8 9]}; pos = {[1 1],[2 1],[1 2],[2 2]};
    for m = 1:4
        mag = 10.^(raw(:,idx{m}(1))/20); ang = deg2rad(raw(:,idx{m}(2)));
        S(pos{m}(1),pos{m}(2),:) = mag.*exp(1j*ang);
    end
end

function g = gatewin(t, tc, hw, taper)
    % Tukey-edged time gate centred at tc, half-width hw
    g = zeros(size(t));
    flat = hw*(1-taper);
    for i = 1:numel(t)
        d = abs(t(i)-tc);
        if d <= flat
            g(i) = 1;
        elseif d <= hw
            g(i) = 0.5*(1+cos(pi*(d-flat)/(hw-flat)));
        end
    end
end

function Sg = timegate(S, df, tc, hw, taper)
    N = numel(S);
    t = (0:N-1).'/(N*df);
    h = ifft(S);
    Sg = fft(h .* gatewin(t, tc, hw, taper));
end

function D = dir_from_cut(th, E)
    % directivity (dBi) from a single cut assuming phi symmetry:
    % D = 2|E|max^2 / int_0^thmax |E(th)|^2 sin th dth   (both sides averaged)
    % E: Nth x Nf
    [ths, is] = sort(th(:)); E = E(is,:);
    P = abs(E).^2;
    Nf = size(E,2); D = zeros(Nf,1);
    thp = linspace(0, max(abs(ths)), 400).';
    for q = 1:Nf
        Pp = interp1(ths,  P(:,q), thp, 'linear', 0);   % +theta side
        Pm = interp1(-ths, P(:,q), thp, 'linear', 0);   % -theta side mirrored
        Psym = (Pp+Pm)/2;
        I = trapz(thp, Psym.*sin(thp));
        D(q) = 10*log10(2*max(Psym)/I);
    end
end

function tp = peaktime(t, h, mask)
    a = abs(h); a(~mask) = 0;
    [~,ip] = max(a);
    tp = t(ip);
end

function xc = parapeak(x, PdB)
    % parabolic interpolation of the peak of a sampled curve (dB domain)
    [~,im] = max(PdB);
    if im == 1 || im == numel(x), xc = x(im); return; end
    y1 = PdB(im-1); y2 = PdB(im); y3 = PdB(im+1);
    d = (y1 - y3) / (2*(y1 - 2*y2 + y3));
    xc = x(im) + d*(x(im+1)-x(im));
end

function F = airycut(th, D, lam)
    u = pi*D/lam*sin(th);
    F = ones(size(u));
    nz = abs(u) > 1e-9;
    F(nz) = 2*besselj(1,u(nz))./u(nz);
end

function w = hpbw_from_cut(th, A)
    A = A/max(A); [~,im] = max(A);
    iL = find(A(1:im) <= 10^(-3/20), 1, 'last');
    iR = im-1+find(A(im:end) <= 10^(-3/20), 1, 'first');
    thL = interp1(A([iL iL+1]), th([iL iL+1]), 10^(-3/20));
    thR = interp1(A([iR-1 iR]), th([iR-1 iR]), 10^(-3/20));
    w = thR - thL;
end
