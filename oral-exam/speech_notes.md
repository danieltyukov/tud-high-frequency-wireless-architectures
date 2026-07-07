# Speech notes, EE4730 oral exam, Time-Domain topic

Total is about 9.5 minutes at a calm pace. Times per slide are a guide, not a rule.

## Slide 1, title (15 s)

Good morning. I'm Daniel Tyukov. I picked the time-domain topic: how a
photoconductive spectrometer works, and how we used one to identify six
unknown dielectric slabs.

## Slide 2, why measure in the time domain (45 s)

The terahertz band is awkward. It sits above what transistors reach and below
what optical sources cover, so making and detecting power there is the whole
problem.

The lectures gave two ways to generate. You can multiply a microwave
oscillator up. Clean tone, but only about thirty gigahertz of bandwidth. Or
you switch a DC bias with a femtosecond laser. That gives one picosecond
pulse that carries the entire band.

So one scan of the field, one FFT, and I can characterize a material from
0.15 to 3 terahertz. That is what this lab does.

## Slide 3, the photoconductive antenna (60 s)

The device behind all of this is the photoconductive antenna. It is a gap of
low-temperature-grown gallium arsenide between two electrodes. The band gap
is 1.59 electron volts, which is exactly why the pump laser sits at 780
nanometres.

The laser pulse creates carriers. The DC bias accelerates them. Recombination
kills the current after about a picosecond. That short burst of current is
what radiates the terahertz pulse.

The lecture model has three ingredients: generation, acceleration,
recombination. Every term in the photocurrent integral is one of those.

The receiver is the same device with no bias. There, the incoming terahertz
field does the accelerating. So the current I read out is proportional to the
field at the instant the laser hits the gap.

One more lecture point: at high laser power the radiated field screens the
bias and the current saturates. That is why power scaling uses PCA arrays.

## Slide 4, stroboscopic sampling (50 s)

Nothing samples a terahertz waveform directly. Electronics stop at a few
gigasamples per second, and we need terahertz.

The trick: the laser fires an identical pulse every ten nanoseconds, and the
receiver only conducts during the picosecond it is lit. Each repetition gives
me one sample of the field, at one delay. A motorized mirror sets that delay.
One millimetre of mirror travel is 6.67 picoseconds.

And the part I find elegant: the readout is a DC measurement. The average
current is proportional to the field at the gate instant, so sweeping the
delay reconstructs the whole waveform, point by point.

## Slide 5, noise prediction (45 s)

Before showing measurements, the lecture arithmetic. One milliwatt average
at a hundred megahertz repetition is ten picojoules per pulse, about twenty
watts peak. Take a factor ten of link loss, and the receiver burst is around
0.14 amps for half a picosecond. The duty cycle waters that down to roughly
seven microamps of DC.

Against seventy picoamps of amplifier noise, that is already about a hundred
dB in a single sweep.

Averaging N sweeps should add ten log N, as long as the noise is white.
Fifty averages, seventeen dB. A thousand, thirty. That is the prediction
Assignment 1 tests.

## Slide 6, the lab bench (35 s)

Here is our bench. Emitter on the right, detector on the left, both
fibre-coupled to the Menlo unit. Four TPX lenses: the outer pair collimates
at the antennas, the inner pair makes a focus at the pinhole position, and
that is where the samples go later.

We aligned by watching the detector current lens by lens. The final pulse
peaked at 2.89. Every scan is a hundred picosecond window in 33
femtosecond steps.

## Slide 7, averaging measured (50 s)

And the prediction holds. Dynamic range goes from about sixty dB with no
averaging to 89 dB at a thousand. The measured gains are 16.9, 19.3
and 29.7 dB, against 17, 20 and 30 predicted. Within 0.7 dB.

The time trace tells the other half of the story. Past a hundred averages the
pre-pulse floor stops improving, because a coherent baseline structure
repeats in every sweep. Averaging removes white noise. It cannot remove
something that is identical every time.

In practice, what averaging buys is bandwidth: the spectrum stays above the
noise floor out to higher frequency.

## Slide 8, extraction method (45 s)

Now the material work. Every slab measurement is differential: one scan
without the sample, one with it, and I work with their ratio.

The delay gives permittivity directly, because the slab replaces a known
thickness of air. One number, one formula.

Loss takes more effort. I model the slab as a transmission-line section
between two air lines, and adjust tan delta at each frequency until the model
matches the measured transfer function. The model includes the etalon of the
slab faces. For the two thick slabs whose internal echo falls outside the
scan window, I keep only the first transit.

## Slide 9, six slabs identified (40 s)

Here are all six. Delays from one and a half up to 28 picoseconds.

Matching the extracted permittivities to the manual's table: two silicon
wafers, a ceramic, Teflon, and Gore-Tex. Five of six land within about three
percent.

Slab one is the odd one out. It sits between Gore-Tex and Teflon, with very
low loss. My reading is porous PTFE of intermediate density; the table just
lists one specific density.

## Slide 10, transfer function fits (25 s)

These are the fits behind those numbers. The thing to look at is the ripple
on the silicon wafers. That is the etalon between the faces, period about 83
gigahertz, and the model reproduces both the period and the amplitude. It
pins the optical thickness independently of the delay.

## Slide 11, the slab 2 conflict (50 s)

One detail I want to walk through, because it shows what this measurement can
do. The data file for slab two says 0.8 millimetres. The sample itself is
labelled 3.08. The delay cannot decide between them; each thickness just
gives a different plausible material.

Three independent checks all reject 0.8. The fit residual is three times
worse. The strong ripple a thin slab would have to produce is not in the
measurement. And the internal echo it predicts, at 8.3 picoseconds after the
main pulse, is simply not in the time trace.

So the slab is 3.08 millimetres of Gore-Tex, and the file name was wrong.

## Slide 12, silicon wafers (45 s)

The two wafers make a nice controlled experiment. Same refractive index,
3.42, within a third of a percent of the literature value. Very different
loss.

For conduction loss, tan delta goes as one over frequency, and that is
exactly the slope we measure below 1.5 terahertz.

Converting to resistivity: wafer five comes out at 37 ohm centimetres, and
the label on that wafer says 33, from a four-point probe. Two completely
different instruments, same answer within twelve percent. Wafer four is
around nine, just a more doped wafer.

## Slide 13, takeaways (30 s)

Four things. Stroboscopic sampling really does turn a DC current measurement
into femtosecond resolution. Averaging follows ten log N until coherent
structure takes over. A delay plus a transmission-line fit identifies
materials to a few percent. And the same fit is strong enough to catch bad
metadata and reproduce an independently measured resistivity.

## Slide 14, closing (10 s)

Thank you. Happy to take questions.
