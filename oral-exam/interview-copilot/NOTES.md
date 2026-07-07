# Condensed theory + lab work — EE4730, Time-Domain oral exam

Answer in one sentence (`CONTEXT.md`). This file backs questions about
underlying theory or the measurement method that aren't tied to one slide;
`SPEECH_NOTES.md` covers the deck itself.

## Course theory

### Lecture 2 — Time-domain systems & photoconductive antennas (this exam's topic)

**Two generation paradigms.** Heterodyne: multiply a lower-frequency signal
up via a mixer chain (×N); clean CW tone but only ~30 GHz of bandwidth.
Photoconductivity: DC bias switched by a femtosecond laser; one pulse spans
up to ~2 THz. This lab uses photoconductivity because one scan + FFT gives a
material's whole 0.15-3 THz response at once.

**PCA physics.** Material is LT-GaAs (low-temperature-grown GaAs), band gap
1.59 eV → matches the 780 nm pump laser. Recombination time τc ≈ 1 ps,
matched to the THz period. Emitter: fs pulse generates carriers, DC bias
accelerates them, recombination kills the current after ~1 ps, and that
current burst radiates the pulse — three ingredients: generation,
acceleration, recombination. Receiver: same device, no bias; the incident
THz field does the accelerating, so the readout current is proportional to
the field at the instant the laser fires. At high optical power the radiated
field screens the bias and the photocurrent saturates (modelled as an
impedance mismatch in the Norton equivalent) — this is why high-power THz
sources use arrays of matched PCAs rather than one bigger PCA.

