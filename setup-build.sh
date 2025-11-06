#!/bin/bash

# setup-build.sh - Script to set up the Yocto build environment for multiple platforms

set -e

# Supported platforms
PLATFORMS=("beaglebone" "raspberrypi4" "jetson-nano")

# Function to display usage
usage() {
    echo "Usage: $0 [PLATFORM]"
    echo "Supported platforms:"
    for platform in "${PLATFORMS[@]}"; do
        echo "  - $platform"
    done
    echo ""
    echo "Example: $0 raspberrypi4"
    echo "If no platform is specified, beaglebone will be used as default."
}

# Parse command line arguments
PLATFORM=${1:-beaglebone}

# Validate platform
if [[ ! " ${PLATFORMS[@]} " =~ " ${PLATFORM} " ]]; then
    echo "Error: Unsupported platform '$PLATFORM'"
    usage
    exit 1
fi

echo "Setting up Yocto build environment for $PLATFORM..."

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "poky" ]; then
    echo "Error: Please run this script from the Yocto_build_custom directory"
    exit 1
fi

# Initialize and update submodules if needed
if [ ! -f "poky/oe-init-build-env" ]; then
    echo "Initializing Git submodules..."
    git submodule update --init --recursive
fi

# Set build directory name
BUILD_DIR="build-${PLATFORM}"

# Source the Yocto environment
if [ -f "poky/oe-init-build-env" ]; then
    echo "Sourcing Yocto build environment..."
    source poky/oe-init-build-env "$BUILD_DIR"
    
    # Copy platform-specific configuration if it doesn't exist
    if [ ! -f "conf/local.conf" ] && [ -f "../conf-templates/$PLATFORM/local.conf" ]; then
        echo "Copying $PLATFORM configuration files..."
        cp "../conf-templates/$PLATFORM/local.conf" conf/
        cp "../conf-templates/$PLATFORM/bblayers.conf" conf/
    fi
    
    echo ""
    echo "Build environment is ready for $PLATFORM!"
    echo "You can now run: bitbake core-image-minimal"
    echo ""
    echo "Configuration files:"
    echo "  - conf/local.conf - Main build configuration"
    echo "  - conf/bblayers.conf - Layer configuration"
    echo ""
    
    # Platform-specific information
    case $PLATFORM in
        "beaglebone")
            echo "Target: BeagleBone (ARM Cortex-A8)"
            echo "Machine: beaglebone-yocto"
            echo "Build output: tmp/deploy/images/beaglebone-yocto/"
            ;;
        "raspberrypi4")
            echo "Target: Raspberry Pi 4 (ARM Cortex-A72 64-bit)"
            echo "Machine: raspberrypi4-64"
            echo "Build output: tmp/deploy/images/raspberrypi4-64/"
            ;;
        "jetson-nano")
            echo "Target: NVIDIA Jetson Nano (ARM Cortex-A57)"
            echo "Machine: jetson-nano-devkit"
            echo "Build output: tmp/deploy/images/jetson-nano-devkit/"
            ;;
    esac
else
    echo "Error: Could not find poky/oe-init-build-env"
    exit 1
fi