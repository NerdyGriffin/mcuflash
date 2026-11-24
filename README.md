# mcuflash

Build and flash [Klipper](https://www.klipper3d.org/) and
[Katapult](https://github.com/Arksine/katapult) firmware for the MCUs in a printer's
config, by name:

```
$ mcuflash list
MCU  BOARD        SERIAL ID                             STATE    FIRMWARE
mcu  btt-octopus  stm32f446xx_4D0043001551303432323631  klipper  v0.14.0-0-gc9559fa04
nhk  nitehawk-36  rp2040_3033393834058AB0               klipper  v0.14.0-0-gc9559fa04

$ mcuflash klipper nhk        # or: mcuflash klipper all
```

- MCU names (`mcu`, `nhk`, ...) come from the `[mcu]` / `[mcu <name>]` sections of
  `~/printer_data/config/printer.cfg` and the files it includes. They tab-complete.
- The device path is read from each section's `serial:` line. No IDs are stored here.
- Build configs are saved per board model under `boards/`, so they are tracked in git and
  shared between printers.

## Requirements

- A Klipper host with `~/klipper` and, for boards that use it, `~/katapult`.
- Python 3.9 or newer. No Python packages are needed.
- `sudo` rights to stop and start the `klipper` service.
- USB-connected MCUs. CAN bus and SD-card flashing are not supported.

## Install

```
git clone https://github.com/NerdyGriffin/mcuflash.git ~/mcuflash
~/mcuflash/install.sh
```

`install.sh` links `mcuflash` into `~/.local/bin` and installs bash completion. Open a new
shell afterwards.

## Usage

| Command | What it does |
|---|---|
| `mcuflash list` | MCUs in the printer config, their board, and whether each is running Klipper or sitting in Katapult |
| `mcuflash boards` | Available board profiles and their flash methods |
| `mcuflash klipper <mcu>... \| all` | Review the build config, build Klipper, flash it |
| `mcuflash katapult <mcu>` | Build and install Katapult, then build and flash Klipper |
| `mcuflash config <mcu>` | Review a saved build config in `menuconfig` without building |

`<mcu>` is an MCU name from the printer config or a board profile name, so
`mcuflash klipper btt-octopus` works wherever exactly one MCU is that board.

Options: `--dry-run` prints every command without running anything,
`--no-menuconfig` skips the review, `--yes` saves build config changes without asking,
`--board <profile>` sets the board for an MCU, `--config-dir <dir>` reads another config.

### Which board is which MCU

When only one board profile matches the chip in the serial ID (for example
`stm32f446xx`), it is used automatically. Several boards share the `rp2040`, so for those
you are asked once; the answer is kept in `.mcuflash-local` (not tracked), keyed by the
board's serial ID.

### Build config review

Each build starts from `boards/<board>/klipper.config`:

1. Options added or removed by the installed Klipper version are applied and shown.
2. `menuconfig` opens so you can check the config before it is used.
3. If the result differs from the saved file you choose to keep and save it, discard the
   changes, edit by hand in `vimdiff`, or quit.

Saved changes land in `boards/`; commit them. If two hosts run different Klipper
versions, each will want to update the shared config to its own version, so upgrade them
together or answer `N` on the older one.

### Updating Katapult

`mcuflash katapult <mcu>` installs over DFU or the RP2040 BOOTSEL drive, following the
board's instructions. For a board that already runs Katapult, `--deployer` updates it in
place by flashing Katapult's `deployer.bin`. This overwrites the bootloader: a wrong
Katapult build config leaves the board unable to boot until it is recovered over
DFU/BOOTSEL or with a programmer.

## Board profiles

A profile is a directory under `boards/`:

```
boards/<board>/board.conf        # name, flash methods, boot-mode instructions
boards/<board>/klipper.config    # Klipper menuconfig output
boards/<board>/katapult.config   # Katapult menuconfig output (optional)
```

`board.conf` keys:

| Key | Values |
|---|---|
| `name` | Display name |
| `klipper_flash` | `katapult` (Katapult's `flashtool.py`), `make-flash` (`make flash FLASH_DEVICE=...`), `host` (Linux host MCU) |
| `katapult_install` | `dfu` or `rp2-bootsel` |
| `dfu_id` | USB ID in DFU mode, default `0483:df11` |
| `boot_mode`, `leave_boot_mode`, `katapult_entry` | Instructions printed at the matching step |
| `untested` | `yes` prints a warning before use |

To add a board, create the directory, write `board.conf`, copy any existing Klipper
config in as `klipper.config`, and run `mcuflash config <mcu> --board <board>`.

The `ebb36-*` and `v0-display` profiles are marked untested: their build configs are
real, but their flash method has not been run with this tool.

## Environment

Paths can be overridden with `MCUFLASH_CONFIG_DIR`, `MCUFLASH_KLIPPER_DIR`,
`MCUFLASH_KATAPULT_DIR`, `MCUFLASH_KATAPULT_ENV`, `MCUFLASH_KLIPPER_SERVICE` and
`MCUFLASH_MOONRAKER_URL`.

## License

GPL-3.0. See [LICENSE](LICENSE).
