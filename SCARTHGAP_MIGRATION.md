# Scarthgap Migration Notes

This repository started from a `kirkstone`-based multi-platform Yocto setup. The Raspberry Pi path now needs to move to `scarthgap` because `scarthgap` is the current Yocto 5.0 LTS line, while `kirkstone` support ends in May 2026.

## What changed in this repo

- `.gitmodules` now points `poky`, `meta-openembedded`, `meta-raspberrypi`, and `meta-virtualization` at `scarthgap`.
- `meta-custom` now declares `LAYERSERIES_COMPAT` for both `kirkstone` and `scarthgap` during the transition.

## Important blocker

`meta-tegra` was intentionally left on `kirkstone-l4t-r32.7.x`.

Why:

- This repository still exposes a `jetson-nano` target.
- Current `scarthgap` `meta-tegra` branches track newer Jetson Linux releases and Orin-class boards.
- Jetson Nano is part of the older L4T generation and does not cleanly follow the same upgrade path.

## Recommended migration path

1. Treat Raspberry Pi migration and Jetson Nano maintenance as separate tracks.
2. Re-sync the Raspberry Pi-related submodules to their `scarthgap` branches.
3. Build `raspberrypi5bare` first as the lowest-risk validation target.
4. Build `raspberrypi5` next and check:
   - firmware/kernel boot on Raspberry Pi 5 rev 1.1 hardware
   - RP1 peripheral bring-up
   - CAN overlay loading
   - Wi-Fi/Bluetooth bring-up
   - Docker image/package compatibility
5. Keep `jetson-nano` on the existing legacy stack until a separate platform decision is made:
   - keep a split branch
   - drop Nano from this repo
   - or replace Nano with a newer Jetson platform supported by modern `meta-tegra`

## Likely follow-up work

- Refresh submodule commits after switching branches.
- Review all Yocto migration notes between `kirkstone` and `scarthgap`:
  - `langdale` 4.1
  - `mickledore` 4.2
  - `nanbield` 4.3
  - `scarthgap` 5.0
- Re-test custom recipes and package names in `meta-custom`.
- Re-check Raspberry Pi specific settings such as:
  - kernel version expectations
  - overlay names
  - `RPI_USE_U_BOOT`
  - package availability from `meta-virtualization`

## Rewired dependencies found so far

- `docker-ce` -> `docker-moby`
  - `scarthgap` `meta-virtualization` in this repository provides `virtual/docker` via `docker-moby`.
  - The Raspberry Pi 5 image config was updated to use `PREFERRED_PROVIDER_virtual/docker = "docker-moby"` and to install `docker-moby` instead of `docker-ce`.
- `ENABLE_SPI` -> `ENABLE_SPI_BUS`
  - `meta-raspberrypi` `scarthgap` uses `ENABLE_SPI_BUS` in `rpi-config`, while the Pi 5 local config still used the older/custom `ENABLE_SPI` knob.
- Pi 5 should not inherit a forced `systemd-networkd` / `systemd-resolved` enable from the shared `rpi4-init-scripts`
  - The shared init script now avoids overriding the network backend selected by the image configuration.
- Pi 5 UART overlay names updated to the BSP's Pi-5-specific overlay variants where available
  - `uart1-pi5.dtbo` through `uart4-pi5.dtbo` are now used instead of the generic UART overlay names.

## Suggested first validation commands

```bash
git submodule sync --recursive
git submodule update --init --remote poky meta-openembedded meta-raspberrypi meta-virtualization
./build.sh setup raspberrypi5bare
./build.sh build raspberrypi5bare
```
