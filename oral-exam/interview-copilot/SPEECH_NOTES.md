# Slide-by-slide reference — EE4730 oral exam, Time-Domain topic

Answer in one sentence (see `CONTEXT.md`). When a question names a slide
number, use its section below. "On slide" is the literal on-slide text;
"Key fact" is the single number/claim to lead with if asked cold.

## Slide 1 — Title

**On slide:** Time-Domain Systems and THz Material Characterization. EE4730
Oral Exam, Time-Domain Topic, Daniel Tyukov, July 2026.
**Key fact:** Topic is a photoconductive THz time-domain spectrometer used to
identify six unknown dielectric slabs.

## Slide 2 — Why measure in the time domain

**On slide:** THz band (0.3-3 THz) sits above transistor fmax (~0.75 THz
record) and below optical sources — generation/detection is the hard part.
Two generation paradigms: multiply a microwave oscillator up (heterodyne), or
switch a DC bias with a femtosecond laser (photoconductive). Photoconductive
gives one picosecond pulse whose spectrum covers the whole band at once;
measure E(t), FFT, one scan characterizes a material from 0.15 to 3 THz.
Table — Heterodyne: LO chain xN, CW tone, ~30 GHz BW, used in VNA labs.
Photoconductive: fs laser + DC bias, ps pulse, up to ~2 THz BW, used in this
lab.
**Key fact:** One photoconductive scan + FFT covers 0.15-3 THz in a single
measurement; heterodyne only reaches ~30 GHz per tone.

## Slide 3 — The photoconductive antenna

**On slide:** LT-GaAs gap between two electrodes, 1.59 eV band gap matches
780 nm pump. fs pulse creates carriers → DC bias accelerates them →
recombination cuts current after ~1 ps → that burst radiates the THz pulse.
Photocurrent model has exactly three ingredients: Gaussian carrier
generation, Drude acceleration, exponential recombination (τc). Receiver is
the same device with no bias — incident field accelerates carriers, so gated
current ∝ field at the instant of illumination. At high optical power the
radiated field screens the bias and photocurrent saturates → motivates PCA
arrays for higher power.
**Key fact:** Three physics ingredients — generation, acceleration,
recombination (τc ≈ 1 ps) — and saturation vs optical power is why
high-power sources use PCA arrays, not one bigger PCA.

## Slide 4 — Stroboscopic sampling

**On slide:** No ADC samples THz directly (electronics top out at a few
GS/s). Laser fires an identical pulse every 10 ns (100 MHz rep rate);
receiver gap only conducts during the ps it's illuminated, so each repetition
samples the field at one delay. A motorized mirror sweeps the delay (1 mm of
travel = 6.67 ps round trip). Readout is a DC average current irec(Δt) ∝
field at the gate instant; sweeping Δt reconstructs E(t).
**Key fact:** The trick is that a DC current meter reconstructs a
femtosecond-resolution waveform, one delay per laser shot, because the
receiver only ever "looks" during a picosecond gate.

## Slide 5 — Noise: what the lecture predicts

**On slide:** 1 mW average power at 100 MHz rep → 10 pJ/pulse, ~20 W peak.
Link efficiency ~1/10 → receiver burst ~0.14 A for 0.5 ps. Duty cycle dilutes
it: iave = ipeak·τrec/Trep ≈ 7 µA DC at the amplifier. Amplifier noise ~70
pA → single-sweep SNR ≈ 100 dB. Averaging N sweeps: SNR_N = SNR_1 +
10·log10(N). Predictions: N=50 → +17.0 dB, N=100 → +20.0 dB, N=1000 → +30.0
dB — exactly what Assignment 1 tests.
**Key fact:** Predicted averaging gains are 17 / 20 / 30 dB at N = 50 / 100 /
1000, from the 10·log10(N) white-noise law.

## Slide 6 — The lab bench

**On slide:** Both PCAs fibre-coupled to the Menlo unit. Lenses 1 and 4
collimate at the antennas; lenses 2 and 3 focus at the pinhole where samples
go (rail carriers at 35/70/190/245/305/400/435 mm). Aligned by maximizing
detector current lens-by-lens; aligned pulse peaks at 2.89 a.u. Every scan:
100 ps delay window, 33.3 fs steps, Tukey window (α=0.1) in ScanControl.
**Key fact:** Aligned by maximizing detector current one lens at a time,
final peak amplitude 2.89 a.u., every scan is 100 ps in 33.3 fs steps.

## Slide 7 — Averaging measured against the prediction

**On slide:** Dynamic range grows from 59.6 dB (N=1) to 89.3 dB (N=1000):
gains of 16.9/19.3/29.7 dB against predicted 17/20/30 dB — the white-noise
law holds within 0.7 dB. Time trace saturates: past N=100 the pre-pulse floor
sticks near 4e-4 of the peak because a coherent baseline structure repeats
every sweep; averaging only buys bandwidth where the noise is white.
**Key fact:** Measured averaging gains (16.9/19.3/29.7 dB) matched the
10·log10(N) prediction within 0.7 dB, but the time-domain noise floor
saturates near 4×10⁻⁴ because coherent structure doesn't average down.

