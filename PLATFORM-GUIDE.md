# Platform Quick Reference

## Quick Start Commands

### BeagleBone (Default)
```bash
./setup-build.sh beaglebone
bitbake core-image-minimal
# Output: build-beaglebone/tmp/deploy/images/beaglebone-yocto/
```

### Raspberry Pi 4
```bash
./setup-build.sh raspberrypi4
bitbake core-image-minimal
# Output: build-raspberrypi4/tmp/deploy/images/raspberrypi4-64/
```

### Jetson Nano
```bash
./setup-build.sh jetson-nano
bitbake core-image-minimal
# Output: build-jetson-nano/tmp/deploy/images/jetson-nano-devkit/
```

## Platform-Specific Images

### BeagleBone
- `core-image-minimal` - Basic Linux system
- `core-image-base` - Minimal with package management
- `core-image-full-cmdline` - Full command-line system

### Raspberry Pi 4
- `core-image-minimal` - Basic Linux system
- `rpi-hwup-image` - Hardware demonstration image
- `core-image-base` - With package management and RPi tools

### Jetson Nano
- `core-image-minimal` - Basic Linux system
- `tegra-minimal-initramfs` - Minimal initramfs
- Custom images with CUDA/AI frameworks

## Hardware Features by Platform

### BeagleBone
- Low power consumption
- Real-time capabilities
- Industrial I/O
- CAN bus support

### Raspberry Pi 4
- GPU acceleration (VideoCore VI)
- 4K video playback
- WiFi 802.11ac & Bluetooth 5.0
- GPIO, SPI, I2C, UART
- Camera and display interfaces

### Jetson Nano
- NVIDIA Maxwell GPU (128 CUDA cores)
- Hardware video encoding/decoding
- Deep learning inference
- Computer vision acceleration
- AI development platform

## Build Time Estimates

| Platform | First Build | Incremental |
|----------|-------------|-------------|
| BeagleBone | 2-3 hours | 10-30 min |
| Raspberry Pi 4 | 3-4 hours | 15-45 min |
| Jetson Nano | 4-6 hours | 20-60 min |

*Times vary based on system specs and network speed*

## Common Issues & Solutions

### All Platforms
- **Clock skew**: Fixed with SOURCE_DATE_EPOCH
- **Parallel build issues**: Configured per-package limits
- **Disk space**: Ensure 40GB+ per platform

### Raspberry Pi 4
- **GPU memory**: Configured with GPU_MEM = "128"
- **WiFi firmware**: Included in image
- **Video codecs**: Commercial license accepted

### Jetson Nano
- **NVIDIA licenses**: Must accept FSL_EULA
- **CUDA version**: Set to 10.2 for compatibility
- **Large downloads**: L4T components are significant

## Switching Between Platforms

To work with multiple platforms simultaneously:
```bash
# Build for RPi4
./setup-build.sh raspberrypi4
bitbake core-image-minimal

# Switch to Jetson (in new terminal)
./setup-build.sh jetson-nano
bitbake core-image-minimal

# All builds maintain separate directories
ls build-*
```