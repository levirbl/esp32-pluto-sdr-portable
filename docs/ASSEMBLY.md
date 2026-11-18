# Assembly

[← Back to README](../README.md)

Assembly on perfboard, from the battery to the Pluto, with a test at the end of each step. The parts
are in [Components](COMPONENTS.md).

There is also an interactive version (in Portuguese), with photos of the parts and every wire drawn:
**[Montagem Pluto SDR](https://claude.ai/artifact/DhdFfQ2hzK1RdGYbfx7DLW)**.

## Before you start

- **Check every pin against your board's silkscreen.** The numbering below is that of a DevKitC-1
  style devkit. Clones vary, and the pin order of the display and the SD module changes between
  makers.
- **Layout**: power (battery, charger, boost) on one side; the Pluto and the antenna on the other,
  away from the boost; display, encoder and audio on the front panel.
- **Star ground**: each module takes its GND by its own wire to a single point, near the boost's
  OUT−. Do not daisy-chain GND from module to module.
- **Ferrites**: the axial ones go only on each branch's +5 V, the clip-on ones around the cables.
  **Never** put a ferrite on GND, between the battery and the boost, or on the USB D+/D− wires.
- **100 Ω resistors** on the fast signals: soldered **right at the ESP32 pin**, with the wire going on
  from them.

## ESP32-S3 pinout

| Function | GPIO | Goes to |
|---|---|---|
| Display MOSI | 11 | Display SDI, **through 100 Ω** (touch T_DIN bridged at the connector) |
| Display SCK | 12 | Display SCK, **through 100 Ω** (touch T_CLK bridged at the connector) |
| Display MISO | 13 | Touch T_DO (the display's SDO is **not connected**) |
| Display CS | 10 | Display CS |
| Display DC | 9 | Display DC/RS |
| Display RESET | 8 | Display RESET |
| Display LED | 7 | Display LED (PWM brightness) |
| Touch CS | 6 | T_CS |
| Touch IRQ | 5 | T_IRQ |
| SD CLK | 39 | SD module CLK, **through 100 Ω** |
| SD MOSI | 40 | SD module MOSI, **through 100 Ω** |
| SD MISO | 41 | SD module MISO |
| SD CS | 42 | SD module CS |
| Encoder A | 16 | KY-040 CLK |
| Encoder B | 17 | KY-040 DT |
| Encoder button | 18 | KY-040 SW |
| I2S BCLK | 4 | MAX98357 BCLK, **through 100 Ω** (and the microphone's SCK, as a branch) |
| I2S LRCK | 2 | MAX98357 LRC, **through 100 Ω** (and the microphone's WS, as a branch) |
| I2S out | 3 | MAX98357 DIN, **through 100 Ω** |
| I2S in | 14 | INMP441 microphone SD |
| Amplifier on/off | 15 | MAX98357 SD |
| Battery | 1 | Middle of the 300k / 100k divider |
| USB D− / D+ | 19 / 20 | **Nothing on the header**: they are the native USB-C lines, used by the Pluto cable |
| Reserved | 21, 47 | Headphone detect and PTT (unused) |

Free: 0 (BOOT button), 38 and 48 (devkit RGB LED). Do not use 35, 36 and 37 (PSRAM), 43 and 44
(programming serial) or 45 and 46 (strapping).

**Devkit USB-C ports**: the **left** one is the native USB and goes to the Pluto; the **right** one
is the UART (CH343), for flashing and the serial monitor.

---

## Step 1: battery and charger

Solder the two LiPo wires to the TP4056 **B+** and **B−** pads: red to B+, black to B−.

- Measure the polarity with the multimeter before soldering. Wire color is no guarantee.

**Test**: with a charger on the USB-C, an LED lights while charging. Without the charger, OUT+ and
OUT− read the battery voltage, between 3.0 and 4.2 V.

## Step 2: switch, fuse and reverse protection

From OUT+, in series: switch SW1, resettable fuse F1 and MOSFET Q1 (AO3401A). The point after the
MOSFET is **VCC**: the battery voltage, now protected.

- On the AO3401A: drain on the battery side, source on the boost side, gate to GND.

**Test**: switch on, VCC reads the same as the battery; switch off, 0 V.

## Step 3: boost, set to 5 V

VCC goes to **IN+** and the negative to **IN−**, with C22 (220 µF) and C23 (100 nF) soldered between
them, right at the module. With the output still **unloaded**, turn the trimmer until OUT+ reads 5.0
to 5.1 V. Only then solder C9 (220 µF), C10 (100 nF) and the TVS (D2) at the output. That is the
**+5V** node.

- An adjustable module may come set well above 5 V. Adjust it before connecting anything.
- **Use a synchronous boost made for one cell, like the TPS61088** (input from ~2.7 V, several amps).
  On the prototype the cheap modules failed:
  - **XL6009** (and its SEPIC version): with the ESP32 already on the output, it does not start. It
    stays stuck at ~2.4 V (the battery minus the diode), getting hot.
  - **MT3608**: it starts, but cannot hold the whole device. About 10 s after power-on, when the
    Pluto starts capturing and the current rises, the voltage drops for a few milliseconds and the
    Pluto and the ESP32 reset together (a multimeter does not show it). Similar symptoms: an
    occasional white screen and the devkit's RGB LED blinking.
- Test any boost with the whole device on and the battery at ~3.5 V, not just unloaded.
- Until you have a boost that holds, feed the +5V node from an **external 5 V** supply. Never connect
  the external supply and the boost to the same node at the same time.
- Do not put a ferrite between the battery and the boost: the current there is high and pulsed.

**Test**: OUT+ between 5.0 and 5.1 V, switch on, nothing on the output.

## Step 4: ESP32, with 5 V through the jumper

From the +5V node a wire goes through ferrite **B3**, on to jumper **JP_DEV** and from it to the
devkit's **5VIN** pin. Between the ferrite and the jumper, C13 (10 µF) and C14 (100 nF) go to GND.

- **Open JP_DEV before plugging the programming USB-C into the PC with the battery connected.** The
  devkit expects one power source at a time.
- The axial ferrite is soldered like a resistor, with no polarity. The capacitors go after it, on the
  ESP32 side.

**Test**: the devkit LED lights and the 3V3 pin reads 3.3 V.

## Step 5: star ground

Each module takes its GND by its own wire to a GND bar. The bar, the boost return and the Pluto
return meet at a single point, near the boost's OUT−. This applies to all the following steps.

**Test**: with everything off, the resistance between any module's GND and the boost's OUT− is below
1 Ω.

## Step 6: battery meter

R1 (**300 kΩ**) goes from VCC to the middle point; R2 (**100 kΩ**) and a 100 nF capacitor go from
the middle to GND. The middle point goes to **GPIO1**.

- The reading is taken before the boost (after it, it is always 5 V) and after the switch (when off,
  the divider does not drain the battery).
- **Do not swap the resistors**: the firmware expects the pin at 25% of the battery voltage.

**Test**: the middle point reads 25% of the battery (4.0 V becomes 1.0 V). Then, on the device, turn
on **Settings > Measure battery** and adjust **Battery voltage** until it matches the multimeter.

## Step 7: display

Wires to the 14-pin J1 connector: VCC (3V3), GND, CS, RESET, DC, SDI, SCK and LED. **SDI and SCK go
through a 100 Ω resistor each, soldered right at the ESP32 pins** (GPIO11 and GPIO12). The **SDO**
pin **stays unconnected**. At J1, C15 (10 µF) and C16 (100 nF) go from VCC to GND, right at the pins.

- VCC on 3V3. Only use 5 V if the display board has a regulator.
- The resistors soften the SPI edges. Without them, the screen drawing got into the Pluto and the FM
  audio sounded "robotic".
- Keep the SPI wires short (10–15 cm at most), away from the Pluto and the antenna.

**Test**: flash the firmware ([README](../README.md#first-esp32-flash-over-usb)). The boot screen
shows, then the menu, with "no Pluto" in the status bar.

## Step 8: touch

The touch uses the same bus. Make two bridges on the connector itself: **T_CLK to SCK** and **T_DIN
to SDI**. T_DO (to GPIO13), T_CS (GPIO6) and T_IRQ (GPIO5) get their own wires.

- The bridges are on the display side, after the 100 Ω resistors: the same resistor serves the
  screen and the touch.

**Test**: **Settings > Calibrate touch**, tapping the corners shown.

## Step 9: SD card

Four signal wires on a bus of its own, plus 3V3 and GND. **MOSI and CLK go through a 100 Ω resistor
each, right at the ESP32 pins** (GPIO40 and GPIO39). At the module's 3V3 and GND pins, C17 (10 µF)
and C18 (100 nF).

- Power it from 3V3: the module has no regulator.
- The order of the six pins is on the back of the board: follow the silkscreen.
- The display's SD slot also works, with the same four GPIOs (one or the other).

**Test**: the **Status** app shows the card's free space. Record a few seconds in the **Record** app
and check the file in the **Files** app.

## Step 10: encoder

**CLK** to GPIO16, **DT** to GPIO17 and **SW** to GPIO18. The **+ pin goes to 3V3** and GND to ground.

- Never connect + to 5 V: the module's pull-ups would put 5 V on the GPIOs.
- Check that SW and + are not swapped. Swapped, the button shorts the 3V3 and resets the ESP32 on
  every press (it happened on the prototype).

**Test**: turning changes the menu item and pressing opens it.

## Step 11: amplifier and speaker

BCLK, LRC and DIN leave the ESP32 through **a 100 Ω resistor each, right at the pin**. The
amplifier's **SD** pin goes to GPIO15. Vin comes from +5V through ferrite **B4**, with C19 (100 µF)
and C20 (100 nF) from Vin to GND, right at the pins. Each output goes through a ferrite (**B5**,
**B6**) and, after it, a 470 pF to 1 nF capacitor goes to GND; from there they go to the speaker. The
GAIN pin stays unconnected (9 dB).

- On the prototype the amplifier was the biggest noise source for the radio: the class D outputs
  switch fast and the speaker wires become antennas. The ferrite and capacitor filter is the one the
  datasheet suggests. The firmware also drives the I2S pins at minimum strength (softer edges).
- **Do not connect headphones** to these outputs: both swing and neither is ground.
- Output capacitors: 1 nF at most.
- Keep the speaker wires short and twisted, away from the Pluto and the antenna.

**Test**: in the **Audio** app, tune an FM station: the sound comes out of the speaker.

## Step 12: microphone (optional)

SCK and WS take the same clocks as the amplifier, branched on the amplifier side (after the 100 Ω
resistors). **SD** goes to GPIO14, VDD to 3V3 (with C21, 100 nF, from VDD to GND) and **L/R to GND**.

The current firmware does not use the microphone; this step can wait.

## Step 13: Pluto, power

From the +5V node, **two ferrites in series (B1 and B2)** and capacitors C11 (100 nF) and C12
(100 µF) make **+5V_PLUTO**, which goes by its own wire to the Pluto's **console USB-C** (the one that
is not the data port). Put a clip-on ferrite on that cable, near the Pluto.

- Before powering the Pluto from your 5 V, set it up and test it alone on a PC
  ([Pluto setup](PLUTO_SETUP.md)).
- The data port is the one that makes the "PlutoSDR" drive appear on the PC; the other is the
  console (CH340).

**Test**: the Pluto's LED lights and, after the ferrites, the voltage stays close to 5 V.

## Step 14: Pluto, data

Connect the whole USB-C cable between the devkit's **left USB-C** and the Pluto's **data port**.
There is no soldering in this step. Put **a clip-on ferrite near each end** of the cable; if the hole
allows, loop the cable twice through the ferrite.

- The cable's VBUS wire joins the 5 V of both boards (the Pluto puts 5 V on it). If the waterfall
  comes out dirty, cut only the cable's VBUS wire.
- Use the shortest cable that works.

**Test**: "no Pluto" leaves the status bar and the **Spectrum** shows the waterfall scrolling.

**Plan B** (only if the whole cable does not work): cut one end; **D+** to GPIO20, **D−** to GPIO19,
GND to ground, VBUS from +5V_PLUTO through a 4.7 to 10 Ω resistor and the CC wire to VBUS through
56 kΩ. The wire colors inside the cable are not standard: identify each with the multimeter. With
wires on pins 19 and 20, do not plug anything into the devkit's native USB-C.

---

## After assembly

1. Set up the device (README, [first settings](../README.md#first-settings-on-the-device)).
2. **Antenna**: extend the telescopic antenna (lying flat it loses more than 7 dB on FM). Moving it
   away from the electronics with a short coax helps. On battery, with no cable connected, the
   monopole lacks a counterpoise: a wire on the SMA's ground, stretched opposite the antenna (~75 cm
   for FM, ~50 cm for 2 m, ~17 cm for 70 cm), or a dipole on coax, brings the signal back.
3. **Transmit** (licensed amateurs only): the TX antenna goes on the Pluto's **TX SMA**. With no T/R
   switch, use one antenna per port and never connect the TX straight to the RX without an attenuator
   of at least 30 dB (the RX input takes +2.5 dBm at most). Use an antenna made for the band
   (Tools > Antenna).
4. **Record the internal spurs** with no antenna (Settings > Internal spurs). Record them again when
   the assembly or the power supply changes: the map describes the spurs of this assembly.
