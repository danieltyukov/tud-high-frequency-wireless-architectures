# Oral exam, Time-Domain topic (EE4730)

10-minute presentation for the oral exam (6-8 July 2026), linking the Lecture 2
theory (photoconductive antennas, stroboscopic sampling, SNR and averaging) to
the Lab 1 measurements (THz-TDS material characterization of six slabs).

## Files

- `EE4730_Oral_Exam_TimeDomain_Daniel_Tyukov_5714699.pptx` - the deck, built on
  the TU Delft corporate template. Speaker notes are embedded per slide.
- `EE4730_Oral_Exam_TimeDomain_Daniel_Tyukov_5714699.pdf` - PDF export.
- `speech_notes.md` - the same speaker notes with per-slide timing, ~9.5 min total.
- `build_deck.py` - regenerates the pptx from the template, the lab 1 analysis
  figures and the images in `assets/`.
- `inject_notes.py` - copies `speech_notes.md` into the pptx notes pane.
- `assets/` - cropped lecture diagrams (from the notes vault attachments) and
  EXIF-flattened lab photos used on the slides.

## Rebuild

```
python3 build_deck.py
python3 inject_notes.py
soffice --headless --convert-to pdf EE4730_Oral_Exam_TimeDomain_Daniel_Tyukov_5714699.pptx --outdir .
```

## Slide map

1. Title
2. Why measure in the time domain (THz gap, heterodyne vs photoconductive)
3. The photoconductive antenna (LT-GaAs, emitter vs receiver, saturation)
4. Stroboscopic sampling (delay line, DC readout)
5. Noise: what the lecture predicts (SNR budget, 10 log N)
6. The lab bench (rail, TPX50 lenses, ScanControl settings)
7. Averaging measured against the prediction (Assignment 1)
8. Extracting permittivity and loss (delay + transmission-line fit)
9. Six slabs identified (results table)
10. Transfer function fits (etalon ripple)
11. The slab 2 thickness conflict (0.8 vs 3.08 mm, three tests)
12. Silicon wafers: same index, different loss (resistivity check)
13. What this lab showed
14. Closing
