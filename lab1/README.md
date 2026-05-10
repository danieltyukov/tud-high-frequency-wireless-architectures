# Lab 1 — Time Domain Spectroscopy (EE4730)

THz Time-Domain Spectroscopy lab. Two assignments: align the THz beam path, then characterize six dielectric slabs.

## Directory layout

```
lab1/
├── Time Domain Lab 2026.pdf             — official lab manual
├── README.md                             — this file
├── Assignment Data/
│   ├── Assignment1/                      — beam alignment + sampling sweep
│   │   ├── Assignment1_calibration.{txt,png}      (no _fft.txt — MISSING)
│   │   ├── Assignment1_50sampling.{txt,png}       + Assignment1_50sampling_fft.txt
│   │   ├── Assignment1_100sampling.{txt,png}      + Assignment1_100sampling_fft.txt
│   │   └── Assignment1_1000sampling.{txt,png}     (no _fft.txt — MISSING)
│   └── Assignment2/                      — six dielectric slabs
│       ├── Slab1_7.5.{txt,png}           + Slab1_7.5_fft.txt
│       ├── Slab2_0.8.{txt,png}           + Slab2_0.8_fft.txt
│       ├── Slab3_4.8.{txt,png}           + Slab3_4.8_fft.txt
│       ├── Slab4_525u.{txt,png}          + Slab4_525u_fft.txt
│       ├── Slab5_525u.{txt,png}          + Slab5_525u_fft.txt
│       └── Slab6_2.04.{txt,png}          + Slab6_2.04_fft.txt
└── pics/
    ├── samples/   — slab close-ups and slabs in the beam path
    └── setup/     — alignment, antennas, and full beam-path photos
```

Data file format (Menlo Systems ScanControl, Program v1.3.3):
- `*.txt` — two columns: `Time [ps]` vs `THz Signal [a.u.]`, recorded over a delay window starting at −327 ps. Header records averaging count and a Tukey window (α = 0.1).
- `*_fft.txt` — two columns: `Frequency [THz]` vs `THz Signal [a.u.]` (already log-scale-ish dB-like values).
- `*.png` — preview plots from ScanControl.

## Assignment 1 — Beam Alignment & Sampling

The THz path is aligned through 4 polymer (TPX50) lenses on a 450 mm rail (Emitter @ 35 mm → TPX50 @ 70 mm → TPX50 @ 190 mm → Pinhole @ 245 mm → TPX50 @ 305 mm → TPX50 @ 400 mm → Detector @ 435 mm). The four datasets compare the effect of waveform averaging:

| File                              | Averages | Purpose                          |
| --------------------------------- | -------- | -------------------------------- |
| `Assignment1_calibration`         | 1        | Reference E_ref(t), no averaging |
| `Assignment1_50sampling`          | 50       | SNR comparison                   |
| `Assignment1_100sampling`         | 100      | SNR comparison                   |
| `Assignment1_1000sampling`        | 1000     | SNR comparison                   |

## Assignment 2 — Dielectric Characterization

Six samples placed at the pinhole position. The number after the underscore in each filename is the slab thickness:

| Slab | Thickness     | Geometry / Notes                                                              |
| ---- | ------------- | ----------------------------------------------------------------------------- |
| 1    | 7.5 mm (data) | Round white disc with orientation arrows (label partially obscured in photo)  |
| 2    | 0.8 mm (data) | Square white slab — **photo label reads `t = 3.08 mm`, see discrepancy below** |
| 3    | 4.8 mm        | Square white slab, clearly labeled                                             |
| 4    | 525 µm        | Silicon wafer (~3″ round), no resistivity printed                              |
| 5    | 525 µm        | Silicon wafer, marked **ρ = 33 Ω·cm** → high-resistivity Si                    |
| 6    | 2.04 mm       | Round white disc                                                               |

**Data → photo mapping** (after renaming):

