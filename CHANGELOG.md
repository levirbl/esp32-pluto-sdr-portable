# Changelog

[← Back to README](README.md)

Each release lists the ESP32 firmware (`sdcard/firmware/`, `esp32-usb/sdr.bin`) and the Pluto program
(`pluto/deploy/rx_streaming_fft`, `sdcard/pluto/`). Both can be updated from the SD card
(Settings > Firmware from card / Pluto from card).

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
