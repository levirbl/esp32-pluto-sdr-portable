# Tools

[← Back to README](../../README.md)

A grid of small utilities that sit next to the radio: an image viewer, a text editor, calculators for
RF work, a stopwatch and timer, a metronome, an IQ file player and some games. None of them uses the
Pluto's radio (the Pluto keeps streaming the spectrum in the background), and nothing here transmits.
Turn the encoder to select and press to open, or tap the icon. **< Tools** in the bar (or holding the
button) comes back to the grid; the last utility used is already selected when you return.

| Tool | What it does |
|---|---|
| [Images](#images) | BMP and PNG viewer (your screenshots included) |
| [Text](#text) | View and edit `.txt`, `.csv` and `.log` files |
| [Calculator](#calculator) | `+ - x / ^ ( )` and square root, with the last answer |
| [Stopwatch](#stopwatch-and-timer) | Stopwatch with laps and a countdown timer with an alarm |
| [Metronome](#metronome) | Clicks on the speaker, 30–250 BPM, tap tempo |
| [LC calc](#lc-calculator) | Resonance of an LC, the L or C missing for a frequency, reactances |
| [IQ player](#iq-player) | Spectrum, waterfall and audio of an IQ recording (receive only) |
| [Games](#games) | Snake, Blocks, 2048, Breakout, Maze 3D, Mines and Starship |
| [RF conv](#rf-conv) | dBm, mW, W, dBW, dBµV, S-meter and VSWR conversions |
| [Antenna](#antenna) | Dipole, 1/4, 5/8 and coax lengths for any frequency |

The [Files](files.md) app opens `.bmp`/`.png` in Images, `.txt`/`.csv`/`.log` in Text and IQ files in the
IQ player straight from its list.

## Images

Shows a BMP or PNG from the card (up to 6 MB), for example the PNGs in `/screenshots`. **Open** picks
a file, **Prev** and **Next** go through the folder. The picture is fitted to the screen; tap it to
switch between fitted and 1:1, and in 1:1 drag or turn to move around.

## Text

Views and edits text files of up to 256 KB. Lines are wrapped to the screen width; tap a line to select
it and tap again to edit it on the keyboard (up to 63 characters per line). The bar has **Open**,
**New**, **Edit**, **Insert**, **Delete** and **Save**.

Saving is made to be safe:

- If the file could not be read completely (too large, truncated, read error, a line longer than 63
  characters), **Save is disabled** and the screen says why, so a partial file never overwrites the
  original.
- Leaving with **unsaved edits** asks for a second tap before they are discarded.
- Saving writes a temporary file and swaps it in, so the original is never deleted before the new one
  exists. If a save is interrupted you may find a `.sdrbak` next to the file: that is the original,
  and it is restored on the next save.

## Calculator

A 5 × 5 on-screen keypad (tap, or turn and press). It does `+ - x / ^`, parentheses and `sqrt`,
and **Ans** brings back the last result.

## Stopwatch and timer

The **stopwatch** counts with laps. The **timer** counts down: turn the knob to set the time while it
is stopped (10 s per click up to 10 min, then 1 min) and press to start. When it reaches zero the
speaker beeps, **in any Tools utility** you happen to have open. The stopwatch and the timer keep
separate states.

## Metronome

Clicks on the speaker with the first beat of the bar accented. Turn for the tempo (30–250 BPM, with
the Largo to Prestissimo name), press to start and stop, or tap the rhythm twice or more with **Tap
tempo**. The volume is the Audio app's.

## LC calculator

Three solvers: f₀ from L and C, the **C** needed for a frequency and an L, and the **L** needed for a
frequency and a C. Tap a field and type a value with an SI suffix (`4.7u`, `100n`, `47p`, `14.6M`,
`2k`); the computed field is green. It also shows the reactance of each part at that frequency.

## IQ player

Opens an IQ recording from the card and shows the spectrum and waterfall of the **whole file**; tap
the spectrum or the waterfall to pick a channel, or turn the **Tune** cell, and listen to it on the
speaker in NFM, AM, USB or LSB. It is **receive only**: nothing is transmitted.

- Formats: `.cs8`/`.c8` (int8 I,Q: HackRF, PortaPack), `.cu8` (uint8: RTL-SDR), `.cs16`/`.c16` (int16)
  and WAV with 2 channels, 16-bit.
- The sample rate and the center frequency come from the `.txt` next to the file (PortaPack), from the
  file name (`_145500000Hz`, `_500000sps`) or from the WAV header; with no rate in the file, set it in
  the **Rate** cell.
- The card reads about 1 MB/s: above roughly 500 kSPS in 8 bits the recording plays slower (without
  sound) and the screen says "too fast for the card".

To play an IQ file back on the air (licensed amateurs only) see
[Transmit](transmit.md#replay-of-an-iq-recording).

## Games

A small menu with seven games. The best score of each is **saved** (the shortest time in Maze 3D and
Mines) and shown on the game screen.

| Game | Controls |
|---|---|
| Snake | Turn the encoder (or tap left/right of the head) to turn 90°; press to pause. Eating speeds up and grows |
| Blocks | Turn to move, press to rotate; touch buttons rotate, drop and pause. Faster every 10 lines |
| 2048 | Tap the arrows or drag; turn to slide left/right, press to switch to up/down |
| Breakout | Turn (or drag) to move the paddle; press to launch the ball and pause. 3 lives |
| Maze 3D | First-person maze: turn to look, press to walk, find the green wall as fast as you can. The map below shows what you have seen |
| Mines | 10 × 12 field with 16 mines: tap to open, hold (or **Flag**) to mark; the first square is never a mine |
| Starship | Turn (or drag) to move, the ship fires by itself; waves of enemies get faster. 3 lives |

## RF conv

Conversions you do all the time, in four groups. Tap a field to type a value (`-73`, `5m`, `S9+20`),
or turn to change it and press for the next field; the other fields of the group follow.

- **Power**: dBm, mW, W and dBW.
- **Voltage (50 Ω)**: dBµV, µV and V rms.
- **S-meter (IARU)**: S1 to S9+60 dB, for HF (S9 = −73 dBm) or VHF/UHF (S9 = −93 dBm), both ways.
- **VSWR / return loss**: VSWR, |Γ|, return loss and mismatch loss.

Nothing is saved: it always opens at 0 dBm, VHF and VSWR 1.50.

## Antenna

For any frequency (turn, or tap to type) or a ready band (current radio frequency, FM, VOR, 2 m/APRS,
AIS, 433, 70 cm, ADS-B): wavelength, dipole total length and each arm, 1/4 monopole and its
counterpoise/radials, 5/8 vertical, and a 1/4 coax transformer (RG-58 and foam), with drawings of the
dipole and the monopole. For receiving the length is not critical: cut it long, then trim it while
watching the SNR. (This calculator used to be in Settings.)
