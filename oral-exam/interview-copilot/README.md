# Interview-copilot context — EE4730 oral exam (Time-Domain, Lab 1)

**Rule: every answer is ONE sentence, spoken out loud during a live oral
defense.** See `CONTEXT.md` for the full rule and answering instructions —
it is read in full by the copilot, so keep it in this folder untouched.

## What this folder is for

Point Sparky (`interview-copilot`) at this directory during the EE4730 oral
exam so it can draft one-sentence, first-person answers grounded in the
actual slides, the course theory, and the Lab 1 measurement I ran.

```
interview-copilot "/home/danieltyukov/workspace/tud/tud-high-frequency-wireless-architectures/oral-exam/interview-copilot"
```

The default `--context-budget 60000` is plenty; no flags needed. Run
`interview-copilot --print-context <this dir>` first if you want to sanity
check exactly what gets sent to the model before the exam.

## Files

| File | Purpose |
|---|---|
| `CONTEXT.md` | The one-sentence rule + how to map slide numbers to answers. Read this one first. |
| `SPEECH_NOTES.md` | Every slide (1-14): what's on it, and its single most quotable fact/number. |
| `NOTES.md` | Condensed course theory (Lecture 2 physics in depth, Lectures 1/3/4/5 briefly) and the condensed Lab 1 report (method, both assignments, results, resolved conflicts). |

Source materials these were built from (kept one directory up, not read
directly by the copilot):
- `../EE4730_Oral_Exam_TimeDomain_Daniel_Tyukov_5714699.pptx` / `.pdf` — the
  actual slide deck.
- `/home/danieltyukov/workspace/tud/tud-notes/Q4/EE4730/High Frequency Wireless Architectures.md` — full course theory notes.
- `../../lab1/report/report.pdf` (source: `report.tex`) — the Lab 1 report I
  wrote and am defending.

## Slide map

| # | Title | One-line hook |
|---|---|---|
| 1 | Title | Time-domain topic: photoconductive spectrometer + six unknown slabs. |
| 2 | Why measure in the time domain | THz gap; heterodyne vs photoconductive; one scan + FFT covers 0.15-3 THz. |
| 3 | The photoconductive antenna | LT-GaAs gap, 1.59 eV / 780 nm, generation-acceleration-recombination, saturation → arrays. |
| 4 | Stroboscopic sampling | 100 MHz laser samples one delay per pulse; DC readout reconstructs E(t). |
| 5 | Noise: what the lecture predicts | Back-of-envelope SNR ≈100 dB single-shot; averaging law 10·log10(N). |
| 6 | The lab bench | Menlo rail, 4 TPX50 lenses, alignment peak 2.89 a.u., 100 ps / 33.3 fs scans. |
| 7 | Averaging measured vs prediction | 59.6→89.3 dB dynamic range; gains within 0.7 dB of 10·log10(N); time-domain floor saturates. |
| 8 | Extracting permittivity and loss | Differential H(f), delay → εr, transmission-line fit → tan δ. |
| 9 | Six slabs identified | 5 of 6 match reference table within 3.1%. |
| 10 | Transfer function fits | Silicon etalon ripple ≈83 GHz pins optical thickness. |
| 11 | The slab 2 thickness conflict | 0.8 vs 3.08 mm — three tests settle it at 3.08 mm (Gore-Tex). |
| 12 | Silicon wafers: same index, different loss | n≈3.42 both; resistivity 37 vs labelled 33 Ω·cm. |
| 13 | What this lab showed | Stroboscopic sampling, averaging law, material ID, metadata + resistivity checks. |
| 14 | Closing | Thank you / questions. |

Full detail for each slide lives in `SPEECH_NOTES.md` under the matching
`## Slide N` heading.