| Slab | Photos in `pics/samples/`                                                                               |
| ---- | ------------------------------------------------------------------------------------------------------- |
| 1    | `slab1_round_white_orientation_arrows.jpeg`, `slab1_round_white_in_beam_setup.jpeg`                     |
| 2    | `slab2_label_t3.08mm_holder.jpeg`, `slab2_in_beam_3.08mm.jpeg`                                          |
| 3    | `slab3_label_4.8mm_closeup.jpeg`, `slab3_in_beam_4.8mm.jpeg`, `slab3_in_beam_4.8mm_v2.jpeg`             |
| 4    | `slab4_silicon_wafer_525um.jpeg`                                                                        |
| 5    | `slab5_silicon_wafer_525um_rho33ohmcm.jpeg`                                                             |
| ?    | `slab_silicon_wafer_resistivity_label.jpeg` (Si wafer, resistivity label visible — likely slab 4 or 5)  |
| 6    | `slab6_label_2.04mm_front.jpeg`, `slab6_label_2.04mm_angled.jpeg`, `slab6_in_beam_2.04mm.jpeg`          |

### ⚠ Discrepancy to verify

The data filename `Slab2_0.8` says **0.8 mm**, but the photo of the slab labeled ② clearly shows **t = 3.08 mm**. Three possibilities:
1. The data file was named with a different thickness convention.
2. The photo and the data refer to different physical samples.
3. One of them is mislabeled.

**Action**: cross-check with the lab notebook before running the extraction. Use the photo's thickness (3.08 mm) for slab 2 unless the notebook says otherwise.

## Reference table (Appendix A of the manual)

| Material  | εᵣ    |
| --------- | ----- |
| Silicon   | 11.90 |
| GaAs      | 12.40 |
| HDPE      | 2.30  |
| Teflon    | 2.10  |
| Gore-Tex  | 1.35  |
| Polyamide | 3.40  |
| Ceramic   | 7.55  |

The wafers (slabs 4–5) are clearly Si (εᵣ ≈ 11.90). Slabs 1, 2, 3, 6 are some mix of HDPE / Teflon / Gore-Tex / Polyamide / Ceramic — to be identified from the extracted εᵣ.

## What's still needed for this lab

1. **Verify slab 2 thickness** — resolve the 0.8 mm vs 3.08 mm discrepancy from the lab notebook.
2. **Generate the two missing FFTs** — `Assignment1_calibration_fft.txt` and `Assignment1_1000sampling_fft.txt` are not in the data folder. The first is needed if calibration is used as E_ref(ν); the second is the highest-SNR trace and the natural reference choice. (Slab1_7.5_fft.txt **is** present.)
3. **Pick the reference signal** — typically the highest-SNR Assignment 1 trace (`1000sampling`) is used as E_ref(t). Decide and document this choice.
4. **Compute εᵣ for each slab** using the standard TDS extraction:

   - Time delay between the reference peak and the sample peak gives the refractive index:

         n  =  1  +  c · Δt / d

     where d is the slab thickness, c the vacuum speed of light, and Δt the peak-to-peak delay.

   - Frequency-domain transfer function H(ν) = E_sam(ν) / E_ref(ν) gives both n(ν) and the absorption coefficient α(ν):

         n(ν)  =  1  +  c · Δϕ(ν) / (2π ν d)

         α(ν)  =  −(2/d) · ln[ |H(ν)| · (n+1)² / (4n) ]

   - Then εᵣ ≈ n² (real part), and the loss tangent tan δ ≈ α · c / (ν · π · n).

5. **Identify each slab** by matching extracted εᵣ to Appendix A.
6. **Compare averaging cases** — quantify SNR improvement going from 50 → 100 → 1000 averages (e.g., noise floor in dB on the FFT plots).
7. **Write up the report** with: (a) alignment photos + final pulse, (b) sampling-vs-SNR plot, (c) table of εᵣ, α, and identified material per slab, (d) FFT comparisons.