## Slide 8 — Extracting permittivity and loss

**On slide:** Differential measurement: reference scan (no sample) and
sample scan, ratio H(f) = Esam(f)/Eref(f); N=100 trace is the reference.
Delay gives permittivity: slab replaces thickness d of air, pulse arrives
Δτ=(n−1)d/c0 later, εr = n². Loss from spectrum: model slab as a
transmission-line section between air lines, fit tan δ(f) until modelled |H|
matches measurement. Model includes the Fabry-Perot etalon of the slab
faces; if the internal echo falls outside the 100 ps window (slabs 1 and 3),
only the first transit is kept.
**Key fact:** Permittivity comes from the pulse's arrival-time delay; loss
tangent comes from fitting a transmission-line model to the measured
transfer function H(f), etalon ripple included.

## Slide 9 — Six slabs identified

**On slide:** Table — Slab 1: 7.5 mm, εr 1.69, tanδ 0.0010, porous PTFE*.
Slab 2: 3.08 mm, εr 1.31, tanδ 0.0026, Gore-Tex. Slab 3: 4.8 mm, εr 7.66,
tanδ 0.0131, Ceramic. Slab 4: 0.525 mm, εr 11.72, tanδ 0.0138, Silicon. Slab
5: 0.525 mm, εr 11.66, tanδ 0.0028, Silicon. Slab 6: 2.04 mm, εr 2.05, tanδ
0.0082, Teflon. Five of six match the reference table within 3.1%. Slab 3
arrives 28 ps late and heavily attenuated; the silicon wafers show their
etalon echo 12 ps after the main pulse. *Slab 1 sits between Gore-Tex and
Teflon — porous PTFE of intermediate density.
**Key fact:** Five of six slabs identified within 3.1% of reference values —
two silicon wafers, a ceramic, Teflon, and Gore-Tex; slab 1 is the outlier.

## Slide 10 — Transfer function fits

**On slide:** The fit reproduces both level and etalon ripple; on silicon the
ripple period c0/(2nd) ≈ 83 GHz pins the optical thickness independently of
the delay measurement.
**Key fact:** The silicon etalon ripple period (~83 GHz) cross-checks the
permittivity independently of the delay-based measurement.

## Slide 11 — The slab 2 thickness conflict

**On slide:** Data file says 0.8 mm, holder label says 3.08 mm. Delay alone
can't decide — both give a plausible material (εr = 2.44, HDPE-like, vs 1.31,
Gore-Tex-like). Three independent tests reject 0.8 mm: fit residual is three
times worse (0.041 vs 0.014), the required ±10% ripple at 120 GHz is absent,
and the predicted internal echo at +8.3 ps (0.13 a.u.) doesn't exist in the
residual. Conclusion: d = 3.08 mm, slab is Gore-Tex; the file name recorded a
different sample or a typo.
**Key fact:** Three independent checks — fit residual, missing 120 GHz
ripple, missing +8.3 ps echo — all reject the 0.8 mm file name in favour of
the 3.08 mm label.

## Slide 12 — Silicon wafers: same index, different loss

**On slide:** Both wafers give n ≈ 3.42, within 0.3% of the literature value
for high-resistivity silicon; the etalon ripple period confirms permittivity
independently. Loss differs by an order of magnitude: conduction loss gives
tan δ = σ/(ω·ε0·εr), so constant conductivity looks like a 1/f slope — the
measured behaviour below 1.5 THz. Converting wafer 5's median conductivity to
resistivity gives 37 Ω·cm against a labelled 33 Ω·cm (four-point-probe): an
independent end-to-end check. Wafer 4 comes out at 9 Ω·cm, more doped and
lossier.
**Key fact:** Same refractive index (n≈3.42) but different loss — wafer 5's
extracted resistivity (37 Ω·cm) matches its labelled 33 Ω·cm within 12%.

## Slide 13 — What this lab showed

**On slide:** Stroboscopic sampling works as taught — a DC photocurrent
measurement reconstructs the THz field with 33 fs steps. Averaging law
holds: 29.7 dB measured vs 30 dB predicted at N=1000, but cannot remove
coherent structure (the time-domain floor shows exactly that). One delay
reading plus a transmission-line fit identified five of six materials within
3.1%. The same physics settles a metadata conflict (slab 2) and reproduces a
wafer's labelled resistivity within 12%.
**Key fact:** Four takeaways — sampling works, averaging law holds to
coherent-noise limits, material ID to 3.1%, and the same method catches bad
metadata and cross-checks resistivity.

## Slide 14 — Closing

**On slide:** Thank you. Time-Domain topic, Daniel Tyukov, EE4730 oral exam.
**Key fact:** Closing slide — invite questions.
