# Scarthgap Migration Notes

This branch is the Raspberry Pi 4 to Raspberry Pi 5 migration on top of the original `master` repository state. The working result moves the Raspberry Pi stack to `scarthgap`, and updates the custom Pi bring-up so the Pi 5 image builds and boots with the newer Yocto/LTS combination.

## Scope of the migration

- Raspberry Pi-related Yocto layers moved from `kirkstone` to `scarthgap`.
- The Raspberry Pi 5 image was updated to match `scarthgap` package, feature, and systemd naming changes.
- The shared `meta-custom` Raspberry Pi bring-up scripts were adjusted so the Pi 5 build does not inherit Pi 4 assumptions that break networking, Docker, or CAN bring-up.
- Jetson Nano was not migrated. `meta-tegra` remains on the legacy Nano-compatible line.

## Submodule and layer changes

Compared to the original repo:

- `.gitmodules` now tracks `scarthgap` for:
  - `poky`
  - `meta-openembedded`
  - `meta-raspberrypi`
  - `meta-virtualization`
- `meta-tegra` was intentionally left on `kirkstone-l4t-r32.7.x`.
- `meta-custom/conf/layer.conf` now declares:
  - `LAYERSERIES_COMPAT_meta-custom = "kirkstone scarthgap"`

Current Raspberry Pi stack revisions in this branch:

- `poky`: `db668121d98162b8ad196ba6d8637f8330a1787d`
- `meta-openembedded`: `ae7dfb12245c7f9b9a353499e2688015bd4e6413`
- `meta-raspberrypi`: `2c646d29912dcc873469a57b1c207e1549c5094d`
- `meta-virtualization`: `9e040ee8dd6025558ea60ac9db60c41bfeddf221`

## Raspberry Pi 5 image changes

The main migration work happened in `conf-templates/raspberrypi5/local.conf`.

Compared to the original repo, the Pi 5 config now:

- adds `usrmerge` to `DISTRO_FEATURES`
- switches Docker from `docker-ce` to `docker-moby`
- updates service auto-enable settings to the `scarthgap` package names:
  - `SYSTEMD_AUTO_ENABLE:pn-openssh-sshd = "enable"`
  - `SYSTEMD_AUTO_ENABLE:pn-networkmanager-daemon = "enable"`
- keeps serial and HDMI boot logs visible with:
  - `CMDLINE_SERIAL = "console=serial0,115200 console=tty1"`
  - `CMDLINE:append = " loglevel=7"`
- switches SPI control from `ENABLE_SPI` to `ENABLE_SPI_BUS`
- increases `BOOT_SPACE` to `131072` KiB for Pi 5 boot assets
- expands accepted license flags to:
  - `commercial synaptics-killswitch`

## Custom recipe and bring-up changes

### `rpi4-init-scripts.bb`

The shared Raspberry Pi init package was updated so Pi 4 and Pi 5 can depend on different Docker providers:

- common dependency now drops the generic `docker`
- Pi 4 appends `docker-ce`
- Pi 5 appends `docker-moby`

The recipe also stops auto-applying the old script patch files from `SRC_URI`. The script content now carries the working logic directly.

### `netcfg.bb` and NetworkManager profile

- the installed `.nmconnection` file now uses mode `0600`, which matches NetworkManager expectations
- `eth0-static.nmconnection` now adds `autoconnect-priority=100`

### `rpi4-hardware-init.sh`

The shared hardware init script was reworked to behave correctly on the migrated Pi 5 image:

- SSH startup now detects the first available unit from:
  - `sshd.service`
  - `sshd.socket`
  - `ssh.service`
- Docker daemon setup now writes `/etc/docker/daemon.json` with working runtime and log settings, then restarts Docker
- the script no longer forces `systemd-networkd` / `systemd-resolved`
  - the image configuration keeps ownership of the network backend
  - this matters because the Pi 5 image uses NetworkManager
- the generated system info utility is now `rpi-system-info`
  - `rpi4-system-info` is kept as a symlink for compatibility

### `rpi4-can-setup.sh`

CAN bring-up was rewritten to match the Pi 5 hardware path more cleanly:

- adds a helper that configures an interface by controller type
- uses tuned CAN-FD timing:
  - `bitrate 500000 sample-point 0.8`
  - `dbitrate 2000000 dsample-point 0.8`
- enables `restart-ms 100` for bus-off recovery
- falls back to classic CAN when FD setup is not available

## Tooling and workflow changes

Compared to the original repo, the branch also adds a few workflow improvements:

- `README.md` now explains the `scarthgap` direction and the Jetson split
- `scripts/flash-sdcard.sh` now:
  - recognizes versioned `.rootfs-*` image names
  - recognizes `.rpi-sdimg` outputs in addition to `.wic`
  - uses `bmaptool copy --nobmap` when no `.bmap` exists
- `stop-build.sh` was added to kill stuck BitBake/pseudo sessions and clear stale locks/sockets in the developer sandbox layout

## Resulting branch intent

- Raspberry Pi path migrated to `scarthgap`
- Raspberry Pi 5 promoted as the maintained path
- shared custom bring-up updated for Pi 5 compatibility
- Jetson Nano intentionally left on the old stack pending a separate decision
