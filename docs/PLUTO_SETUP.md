# Pluto setup

[← Back to README](../README.md)

This guide prepares the Pluto to talk to the ESP32. It is done **once**, with the Pluto on a PC. At
the end, the Pluto boots straight into the SDR program on the USB data serial port, in place of the
login, and the ESP32 only needs to be connected to that port.

Tested with a **PlutoSDR Rev.B (Z7010-AD9363A)** clone, official ADI firmware **v0.39** (Linux 6.1,
libiio 0.26, glibc 2.25) and Windows 11.

## How the Pluto and the ESP32 talk

- The ESP32 is the USB host and the Pluto is the device. The cable goes from the ESP32's native
  USB-C (the left one on the devkit) to the Pluto's **data port**.
- The Pluto's data port shows several devices at once: network (RNDIS), a "PlutoSDR" drive, IIO and a
  **USB serial port** (`/dev/ttyGS0` on the Pluto's Linux). The ESP32 only uses that serial port.
- On the original firmware that serial port has a login (getty). The setup replaces the login with
  the **`rx_streaming_fft`** program, which takes text commands from the ESP32 (START, RETUNE,
  AUDIO...) and sends back lines of spectrum, audio and decoded messages.
- The login is still available on the **other USB-C** (the console, CH340 chip, 115200 baud) and over
  SSH.

## About libiio

The program uses **libiio**, ADI's library that talks to the radio. **It already comes with the
Pluto's firmware** (v0.39 has libiio 0.26, in `/usr/lib/libiio.so.0`), so there is nothing to install
on the Pluto. The binary in `pluto/deploy/` is already built for the Pluto (ARM, glibc 2.25).

## What you need

- A Pluto SDR with the official ADI firmware. To see the version, open the "PlutoSDR" drive that shows
  up on the PC and its `info.html`. Firmware other than v0.39 has not been tested.
- On the PC (Windows):
  - ADI's **"PlutoSDR-M2k USB Drivers"**
    (https://github.com/analogdevicesinc/plutosdr-m2k-drivers-win/releases). They make the Pluto's USB
    network work.
  - The **OpenSSH client** (`ssh` and `scp`), included in Windows 10 and 11.
  - Optional: **libiio for Windows** (https://github.com/analogdevicesinc/libiio/releases), which
    brings `iio_info` and `iio_attr`, handy to check the radio from the PC.
- The files in this repository's `pluto/deploy/`: `rx_streaming_fft`, `run.sh` and `autorun.sh`.

> **Do not edit `run.sh` or `autorun.sh` in Notepad.** The scripts need Linux line endings (LF). The
> repository already stores them that way; an editor that changes them to CRLF breaks the program's
> start-up.

## 1. Find the data port and log into the Pluto

1. Connect the Pluto to the PC through one of the USB-C ports. The **data port** is the one that makes
   the "PlutoSDR" drive and a new network adapter appear. The other one is the console (shows up as a
   CH340 COM port).
2. With the data port on the PC, the Pluto is at **192.168.2.1**. Test with `ping 192.168.2.1`.
3. Log in over SSH, as `root` with the ADI firmware's default password (on ADI's wiki, PlutoSDR
   page):

```bash
ssh root@192.168.2.1
```

The commands in steps 2 to 5 are typed **inside the Pluto** (in SSH); the copy commands, on the PC.

## 2. Open up the 70 MHz to 6 GHz range

The AD9363 comes set to 325 MHz–3.8 GHz. The device's firmware uses 70 MHz–6 GHz (FM, aviation, 2 m,
AIS...), so the chip has to be declared as an AD9364:

```bash
fw_setenv attr_name compatible
fw_setenv attr_val ad9364
reboot
```

After the reboot, log in again and check:

```bash
iio_attr -c ad9361-phy altvoltage0 frequency_available
```

The range should start at 70000000 (70 MHz) and go up to 6000000000 (6 GHz).

The chip is still an AD9363: outside 325 MHz–3.8 GHz it works, but out of specification. To undo:
`fw_setenv attr_val ad9363a` and `reboot`.

## 3. Check the permanent storage (`/mnt/jffs2`)

The Pluto's Linux root runs from RAM: anything copied outside `/mnt/jffs2` is gone after a reboot. The
program and the scripts live in `/mnt/jffs2`.

```bash
mount | grep jffs2
```

- If a line with `/mnt/jffs2` shows up, all is well: skip to step 4.
- If nothing shows up, the partition holds garbage (it happened on the tested clone; the boot shows
  "Cowardly refusing to erase blocks"). Check the partition names:

```bash
cat /proc/mtd
```

`mtd2` must be named `"qspi-nvmfs"`. Only then erase **that** partition and reboot:

```bash
flash_erase -j /dev/mtd2 0 0
reboot
```

After the reboot, `mount | grep jffs2` should show `/mnt/jffs2`.

> **Warning**: erase only `mtd2`. `mtd0` holds the boot loader, `mtd1` the environment (including the
> `ad9364` from step 2) and `mtd3` the Linux image. Erasing another partition can leave the Pluto
> unable to boot.

## 4. Copy the files

On the PC, open a terminal in the repository's `pluto/deploy` folder. The Pluto uses the dropbear SSH
server, which has no SFTP, so `scp` needs **`-O`**:

```bash
ssh root@192.168.2.1 "mkdir -p /mnt/jffs2/sdr"
```

```bash
scp -O rx_streaming_fft run.sh root@192.168.2.1:/mnt/jffs2/sdr/
```

```bash
scp -O autorun.sh root@192.168.2.1:/mnt/jffs2/autorun.sh
```

```bash
ssh root@192.168.2.1 "chmod +x /mnt/jffs2/sdr/rx_streaming_fft /mnt/jffs2/sdr/run.sh /mnt/jffs2/autorun.sh"
```

If your Pluto already had an `/mnt/jffs2/autorun.sh` of yours, keep a copy first and merge the two.

The files end up like this:

| On the Pluto | What it is for |
|---|---|
| `/mnt/jffs2/sdr/rx_streaming_fft` | The SDR program |
| `/mnt/jffs2/sdr/run.sh` | Started by init on the USB serial port; turns on the Zynq's 2nd core, opens the program and sends its log to `/tmp/sdr.log` |
| `/mnt/jffs2/autorun.sh` | Runs at every boot (through `/etc/init.d/S98autostart`); replaces the USB serial login with `run.sh` in `/etc/inittab` |

## 5. Test the program (before rebooting)

Still in SSH, run the program by hand with a test command:

```bash
(echo "START 100000000 512 320"; sleep 600) | /mnt/jffs2/sdr/rx_streaming_fft
```

You should see `OK START` and then `DATA,320,...` lines scrolling. Stop with **Ctrl+C**.

Do this test **before** the reboot in step 6. After it, the program is already running on the USB
serial port, and a second copy would fight it for the radio.

## 6. Reboot and check

```bash
reboot
```

About 7 seconds after boot, log in again and check:

```bash
ps | grep -E "rx_streaming|getty"
```

You should see `/mnt/jffs2/sdr/rx_streaming_fft` and only one `getty`, the console's (`ttyPS0`).
Check the two cores too:

```bash
cat /sys/devices/system/cpu/online
```

It should show `0-1`. The Zynq has two cores, but the Pluto's boot turns on only one (`maxcpus=1` on
the kernel command line). `run.sh` turns the second one on before opening the program (this is lost
at reboot and redone at every boot; the boot loader is not changed). The program runs the
**integrated spectrum** and fine RBW FFTs there, at the lowest priority, and keeps the capture and the
demodulator on the first. With a single core everything works, but the spectrum uses fewer samples.
To stay on one core: `touch /mnt/jffs2/sdr/um_nucleo` and reboot.

