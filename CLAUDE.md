# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Coursework repository for TU Delft EE4730 (High-Frequency Wireless Architectures): raw measurement data, lab manuals (PDFs), setup photos, and analysis notes for three lab sessions. There is no build system, linter, or test suite — the deliverables are two lab reports (see `delivarables.txt`, note the misspelled filename). Work here is data analysis (MATLAB/Python) and report writing.

**Never modify or regenerate the raw measurement files** (`.txt`, `_fft.txt`, `.s2p`, `.mat`) — they are one-time instrument captures that cannot be re-taken.

## Structure

- `lab1/` — THz Time-Domain Spectroscopy lab. `lab1/README.md` is the authoritative reference: directory layout, slab-to-photo mapping, the εᵣ reference table, the extraction formulas (n, α, tan δ), and a list of open issues (slab 2 thickness discrepancy 0.8 mm vs 3.08 mm; two missing FFT files). Read it before doing any lab 1 analysis.
- `lab2/`, `lab3/` — Communications lab parts 1 and 2 (waveguide/horn link, then lens antennas). Contain the lab manual PDFs and descriptively named setup photos only.
- `Lab2&3_Com_2026_G2/` — measurement data for labs 2–3 (group G2). The `&` in the directory name must be quoted in shell commands.

## Data formats

- `lab1/**/*.txt` — Menlo Systems ScanControl time-domain traces: 5 header lines starting with `#`, then two columns (Time [ps], THz signal [a.u.]). `*_fft.txt` are the matching spectra (Frequency [THz] vs dB-like amplitude). `*.png` are ScanControl preview plots.
- `read_TD_file.m` — MATLAB loader for those traces. Its `fscanf` does **not** skip the `#` header lines (the comment says to delete them first); strip or skip the header when loading.
- `*.s2p` — Touchstone 2-port S-parameters from a Keysight N5224B PNA: 140–220 GHz (G-band, WR-5.1 waveguide), 801 points, dB/angle format, 50 Ω. Filename suffixes encode the antenna pair and separation distance (e.g. `Lens2Lens_11p5cm` = 11.5 cm, `Horn2Horn_10p5`, `Horn2probe_17p6`).
- `*.mat` — MATLAB measurement exports for the same lab 2–3 setups.

## Conventions

- Photos use descriptive snake_case names stating subject and viewpoint (e.g. `tx_rx_waveguide_ports_aligned_front_view.png`, `slab5_silicon_wafer_525um_rho33ohmcm.jpeg`). Keep this scheme when adding images; lab 1 photos are sorted into `pics/setup/` vs `pics/samples/`.
- Math notation rules for all writing live in the parent `../CLAUDE.md` (Unicode symbols, no LaTeX delimiters).
