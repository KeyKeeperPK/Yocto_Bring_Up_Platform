# Platform-Specific Hardware Initialization

This document describes the separated platform-specific hardware initialization configurations for BeagleBone, Raspberry Pi 4, and Raspberry Pi 5.

## Overview

The `meta-custom` layer now keeps a clean Raspberry Pi 4 base recipe and a dedicated Raspberry Pi 5 recipe that reuses the Pi 4 base files plus Pi-5-specific patches.

```
meta-custom/
├── recipes-core/
│   ├── beaglebone-init-scripts/
│   │   ├── beaglebone-init-scripts.bb
│   │   └── files/
│   │       ├── beagle-hardware-init.sh
│   │       ├── beagle-can-setup.sh
│   │       ├── beagle-uart-setup.sh
│   │       ├── beagle-spi-setup.sh
│   │       ├── beagle-wifi-setup.sh
│   │       ├── beagle-hardware-init.service
│   │       └── beagle-can-fd.patch
│   ├── rpi4-init-scripts/
│   │   ├── rpi4-init-scripts.bb            # Raspberry Pi 4 base recipe
│   │   └── files/
│   │       ├── rpi4-hardware-init.sh       # Clean base hardware init script
│   │       ├── rpi4-can-setup.sh           # Clean base CAN setup script
│   │       ├── rpi4-uart-setup.sh
│   │       ├── rpi4-spi-setup.sh
│   │       ├── rpi4-hardware-init.service
│   │       └── rpi4-hardware-init.tmpfiles
│   └── rpi5-init-scripts/
│       ├── rpi5-init-scripts.bb            # Raspberry Pi 5 recipe
│       └── files/
│           ├── rpi5-hardware-init.service
│           ├── rpi5-hardware-init.patch    # Pi-5-specific service/network/docker delta
│           └── rpi5-can-setup.patch        # Pi-5-specific CAN-FD/controller delta
```

## Platform Configurations

### BeagleBone Industrial Configuration

**Target Machine:** `beaglebone-yocto`

**Recipe:** `beaglebone-init-scripts.bb`

### Raspberry Pi 4 Industrial Configuration

**Target Machine:** `raspberrypi4-64`

**Recipe:** `rpi4-init-scripts.bb`

**Design:**
- uses the clean base scripts directly
- keeps the original Raspberry Pi 4 service and runtime naming
- uses `docker-ce`

### Raspberry Pi 5 Industrial Configuration

**Target Machine:** `raspberrypi5`

**Recipe:** `rpi5-init-scripts.bb`

**Design:**
- reuses the Raspberry Pi 4 base scripts as source inputs
- applies explicit Pi-5-specific patches during the recipe build
- installs Pi-5-specific runtime names like `rpi5-hardware-init.sh`
- uses `docker-moby`

## Patch Strategy

The Raspberry Pi path now follows this rule:

- base behavior lives in `rpi4-init-scripts/files/*.sh`
- Raspberry Pi 5 differences live in `rpi5-init-scripts/files/*.patch`
- recipe selection decides which variant gets built

Current Pi 5 patch split:

1. `rpi5-hardware-init.patch`
   - SSH service detection for newer systemd packaging
   - Docker daemon tuning
   - no forced `systemd-networkd` ownership
   - Pi-5-specific helper names
2. `rpi5-can-setup.patch`
   - MCP251xFD detection
   - tuned CAN-FD timing
   - `restart-ms` recovery behavior

## Configuration Usage

### Raspberry Pi 4 Build

`conf-templates/raspberrypi4/local.conf` installs:

```conf
IMAGE_INSTALL:append = " rpi4-init-scripts netcfg"
```

### Raspberry Pi 5 Build

`conf-templates/raspberrypi5/local.conf` installs:

```conf
IMAGE_INSTALL:append = " rpi5-init-scripts netcfg"
```

## Runtime Utilities

### Raspberry Pi 4
- `rpi4-system-info`
- `uart-test`
- `spi-test`
- `spi-speed-test`

### Raspberry Pi 5
- `rpi5-system-info`
- `rpi-system-info`
- `uart-test`
- `spi-test`
- `spi-speed-test`