The log shows what the program is doing:

```bash
cat /tmp/sdr.log
```

The first useful line is "pronto, esperando comandos" ("ready, waiting for commands"; the Pluto log is
in Portuguese). From there on the log shows the commands received and, every 10 s, the processing
cost of each mode.

## 7. Connect to the ESP32

Unplug the data port from the PC and connect it to the devkit's **left USB-C** (the ESP32's native
USB) with the C–C cable. When the device is powered, "no Pluto" leaves the status bar and the
Spectrum starts scrolling.

The program restarts by itself every time the cable is connected (init relaunches it). The ESP32
sends the radio settings again whenever the link comes back.

## After setup

**Reading the log with the Pluto on the ESP32**: use the console USB-C (CH340, 115200 baud, log in as
`root`) in a serial terminal like PuTTY and run `cat /tmp/sdr.log`. You can also move the data port
back to the PC and use SSH; the program keeps running there, it just receives no commands.

**Updating the program from the card**: copy the new `rx_streaming_fft` to the card's `/pluto` folder
and use **Settings > Pluto from card** on the device. The ESP32 sends the file over the data cable
itself; the Pluto checks it (md5, ARM program, the project's mark), keeps the running one as `rx_old`,
switches and restarts the program. The new one only **confirms** after running for 30 s **and**
answering the ESP32. If it crashes, or if it receives the ESP32's commands and answers none for 20 s
(then it exits by itself), `run.sh` counts the start; with no confirmation in 3 starts in a row it goes
back to `rx_old` by itself, and the screen says it rolled back (in under 1 min). If the new one does
not even read the serial port, the screen says it does not answer: power the Pluto off and on twice
and it rolls back. **Back to previous**, on the same screen, switches back. No SSH, password or cable
swap needed. The first install of a version with this feature (program and `run.sh`) is still done
over SSH, as below.

Files the update uses in `/mnt/jffs2/sdr/`: `rx_old` (the previous one), `rx_new.part` (the one
arriving), `novo` (new program not yet confirmed) and `voltou` (`run.sh` rolled back). The free space
shows on the screen; if it is low, delete old files of yours from the folder over SSH.

**Updating the program over SSH**: with the program running, copying over it gives "Text file busy".
Send it under another name and swap:

```bash
scp -O rx_streaming_fft root@192.168.2.1:/mnt/jffs2/sdr/rx_new
```

```bash
ssh root@192.168.2.1 "mv /mnt/jffs2/sdr/rx_new /mnt/jffs2/sdr/rx_streaming_fft && chmod +x /mnt/jffs2/sdr/rx_streaming_fft && killall rx_streaming_fft"
```

Init starts the new program right away. To check the copy, compare `md5sum
/mnt/jffs2/sdr/rx_streaming_fft` with the repository file's. The current version (2026-11-10, with
the radio astronomy mode and the transmit fixes; see the [changelog](../CHANGELOG.md)) has md5
**fa67a4609797e5e9bdee7cd592adba0c** (183,552 bytes). Update `run.sh` too (it turns on the 2nd core);
since it is only read when the program opens, it can be copied over.

