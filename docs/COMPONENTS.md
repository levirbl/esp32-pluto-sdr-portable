# Components

[← Back to README](../README.md)

Parts list to build a unit on perfboard, like the prototype. A 4-layer main board that replaces most
of these modules is in [hardware/](../hardware/README.md) (designed, not built yet). The codes (C9, B3, R1...) are the same
as in the [Assembly](ASSEMBLY.md).

## Main modules

| Qty | Part | Notes |
|---|---|---|
| 1 | **Pluto SDR** (ADALM-PLUTO or a Zynq 7010 + AD9363 clone) | Prototype: HamGeek clone, two USB-C ports, ADI firmware v0.39 |
| 1 | **ESP32-S3-N16R8**, DevKitC-1 style devkit (22 + 22 pins, two USB-C ports) | Must be **N16R8**: 16 MB flash and 8 MB octal PSRAM |
| 1 | **3.5" SPI ILI9488 display**, 480 × 320, with **XPT2046** resistive touch | 14-pin module (the common red one); it usually has an SD slot on the back |
| 1 | **microSD module**, SPI, 3.3 V | Or the display's own SD slot |
| 1 | **microSD card** | FAT32; the prototype uses 8 GB |
| 1 | **KY-040 rotary encoder** | With push button |
| 1 | **MAX98357A I2S amplifier** | Class D, 3 W |
| 1 | **Speaker**, 4 or 8 Ω, ~3 W | Small; it does not play below ~150 Hz |
| 1 | **INMP441 I2S microphone** | **Optional**: it is in the pinout, but the firmware does not use it yet |
| 1 | **Antenna** with SMA | A telescopic one is the most versatile (FM wants ~75 cm). A short coax to keep it away from the electronics helps |
| 1 | **TX antenna** for 2 m and/or 70 cm, with SMA | **Optional**, only for licensed amateurs using the Transmit app. Goes on the Pluto's TX SMA |
| 1 | SMA attenuator of 30 dB or more | **Optional**, only to connect the TX to the RX by cable for tests |

## Power

| Qty | Part | Notes |
|---|---|---|
| 1 | **1S LiPo battery**, 3.7 V, 2000–3000 mAh | 1C discharge or more. Total draw ~1.0–1.3 A at 5 V: estimated 1.5–2 h of use |
| 1 | **TP4056 charger with protection** (DW01A + 8205A), USB-C | |
| 1 | **Synchronous 5 V boost converter for one cell**, e.g. **TPS61088** | Input from ~2.7 V, 2 A or more at the output. **The XL6009 and MT3608 failed on the prototype** (won't start under load / resets the device; see the Assembly) |
| 1 | On/off switch (SW1) | Slide switch, for the battery current (~2.5 A peak) |
| 1 | Resettable PTC fuse (F1) | Hold current above the battery peak (~2.5 A) |
| 1 | **AO3401A** P-channel MOSFET (Q1) | Reverse battery protection |
| 1 | 5 V TVS diode (D2) | At the boost output. E.g. SMBJ5.0A |
| 1 | 2-pin jumper + shunt (JP_DEV) | In series with the ESP32's 5 V |
| 1 | USB-C cable with one end cut off (or a solderable USB-C plug) | Takes +5V_PLUTO to the Pluto's console USB-C |

## Data link

| Qty | Part | Notes |
|---|---|---|
| 1 | **USB-C to USB-C cable**, short, with data | From the ESP32's native USB-C to the Pluto's data port. Whole, no soldering |

## Resistors

| Qty | Value | Where |
|---|---|---|
| 7 | **100 Ω** | In series, right at the ESP32 pins: display SCK and MOSI (GPIO12, 11), card CLK and MOSI (GPIO39, 40), audio BCLK, LRC and DIN (GPIO4, 2, 3) |
| 1 | 300 kΩ (R1) | Battery divider, from VCC to GPIO1 |
| 1 | 100 kΩ (R2) | Battery divider, from GPIO1 to GND |

## Capacitors

Electrolytics rated 16 V or more.

| Qty | Value | Where |
|---|---|---|
| 9 | 100 nF ceramic (104) | C10 boost output · C11 Pluto · C14 ESP32 · C16 display · C18 SD card · C20 amplifier · C21 microphone · C23 boost input · battery divider |
| 3 | 10 µF electrolytic | C13 ESP32 · C15 display · C17 SD card |
| 2 | 100 µF electrolytic | C12 Pluto · C19 amplifier (47 µF also works) |
| 2 | 220 µF electrolytic, low ESR | C9 boost output · C22 boost input |
| 2 | 470 pF to 1 nF ceramic | Filter on the two speaker outputs (1 nF at most) |

## Ferrites

| Qty | Part | Where |
|---|---|---|
| 6 | Axial ferrite beads (~3.5 × 6 mm, solder like a resistor) | B1 and B2 in series on the Pluto's 5 V · B3 on the ESP32's 5 V · B4 on the amplifier's Vin · B5 and B6 on the speaker outputs |
| 3 | Clip-on cable ferrites | One near each end of the C–C data cable and one on the Pluto's power cable |

The clip-on ferrites made a big difference on the prototype: the FM stations' SNR became steady and
most of the spurs the ESP32 put into the spectrum disappeared.

## Assembly

- Perfboard, female pin headers for the modules, thin wire (preferably in different colors), thicker
  wire for the battery and the 5 V.
- Soldering iron, solder and a **multimeter** (essential to check polarity and voltages).

## Data cable plan B

Only if the whole C–C cable does not work (on the prototype it did):

| Qty | Part | Where |
|---|---|---|
| 1 | 4.7 to 10 Ω resistor | VBUS of the cut cable |
| 1 | 56 kΩ resistor | From the CC wire to VBUS |
