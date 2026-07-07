# Speech notes, EE4730 oral exam, Time-Domain topic

Total is about 7.5 minutes at a natural speaking pace, leaving buffer in
the 10-minute slot for slide transitions, pointing at figures, and
questions. Times per slide are a guide, not a rule. Each slide keeps the
one or two numbers that carry the result and lets the slide itself show
the rest of the derivation.

## Slide 1, title (10 s)

Good morning, I'm Daniel Tyukov. I picked the time-domain topic: how a
photoconductive spectrometer works, and how we used one to identify six
unknown dielectric slabs.

## Slide 2, why measure in the time domain (35 s)

The terahertz band is awkward: it sits above what transistors reach and
below what optical sources cover. I can multiply a microwave oscillator up
for a clean tone, but that only covers about 30 gigahertz, or I can switch
a DC bias with a femtosecond laser for a single-picosecond pulse that
spans the whole band. One scan, one FFT, and I get a material's response
from about a tenth of a terahertz up to three.

## Slide 3, the photoconductive antenna (55 s)

The device behind all this is the photoconductive antenna, a gap of
low-temperature-grown gallium arsenide between two electrodes. Its band
gap is 1.59 electron-volts, which is why the pump laser sits at 780
nanometres. The laser pulse creates carriers, the bias accelerates them,
and recombination kills the current almost immediately after, and that
short burst is what radiates the pulse: generation, acceleration,
recombination.

The receiver is the same device without a bias, so the incoming field does
the accelerating, and the current I read out follows the field at the
instant the laser fires. At high power the radiated field screens the bias
and the current saturates, which is why scaling up uses arrays instead of
a bigger laser spot.

## Slide 4, stroboscopic sampling (40 s)

Nothing samples a terahertz waveform directly, since ordinary electronics
fall far short of the speeds involved. The trick: the laser fires an
identical pulse every ten nanoseconds, and the receiver only conducts for
the instant it's lit. Each repetition hands me one sample of the field at
one delay, set by a motorized mirror, where every millimetre of travel
works out to about six and a half picoseconds.

The readout itself is just a plain DC measurement, tracking the field at
that one instant, so sweeping the mirror reconstructs the whole waveform
point by point.

## Slide 5, noise prediction (35 s)

Before the measurements, here's the reasoning behind the prediction.
Working through the laser's power, its repetition rate, and the losses
along the path, the receiver's signal comes out with something like a
hundred decibels of headroom above the amplifier's noise floor, in a
single sweep. From there, averaging should improve things by ten times the
log of how many sweeps I combine: about seventeen decibels after fifty,
thirty after a thousand. That's the prediction the next slide tests.

## Slide 6, the lab bench (30 s)

Emitter on the right, detector on the left, both fibre-coupled to the
Menlo unit. Four lenses shape the beam: an outer pair collimates it at the
antennas, an inner pair focuses it at the pinhole, where the samples go
later. I aligned everything watching the detector current lens by lens,
and the pulse peaked at 2.89 once it was lined up. Every scan since covers
the same hundred-picosecond window, in thirty-three-femtosecond steps.

## Slide 7, averaging measured (40 s)

The prediction holds up well. Dynamic range climbs from about sixty
decibels unaveraged to around ninety at a thousand sweeps, and the three
measured gains, close to seventeen, nineteen, and thirty decibels, land
right on the ten-log-N prediction.

Past about a hundred averages, though, the floor just before the main
pulse stops improving, because a coherent baseline structure repeats in
every sweep. Averaging only removes noise that's random; it can't touch
something identical every time. What it actually buys me is bandwidth,
since the spectrum keeps rising above the noise floor the longer I
average.

## Slide 8, extraction method (45 s)

Now for the material work. Every slab measurement is differential: one
scan without the sample, one with it, and I work from their ratio. The
delay gives me permittivity directly, since the slab just stands in for a
known thickness of air.

Loss takes more effort: I model the slab as a transmission-line section
between two air lines, and adjust the loss term at each frequency until
the model matches the measured transfer function, echoes from the slab
faces included. For the two thickest slabs, where that echo falls outside
the scan window, I keep only the first pass through the material.

## Slide 9, six slabs identified (30 s)

Here are all six, with delays from about a picosecond and a half up to
twenty-eight. Matching the extracted permittivities against the manual's
table points to two silicon wafers, a ceramic, Teflon, and Gore-Tex, most
within a few percent of the reference value.

Slab one is the odd one out, sitting between Gore-Tex and Teflon with very
low loss; my read is a porous PTFE of intermediate density that the table
doesn't list separately.

## Slide 10, transfer function fits (25 s)

These are the fits behind those numbers. The thing to look at is the
ripple riding on the silicon wafers, the etalon between the two faces,
repeating roughly every 83 gigahertz. The model reproduces both that
spacing and its depth, which alone pins down the slab's optical thickness
independently of the delay.

## Slide 11, the slab 2 conflict (45 s)

Worth walking through, since it shows what this measurement can do. The
data file for slab two lists 0.8 millimetres; the sample itself is
labelled 3.08. The delay alone can't settle it, since either thickness
just implies a different plausible material.

Three checks all point the same way: the fit is noticeably worse under
the thinner reading, the ripple that thinner slab would produce isn't in
the measurement, and the internal echo it predicts, about 8.3 picoseconds
after the main pulse, is nowhere in the time trace either. So the sample
really is 3.08 millimetres of Gore-Tex, and it was the file name that was
wrong.

## Slide 12, silicon wafers (40 s)

The two wafers make a nice controlled experiment: they share essentially
the same refractive index, close to 3.42, right in line with the
literature value, but their loss is completely different.

Conduction loss scales as one over frequency, exactly the slope I see
below about one and a half terahertz. Converting that to resistivity, one
wafer comes out around 37 ohm-centimetres, close to the 33 printed on its
label from an independent four-point-probe measurement. The other wafer is
far more heavily doped, down around 9.

## Slide 13, takeaways (25 s)

Four things, to wrap up. Stroboscopic sampling turns a plain DC current
measurement into femtosecond-scale resolution. Averaging follows that
ten-log-N climb until coherent structure takes over. A delay measurement
paired with a transmission-line fit identifies materials to within a few
percent, and that same fit was sharp enough to catch a labelling error and
reproduce a resistivity from a completely different instrument.

## Slide 14, closing (10 s)

Thank you. Happy to take questions.