**Transmitting (Transmit app)**: there is nothing to set up on the Pluto. In the log, the line
`[tx] pronto; ganho do TX lido de volta: -89.75 dB` ("TX ready; TX gain read back") says the TX opened
off and at minimum gain. The program only transmits within its limits (2 m and 70 cm, at least 3 dB
of attenuation, a keep-alive from the ESP32 every 500 ms) and always exits with the TX off.

**Back to the login on the USB serial port** (without deleting anything):

```bash
touch /mnt/jffs2/sdr/off
reboot
```

Delete the `off` file and reboot to bring the program back.

**Crystal correction**: the device keeps the base value in `/tmp/sdr_xo_base` and applies the
correction at every connection. Nothing to set up here: use **Settings > Crystal (FM station)** on the
device.

## Common problems

| Symptom | Likely cause |
|---|---|
| The PC can't reach 192.168.2.1 | Cable on the console port, or ADI's driver missing |
| `scp` gives a "subsystem" or "sftp" error | Missing `-O` |
| Tuning fails below 325 MHz or above 3.8 GHz (FM, aviation, 2 m...) | Step 2 (`ad9364`) was skipped |
| After the reboot there is still a login on the USB serial port | `/mnt/jffs2` did not mount (step 3), `autorun.sh` without `chmod +x`, or scripts with CRLF |
| "no Pluto" on the device with everything connected | Cable on the wrong ESP32 USB-C (it must be the left, native one) or on the Pluto's console port |
| The device connects but no spectrum arrives | Check `/tmp/sdr.log` through the console |