**Carrier-dynamics equations (exam-critical, be able to identify each
term):**
- Generation rate (Gaussian laser pulse, width τp): g_gen(t'') = A·exp[-4ln2·(t''/τp)²]
- Average carrier density (exponential decay): n_ave(t,t'') = g_gen(t'')·exp[-(t-t'')/τc]
- Carrier velocity (Drude-Lorentz, scattering time τs): v_c(t,t'') = (qe/me)∫ exp[-(t-t')/τs]·e_g(t') dt'
- Total photocurrent = triple integral combining all three (generation ×
  acceleration × recombination); depends on τc, μDC, P_laser, V_bias.

**Stroboscopic sampling (the central trick).** Electronics sample at most a
few GS/s — far too slow for multi-THz bandwidth. The laser fires identical
pulses every 10 ns (100 MHz repetition rate, "PRF"); the receiver gap
conducts only during the ps it's illuminated, so each repetition samples the
field at exactly one delay. A motorized mirror sweeps that delay — 1 mm of
mirror travel ≈ 6.67 ps of round-trip delay. The readout is a DC average
current i_rec(Δt) = (1/T)∫ i_load(t,Δt) dt, proportional to the field at the
gate instant; sweeping Δt across the pulse reconstructs the full waveform
E(t) even though the electronics only ever measure a DC current.

**SNR / dynamic-range back-of-envelope (must be able to reproduce):**
Given 1 mW average Tx power at 100 MHz rep rate: energy/pulse ≈ 10 pJ, peak
power ≈ 20 W. With ~1/10 link efficiency, Rx pulse energy ≈ 1e-12 J →
absorbed over τrec ≈ 0.5 ps into R_Rx ≈ 100 Ω gives a peak current iτ ≈ 0.14
A. Duty-cycle-diluted DC average: i_ave = iτ·τrec/Trep ≈ 0.14·(0.5e-12/1e-8)
≈ 7 µA. Menlo amplifier noise ≈ 7e-11 A → single-shot SNR ≈ 100 dB.
Averaging N pulses: SNR = SNR_1shot + 10·log10(N) — e.g. N=1e4 → +40 dB
(140 dB total); one full waveform at N=1 takes ~10 ms to acquire.

**Applications of TDS:** pharmaceutical tablet coating-thickness imaging via
echo delay; water-content imaging of biological tissue/leaves (water absorbs
THz strongly); car-paint inspection (εr, loss tangent, layer thickness down
to 10 µm); future security imaging (mm-scale lateral/depth resolution).
Newer prototypes move from LT-GaAs/780 nm to InGaAs:Fe/1550 nm (telecom-laser
compatible), targeting ~20 mW of THz output power.

### Lecture 1 — THz systems, briefly (context, not this exam's main topic)

THz "gap": 0.3-3 THz sits above transistor fmax (BiCMOS SiGe HBT record
~750 GHz; CMOS <0.4 THz) and below optical sources, so generation/detection
is the bottleneck; if f > fmax, harmonic mixers (LO at f/N, multiplied up)
are needed. THz is useful because it penetrates non-conductive materials,
is non-ionizing, gives molecular spectral fingerprints, and (wide bandwidth)
gives fine depth resolution. Far-field (Fraunhofer) distance R_f = 2D²/λ —
at THz, high-gain antennas easily sit inside the near field. Heterodyne
mixer hierarchy for radiometry: SIS (~4K, most sensitive, ≤1.2 THz), HEB
(~4K, >1 THz, broadband), Schottky (20-300K, least sensitive, room-T
capable — commercial front ends). Shannon: C = BW·log2(1+SNR) motivates
going to THz for 6G bandwidth (IEEE 802.15.3d: 44 GHz contiguous band at
252-296 GHz).

### Lecture 3 — LoS far-field communications, briefly

Capacity C ≈ BW·n·log2(1+SNIR): bandwidth and spatial streams (n) are the
6G enablers. Friis with fixed *physical apertures* (not fixed gain): P_rx =
(P_tx/λ²R²)·A_eff_tx·A_eff_rx — since gain G = 4πA_eff/λ², received power
actually *grows* with frequency at fixed aperture size. Fly's-Eye stadium
case study: 80,000 users need 12 Tbps; full digital multiplexing needs ~80
dBm (infeasible), one-beam-per-user hardware multiplexing needs only ~-20
dBm but no reconfigurability — the chosen SDMA/FDMA/TDD compromise reaches
12 Tbps with 1500 beams at 37 W total (vs 1.6 kW / 40 Gbps for a
conventional 2+5 GHz stadium system). Observable-field theory: ideal
receive antenna = Huygens pattern × Airy pattern; bounds the max effective
area achievable from a given physical aperture size.

### Lecture 4 — LoS near-field / quasi-optical links, briefly

At high f, high-gain antennas often operate inside the radiative near field
(R_f = 2D²/λ can be hundreds of metres). There, Friis becomes unphysical
(predicts P_rx > P_tx); a focusing aperture (quadratic-phase current
distribution) recovers the Friis value even deep in the near field. When
*both* antennas are in each other's near field, conjugate-matched
Gaussian/PSWF-apodized apertures push coupling efficiency toward ~1 (vs
Friis's 1/R² falloff) — near-field links spread only ~1 dB of energy vs
~50 dB for an equivalent far-field link, enabling multi-Gbps links at low
transmit power (demonstrated at 270 GHz).

### Lecture 5 — Radiometry & imaging, briefly

Thermal radiation varies too fast (~1e-15 s) to track directly — radiometers
measure time-averaged power (integration time ~seconds), and incoherent
sources sum in power, not field. Planck's law gives brightness B(f,T);
Rayleigh-Jeans limit (low f) → linear in T; peak frequency f_max[THz] ≈
T[K]/18. Key sensitivity metric NEP (noise-equivalent power); sensitivity
ΔT_min = NEP/(kB·BW_eff·√τ_int) — lower is better. Passive imaging uses
temperature contrast (direct detection); active imaging uses
reflectivity contrast (heterodyne, radar-like, gives range). Three
feed-spacing/sampling regimes trade resolution against sensitivity: power
sampling (0.5λf#, tightest), field sampling (1λf#), max-gain sampling
(2λf#, most sensitive per beam).

## Lab 1 report — material characterization with THz-TDS (what I actually did)

**Setup.** Menlo Systems THz-TDS spectrometer, ScanControl 1.3.3. Emitter
and detector PCA fibre-coupled to the laser unit; four TPX50 lenses on a
450 mm rail — lenses 1 & 4 collimate at the antennas, lenses 2 & 3 form an
intermediate focus at the pinhole (carrier positions 35/70/190/245/305/400/
435 mm) where samples are placed. Aligned by maximizing detector current
lens-by-lens; final aligned pulse peaks at 2.89 a.u. at t=43.9 ps. Every
scan: 100 ps delay window in 33.3 fs steps.

**Assignment 1 — averaging study.** Measured spectral dynamic range (peak
minus noise floor) at N = 1, 50, 100, 1000 averages:

| N | σ_t (a.u.) | floor (dB) | DR (dB) | ΔDR meas. | 10·log10(N) predicted |
|---|---|---|---|---|---|
| 1 | 1.88e-3 | -24.9 | 59.6 | 0.0 | 0.0 |
| 50 | 4.57e-4 | -41.8 | 76.5 | 16.9 | 17.0 |
| 100 | 3.65e-4 | -44.3 | 78.9 | 19.3 | 20.0 |
| 1000 | 4.43e-4 | -54.6 | 89.3 | 29.7 | 30.0 |

The white-noise model (10·log10 N) holds within 0.7 dB. But the *time-domain*
pre-pulse standard deviation stops improving past N=100 (plateaus near
4.4e-4) because a coherent baseline structure repeats identically in every
sweep — averaging removes white noise, not something reproducible every
shot; what it actually buys is usable bandwidth (signal stays above the
noise floor out to ~4.2 THz at N=1000 vs ~3.5 THz at N=1). The FFT pipeline
used for analysis reproduces the instrument's own exported FFTs within 0.12
dB rms (0.1-2 THz), validating the processing chain.

**Method — permittivity and loss extraction.** Every slab measurement is
differential: a reference scan E_ref(t) (no sample) and a sample scan
E_sam(t), combined as H(f) = E_sam(f)/E_ref(f). The N=100 trace from
Assignment 1 serves as the reference. Permittivity comes directly from the
pulse's extra time delay: the slab replaces a thickness d of air, delaying
the pulse by τ_dif = (n-1)d/c0, so εr = n² follows from inverting that
(scan step is 33.3 fs, so timing error is negligible next to thickness
uncertainty). Loss tangent comes from a transmission-line model of the slab
between two air lines (impedance Z_s = Z0(1+j·tanδ/2)/√εr), including the
Fabry-Pérot etalon of the slab's two faces; tan δ(f) is swept until the
modelled |H(f)| matches the measured one (grid search, since a bracketing
minimizer stalls on thick/lossy slabs). If a slab's internal echo (arrives
2nd/c0 after the main pulse) falls outside the 100 ps scan window (slabs 1
and 3), the model is reduced to a single-transit (Fresnel transmission)
approximation instead.

**Assignment 2 — six slabs identified:**

| Slab | d (mm) | εr | tanδ (0.5/1 THz) | dB/λ | Material | deviation |
|---|---|---|---|---|---|---|
| 1 | 7.5 | 1.69 | 0.0006/0.0010 | 0.02 | porous PTFE (nearest table: Gore-Tex) | +25.2% |
| 2 | 3.08 | 1.31 | 0.0019/0.0026 | 0.05 | Gore-Tex | -3.1% |
| 3 | 4.8 | 7.66 | 0.0056/0.0131 | 0.15 | Ceramic | +1.5% |
| 4 | 0.525 | 11.72 | 0.0531/0.0138 | 1.45 | Silicon | -1.5% |
| 5 | 0.525 | 11.66 | 0.0075/0.0028 | 0.20 | Silicon | -2.1% |
| 6 | 2.04 | 2.05 | 0.0048/0.0082 | 0.13 | Teflon | -2.2% |

Five of six match the reference table within 3.1%. Where the etalon ripple
is strong (the silicon wafers, face reflection Γ≈0.55), its period gives an
independent εr cross-check (11.98 and 11.71 vs delay-based 11.72/11.66,
within 2.2%) — for the low-contrast polymers the ripple is too weak for this
cross-check to be meaningful.

**Silicon resistivity check.** Both wafers have the same index (n = 3.423
and 3.414, within 0.3% of the literature 3.418 for high-resistivity
silicon) but very different loss. Conduction loss makes tan δ = σ/(ωε0εr)
scale as 1/f — exactly the slope measured below 1.5 THz. Converting the
median conductivity to resistivity gives 37 Ω·cm for slab 5, against a
labelled 33 Ω·cm from an independent four-point-probe measurement (within
12%) — a useful end-to-end validation of the whole loss-extraction chain.
Slab 4 comes out at 9 Ω·cm (more heavily doped, lossier).

**Slab 2 thickness conflict.** The data file is named "Slab2_0.8" but the
physical sample is labelled t = 3.08 mm. The delay alone can't decide
(0.8 mm ⇒ εr = 2.44, HDPE-like; 3.08 mm ⇒ εr = 1.31, Gore-Tex-like). Three
independent tests all reject 0.8 mm: the |H| fit residual is three times
worse (0.041 vs 0.014), the ~10% ripple at 120 GHz that an 0.8 mm slab would
produce is absent from the measurement, and the internal echo predicted at
+8.3 ps (≈0.13 a.u.) simply isn't there (residual stays below 0.011 a.u.).
Conclusion: d = 3.08 mm, material is Gore-Tex; the file name is either a
different sample or a typo.

**Slab 1 anomaly.** εr = 1.69 falls between Gore-Tex (1.35) and Teflon
(2.10), 25% from the nearest table entry — the largest deviation of the six.
The extraction itself isn't suspect (largest delay of the polymer slabs,
least sensitive to timing error; tan δ ≈ 1e-3, the lowest loss measured).
Best explanation: a porous PTFE of intermediate density — expanded PTFE
spans roughly εr 1.2 to bulk 2.1 depending on air fraction, and the
supplied table only lists one specific density. Orientation arrows printed
on the disc hint it may be an engineered, possibly anisotropic material.

**Conclusion.** The aligned spectrometer reaches 89.3 dB dynamic range at
N=1000, tracking the 10·log10(N) prediction to within 0.7 dB, while the
time-domain floor is limited to ~4e-4 by coherent (non-averaging) structure.
The delay-plus-transmission-line method identified five of six slabs within
3.1% of reference values, reproduced a wafer's labelled resistivity within
12%, and independently settled a real metadata conflict (slab 2) using the
etalon ripple and a missing internal echo — i.e. the same physics that
measures εr and tan δ also catches a labelling error and cross-validates
against an unrelated measurement technique (four-point probe).
