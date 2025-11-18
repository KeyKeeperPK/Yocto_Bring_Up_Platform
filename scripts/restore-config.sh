#!/bin/bash

# restore-config.sh - Script to restore build configuration files for multiple platforms

set -e

# Supported platforms
PLATFORMS=("beaglebone" "raspberrypi4" "jetson-nano")

# Function to display usage
usage() {
    echo "Usage: $0 [PLATFORM] [BUILD_DIR]"
    echo "Supported platforms:"
    for platform in "${PLATFORMS[@]}"; do
        echo "  - $platform"
    done
    echo ""
    echo "Example: $0 raspberrypi4 build-rpi4"
    echo "If no platform is specified, beaglebone will be used as default."
    echo "If no build directory is specified, build-[PLATFORM] will be used."
}

# Parse command line arguments
PLATFORM=${1:-beaglebone}
BUILD_DIR=${2:-"build-${PLATFORM}"}

# Validate platform
if [[ ! " ${PLATFORMS[@]} " =~ " ${PLATFORM} " ]]; then
    echo "Error: Unsupported platform '$PLATFORM'"
    usage
    exit 1
fi

CONF_DIR="$BUILD_DIR/conf"

echo "Restoring Yocto build configuration for $PLATFORM..."

# Check if we're in the right directory
if [ ! -d "conf-templates" ]; then
    echo "Error: conf-templates directory not found. Please run from project root."
    exit 1
fi

# Check if platform template exists
if [ ! -d "conf-templates/$PLATFORM" ]; then
    echo "Error: Configuration template for '$PLATFORM' not found."
    echo "Available platforms:"
    ls -1 conf-templates/
    exit 1
fi

# Create build directory and conf if they don't exist
mkdir -p "$CONF_DIR"

# Copy configuration files
if [ -f "conf-templates/$PLATFORM/local.conf" ]; then
    cp "conf-templates/$PLATFORM/local.conf" "$CONF_DIR/"
    echo "Restored local.conf for $PLATFORM"
else
    echo "Warning: conf-templates/$PLATFORM/local.conf not found"
fi

if [ -f "conf-templates/$PLATFORM/bblayers.conf" ]; then
    cp "conf-templates/$PLATFORM/bblayers.conf" "$CONF_DIR/"
    echo "Restored bblayers.conf for $PLATFORM"
else
    echo "Warning: conf-templates/$PLATFORM/bblayers.conf not found"
fi

echo "Configuration files restored to $CONF_DIR/"
echo "You can now run: source poky/oe-init-build-env $BUILD_DIR"