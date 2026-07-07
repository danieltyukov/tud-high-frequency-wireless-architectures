# Speech notes, EE4730 oral exam, Time-Domain topic

Total is under 4 minutes of scripted content, meant as memory cues, not a
script to read verbatim, leaving most of the 10-minute slot for natural
delivery, pointing at figures, and questions. Times per slide are a guide,
not a rule.

## Slide 1, title (5 s)

Good morning, I'm Daniel Tyukov. Topic: time-domain, the photoconductive
spectrometer, and identifying six unknown dielectric slabs.

## Slide 2, why measure in the time domain (15 s)

THz sits above transistors, below optical sources. Two routes: multiply a
microwave oscillator up, clean tone but ~30 GHz bandwidth; or DC-bias a
femtosecond laser, one-ps pulse, whole band. One scan, one FFT: 0.15-3 THz.

## Slide 3, the photoconductive antenna (25 s)

PCA: LT-GaAs gap between two electrodes. 1.59 eV gap, 780 nm pump. Laser
creates carriers, bias accelerates, recombination kills current after ~1 ps,
that burst radiates the pulse. Three ingredients: generation, acceleration,
recombination. Receiver: same device, no bias; current proportional to field
at that instant. High power: field screens bias, saturates, hence PCA
arrays.

## Slide 4, stroboscopic sampling (20 s)

Electronics top out at Gsamples/s, not THz. Laser fires an identical pulse
every 10 ns; receiver conducts only during the ps it's lit, one delay per
repetition, set by a motorized mirror (1 mm = 6.67 ps). Readout: DC current
proportional to field, so sweeping delay rebuilds the waveform.

## Slide 5, noise prediction (20 s)

1 mW at 100 MHz = 10 pJ/pulse, ~20 W peak. 10x link loss gives ~0.14 A burst
for 0.5 ps, duty-cycle averaged to ~7 μA DC. Against 70 pA noise, ~100 dB in
one sweep. Averaging: +10 log N, 17 dB at 50, 30 dB at 1000.

## Slide 6, the lab bench (15 s)

Emitter right, detector left, fibre-coupled to Menlo unit. Four TPX lenses:
outer pair collimates at antennas, inner pair focuses at the pinhole.
Aligned lens by lens, peak 2.89. Scan: 100 ps window, 33 fs steps.

## Slide 7, averaging measured (15 s)

Prediction holds: 60 dB unaveraged to 89 dB at 1000 averages. Measured
16.9/19.3/29.7 dB vs 17/20/30 predicted, within 0.7 dB. Past 100 averages,
pre-pulse floor plateaus, coherent baseline repeats every sweep. What
averaging really buys: bandwidth.

## Slide 8, extraction method (20 s)

Every measurement is differential, scan without sample, scan with, take the
ratio. Delay gives permittivity directly. Loss: model the slab as a
transmission-line section, fit tan delta per frequency to match the transfer
function, including the face etalon. Two thick slabs: echo falls outside the
scan window, keep first transit only.

## Slide 9, six slabs identified (15 s)

Six slabs, delays 1.5-28 ps. Matched to the manual: two silicon wafers, a
ceramic, Teflon, Gore-Tex, five of six within ~3%. Slab one is the outlier,
likely porous PTFE, intermediate density.

## Slide 10, transfer function fits (10 s)

Ripple on the silicon wafers is the face etalon, period ~83 GHz, model
reproduces it and pins the optical thickness independently of delay.

## Slide 11, the slab 2 conflict (20 s)

Slab 2's file says 0.8 mm, sample labelled 3.08. Delay alone can't decide.
Three checks reject 0.8: fit residual 3x worse, expected ripple absent,
predicted echo at 8.3 ps after the main pulse absent. So: 3.08 mm Gore-Tex,
file name was wrong.

## Slide 12, silicon wafers (15 s)

Two wafers: same index, 3.42, within 0.3% of literature, very different
loss. Conduction loss: tan delta scales as 1/f, matches slope below 1.5 THz.
Resistivity: wafer 5 = 37 Ω·cm vs labelled 33, within 12%. Wafer 4 ≈ 9, more
doped.

## Slide 13, takeaways (15 s)

Four things: stroboscopic sampling gives fs resolution from a DC
measurement. Averaging follows 10 log N until coherent structure takes over.
Delay plus transmission-line fit IDs materials to a few percent, and catches
bad metadata along the way.

## Slide 14, closing (5 s)

Thank you. Happy to take questions.
