# Changelog

[← Back to README](README.md)

Each release lists the ESP32 firmware (`sdcard/firmware/`, `esp32-usb/sdr.bin`) and the Pluto program
(`pluto/deploy/rx_streaming_fft`, `sdcard/pluto/`). Both can be updated from the SD card
(Settings > Firmware from card / Pluto from card).

## 2026-11-17 — Tools, Power saver and safety fixes

ESP32 `sdr_2026-11-17.bin` (md5 `a228bcdb`, 1,222,512 bytes) · Pluto `rx_streaming_fft_trk_17-11`
(md5 `edde88ad`, 185,160 bytes; installed as `rx_streaming_fft`)

**Install both.** The ESP32 firmware and the Pluto program share the command parsers and the transmit
guard (`protocol.h`, `txguard.h`), so update them together:

1. Copy the ESP32 `.bin` to `/firmware` and the Pluto program (named `rx_streaming_fft`) to `/pluto`
   on the card.
2. On the device: **Settings > Firmware from card**, pick the file and confirm; then
   **Settings > Pluto from card** and confirm (the Pluto program confirms itself after running 30 s and
   answering the ESP32, or goes back to the previous one). Details in the [README](README.md#updating-the-firmware-from-the-card).
3. The settings are migrated to **persist v40** at the first boot (a backup is saved in `/cfg`
   automatically before the migration).

**Partition table (read before updating).** This firmware is built for a new flash layout: two
application slots of **2.5 MB** each (before: 1.25 MB each, and the firmware had reached ~93% of a
slot). The settings area and the internal-flash area (spur maps) keep their addresses.
- Updating **from the card works on a device that still has the old table**: the image (1,222,512
  bytes) fits in the old 1,310,720-byte slot, but with almost no room left for later versions. This
  combination was calculated, not tested on a device.
- To get the larger slots, write the new `partitions.bin` **once over USB**, the way described in
  [First ESP32 flash over USB](README.md#first-esp32-flash-over-usb) (`esp32-usb/`): the same
  `esptool` command, **without erasing the whole flash**, so the settings are kept. Changing the table
  moves the second slot, so **Back to previous** is empty until the next update from the card.
  After that, updates from the card go on as usual.

**Added**
- **Tools** (new icon on the home menu; [Tools](docs/apps/tools.md)): a grid of utilities that do not use
  the radio.
  - **Images**: BMP and PNG viewer (your own screenshots included), fit or 1:1 with drag, previous and next.
  - **Text**: view and edit `.txt`/`.csv`/`.log`. **Save is safe**: a file that could not be read
    completely blocks the Save and says why, edits are written to a temporary file and swapped in, and
    leaving with unsaved edits asks for a second tap.
  - **Calculator** (`+ - x / ^ ( )`, square root, last answer), **LC calculator** (resonance, missing L or C,
    reactances), **Stopwatch and timer** (laps; the timer alarm sounds in any Tools utility; separate
    states) and **Metronome** (30–250 BPM, tap tempo, accented first beat).
  - **RF conv**: dBm/mW/W/dBW, dBµV/µV/V in 50 Ω, S-meter (IARU, HF and VHF/UHF) and VSWR /
    |Γ| / return loss / mismatch loss.
  - **Antenna**: the antenna calculator that was in Settings (dipole, 1/4, 5/8, radials, 1/4 coax),
    now in Tools.
  - **IQ player** (receive only): spectrum and waterfall of a whole IQ file (`.cs8`, `.cu8`, `.cs16`,
    2-channel WAV), pick a channel and listen in NFM, AM, USB or LSB. Rate and center from the `.txt`, the
    file name or the WAV header.
  - **Games**: Snake, Blocks, 2048, Breakout, Maze 3D, Mines and Starship, each with its **best score
    saved**.
- **Transmit: replay of an IQ recording** (Mode **IQ** in the WAV screen). The file is resampled to
  48 kSPS and only ±24 kHz around its center is sent, under the same guard as the WAV: LO ± 24 kHz
  must be inside 2 m or 70 cm, never outside. Not measured in RF yet.
- **Power saver** (Settings, off/on; [details](docs/apps/settings.md#power-saver)): brightness capped at
  40%, screen off after 30 s without use, CPU at 160 MHz (set at boot), no opening animation, and the
  Pluto's integrated spectrum off in Audio/Record when nothing needs it. Changing it saves, says
  "Restarting in 3 s..." and restarts. Transmit behaves as with the saver off.
- **Battery voltage** (Settings): tap the line and type the multimeter's voltage on a keypad
  (2.50–4.20 V, volts or mV), besides the old 10 mV per click.
- The battery log (`/bat`) has a new `ps` column (Power saver on or off in that boot).
- **Display gamma** (4 presets) and **4 new waterfall palettes** (Inferno, Viridis, Ocean, Phosphor) in Settings.
- **Status** now shows the ESP32 chip temperature (and the CPU frequency with the Power saver on), and it
  is opened from **Settings > Status**.

**Changed**
- The antenna calculator moved from Settings to **Tools > Antenna**.
- **Partition table** with two 2.5 MB application slots (see above); the firmware uses ~47% of a slot.
- Pluto, Audio: the spectrum interpolates the central bin (the DC point of the receiver). It is harmless;
  the narrow dip sometimes seen in the Audio spectrum turned out to depend on the antenna position,
  not on the receiver's DC offset.
- Tools: the best scores of Snake and Blocks are saved when you leave the game; fixes in the Starship
  wave counter and in the memory check of Snake.

**Safety** (found in an independent, read-only code review with OpenAI Codex; the first three are fixed, with new tests)
- The frequency validation of `TRACK`, `SWEEP` and `RA` wrapped around with a start frequency close to
  2^64 and accepted a forged command with an absurd range; the check is now written without overflow in
  the parser and in the transmit guard. The 60 dB floor and the band rules of the tracking generator
  were not loosened.
- **TRACK start race**: the safety watchdog could cut the transmit guard while the receiver was being
  reconfigured at the start of a tracking sweep, and the sweep still switched the transmitter on. The
  start now re-checks the guard under the lock before turning the TX on.
- The `RAS` parser (radio astronomy) could be driven out of range by a large index on 32-bit
  `unsigned long`; the range is now checked before it is used.
- Not changed (reviewed, still open): a window of about 10 ms in the tracking start, `FINE` not
  aborting a running transmission first, and the battery adjust showing 4.19 V when you ask for 4.20 V.

**Tests**: 2594 checks on the PC (new groups T73–T76: Power saver, the 64-bit overflow, the TRACK start
race and RAS, battery adjustment). On the device, the
Power saver, the battery keypad, RF conv, Antenna and the safety fixes were tried; the other Tools were
only checked on the PC so far.

**Main board**
PCB (layout revision reviewed in KiCad):
- Cleaned up the routing on 81 nets: duplicate tracks and short loop/wiggle segments removed (track
  segments 2164 -> 1338), many 90-degree corners replaced by 45-degree ones.
- `VBUS_IN` at the USB-C J1 input widened (the net now runs 0.2-1.5 mm, was 0.2-0.5 mm) and its vias
  re-placed.
- Pluto +5 V copper on inner layer 2 widened (larger +5V area, smaller +3V3 area).
- Vias removed from inside the R3 and C1 pads; R4 (ILIM) moved 0.7 mm; Q3 pad 4 narrowed to 0.3 mm
  (TI land pattern). Vias: 524 -> 526.
- Speaker connector J103 changed to LCSC C54582899 (same JST-PH footprint).
- BOM: encoder SW103 removed from the JLCPCB BOM (hand-soldered, still in `lcsc_order.csv`); CPL rotations
  normalized to 0-359 (orientation unchanged).
- DRC: 0 errors, 0 unrouted, 0 schematic-parity issues; 526 pins match the schematic (one new
  copper-sliver warning from the saved zone fill, to be checked in KiCad before ordering).
- Gerbers, BOM, CPL, LCSC order list and renders regenerated.

## 2026-11-14 — radio astronomy and the main board

ESP32 `sdr_2026-11-12.bin` (md5 `b4297eea`) · Pluto 2026-11-10 (md5 `fa67a460`)

**Added**
- **Radio astronomy** in Decode: the 21 cm hydrogen line (1420 MHz) and total-power drift scans.
  Views: Spectrum (km/s, LSR-corrected), Power, Sky (where to point, Milky Way, Sun, geostationary arc,
  radio sources; tap to aim), HI map and Galaxy (longitude–velocity, top view, rotation curve) built
  from your saved measurements. See [Decode](docs/apps/decode.md#radio-astronomy).
- Pluto: `RA` mode with frequency switching, integration of every sample on the second core, fixed
  gain, and settling rules that keep the samples right after each retune out of the sum.
- **Main board PCB** (4 layers, KiCad 10) with Gerbers, BOM and pick-and-place: [hardware/](hardware/README.md).
  Designed and checked, not built yet.

**Changed**
- Battery %: filtered over 2 minutes, only goes down, and goes up only after 60 s at least 15 % higher
  (charging). The curve is now the measured one with the device on (about 1 h 45 min on 3000 mAh);
  the low-battery warning is at 3.45 V. The battery log has a new `raw` column.

**Fixed**
- Transmit, WAV in **USB/LSB**: it came out on the wrong sideband and 44–57 dB below the right level,
  and the level drifted down over long files. It is now on the right side of the carrier, at the same
  level as NFM, with 46–70 dB opposite-sideband rejection.
- Transmit: FM pre-emphasis had the wrong gain and could over-deviate (now limited to 75 kHz).
- Transmit: the safety watchdog can always cut the power, even while a WAV buffer is being sent.
- Transmit: starting a WAV no longer changes the receiver's sample rate behind its back; `STOP` also
  ends a transmission or a tracking sweep.
- Pluto: the program pauses the firmware's USB-drive poller during radio-astronomy runs (it made
  periodic noise bursts in the receiver).

## 2026-11-09 — English interface and documentation

ESP32 `sdr_2026-11-09.bin` · Pluto 2026-11-08

**Added**
- The whole user interface in English; new documentation in English with a page and screenshots per app.
- **Screenshots**: hold a finger on the status bar (or send `screenshot` on the serial port) to save
  a PNG of the screen to `/screenshots` on the card.

**Fixed**
- Negative radio-chip temperatures were shown garbled; implausible readings are now ignored.
- Compass labels on the radar, sky and VOR views; several cut-off texts.

## 2026-11-08 — oscilloscope, tracking generator, fine RBW

ESP32 2026-11-04 · Pluto 2026-11-08

**Added**
- **RF oscilloscope** in Meter: amplitude and frequency over time, trigger (auto, normal, single,
  rising or falling), 1 µs to 500 ms per division; tap the pulse line to tune to the pulse.
- **Tracking generator** in Transmit: sweeps 70–500 MHz with the TX while the RX follows (filters,
  cables, attenuators), with calibration, integration and averaging. 60 dB minimum attenuation outside
  the 2 m / 70 cm bands; distress frequencies are skipped.
- **Fine RBW** in Spectrum: spans of 10–200 kHz with a resolution down to ~24 Hz.
- **Audio zoom** with fine RBW (tap the scale): 600 → 200 → 100 → 50 kHz; during a satellite pass the
  zoom can **follow the Doppler** so the signal stays still on the waterfall.
- Transmit: minimum attenuation lowered to 3 dB (with a low-pass filter warning below 20 dB).

**Fixed**
- Squelch opening and closing by itself: the device's own speaker noise lowered the measured SNR.
  The squelch now discounts it, and the I2S pins run at minimum drive strength (much less noise).
- Pluto: listening to a satellite in USB, LSB or CW from the satellite list gave errors and no audio.
- Pluto: a new program installed from the card now has to answer the ESP32 before it is confirmed;
  one that does not respond goes back to the previous one by itself. The update screen now shows the
  final result.

## 2026-11-04 — satellite orbits

- Satellite orbits (TLE) updated from CelesTrak.

## 2026-11-02 — Pluto from the card, CW, ignore list

**Added**
- **Pluto program update from the SD card**, with automatic fallback to the previous version.
- Transmit: menu of icons; **CW identification** (automatic after each transmission or every 10 min)
  and **CW messages** (free text); listen to the frequency between transmissions and monitor while
  transmitting.
- Meter: **fox-hunt beep** (higher and faster with a stronger signal).
- **Ignore list** (up to 64 frequencies) for Search and the memory scanner.
- Search: stable list and a **Pause** button.
- Files: **waveform viewer** for WAV files (tap to play from that point).
- Decode: **FPV drone** detector (40 analog video channels at 5.8 GHz).

## 2026-10-27 — integrated spectrum, traces, amateur TX

**Added**
- **Integrated spectrum**: the Pluto's second core processes nearly all samples (≈98 % instead of
  ~1 %), so weak and short signals show up.
- **Traces** in Spectrum and Sweep: peak hold, minimum, average, peak decay.
- **Transmit** (licensed amateurs, 2 m and 70 cm): test tone and WAV files from the card, with
  on-screen confirmation, keep-alive and automatic cut-off.

## 2026-10-22 — automatic noise reduction

**Added**
- **Automatic noise reduction** for the speaker (spectral noise reduction, band-pass per mode, soft
  mute, automatic FM bandwidth and fine tuning). Tap the SNR in the header to turn it on or off.

## 2026-10-21 — first public release

First release: spectrum and waterfall, sweep, search, meter, memories and scanner, audio (AM, NFM,
WFM, USB, LSB, CW) with EQ and squelch, recording, decoders (RDS, ADS-B, AIS, APRS, radiosondes, VOR),
satellite passes with Doppler correction, files, settings with backups and firmware update from the card.
