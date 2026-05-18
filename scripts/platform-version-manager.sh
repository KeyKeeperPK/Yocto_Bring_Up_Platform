#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_CUSTOM_DIR="$SCRIPT_DIR/meta-custom"

source "$SCRIPT_DIR/pk-logo-class.sh"

BEAGLEBONE_VERSION="1.0.0"
RPI4_VERSION="1.0.0"
RPI5_VERSION="1.0.0"

pk_logo_show "popup" "neon" "Platform Kit" "Version Manager"

echo "=========================================="
echo "Platform Hardware Init Version Manager"
echo "=========================================="

show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  status              Show version status of all platforms"
    echo "  version [platform]  Show version of specific platform"
    echo "  patch [platform]    Show active patches for platform"
    echo "  info [platform]     Show platform information"
    echo ""
    echo "Platforms:"
    echo "  beaglebone         BeagleBone Black/Green industrial config"
    echo "  rpi4               Raspberry Pi 4 base recipe"
    echo "  rpi5               Raspberry Pi 5 patched recipe"
}

show_status() {
    echo "Platform Configuration Status:"
    echo "=============================="
    echo ""

    if [ -f "$META_CUSTOM_DIR/recipes-core/beaglebone-init-scripts/beaglebone-init-scripts.bb" ]; then
        echo "✓ BeagleBone: v$BEAGLEBONE_VERSION"
        echo "  Recipe: beaglebone-init-scripts.bb"
    fi
    echo ""

    if [ -f "$META_CUSTOM_DIR/recipes-core/rpi4-init-scripts/rpi4-init-scripts.bb" ]; then
        echo "✓ Raspberry Pi 4: v$RPI4_VERSION"
        echo "  Recipe: rpi4-init-scripts.bb"
        echo "  Model: clean base scripts"
    fi
    echo ""

    if [ -f "$META_CUSTOM_DIR/recipes-core/rpi5-init-scripts/rpi5-init-scripts.bb" ]; then
        echo "✓ Raspberry Pi 5: v$RPI5_VERSION"
        echo "  Recipe: rpi5-init-scripts.bb"
        patch_count=$(find "$META_CUSTOM_DIR/recipes-core/rpi5-init-scripts/files" -maxdepth 1 -name '*.patch' | wc -l)
        echo "  Active Pi 5 patches: $patch_count"
    fi
    echo ""
}

show_version() {
    case "$1" in
        beaglebone)
            echo "BeagleBone Hardware Init Version: $BEAGLEBONE_VERSION"
            grep '^PV\|^PR' "$META_CUSTOM_DIR/recipes-core/beaglebone-init-scripts/beaglebone-init-scripts.bb" 2>/dev/null || true
            ;;
        rpi4)
            echo "Raspberry Pi 4 Hardware Init Version: $RPI4_VERSION"
            grep '^PV\|^PR' "$META_CUSTOM_DIR/recipes-core/rpi4-init-scripts/rpi4-init-scripts.bb" 2>/dev/null || true
            ;;
        rpi5)
            echo "Raspberry Pi 5 Hardware Init Version: $RPI5_VERSION"
            grep '^PV\|^PR' "$META_CUSTOM_DIR/recipes-core/rpi5-init-scripts/rpi5-init-scripts.bb" 2>/dev/null || true
            ;;
        *)
            echo "Available platforms: beaglebone, rpi4, rpi5"
            exit 1
            ;;
    esac
}

show_info() {
    case "$1" in
        beaglebone)
            echo "BeagleBone Industrial Configuration"
            echo "==================================="
            echo "Recipe: beaglebone-init-scripts.bb"
            ;;
        rpi4)
            echo "Raspberry Pi 4 Industrial Configuration"
            echo "======================================="
            echo "Recipe: rpi4-init-scripts.bb"
            echo "Design: clean base scripts, no Pi-5-specific patches"
            ;;
        rpi5)
            echo "Raspberry Pi 5 Industrial Configuration"
            echo "======================================="
            echo "Recipe: rpi5-init-scripts.bb"
            echo "Design: Pi 4 base files plus Pi-5-specific patches"
            echo "Active patches:"
            find "$META_CUSTOM_DIR/recipes-core/rpi5-init-scripts/files" -maxdepth 1 -name '*.patch' -printf '  • %f
' 2>/dev/null | sort
            ;;
        *)
            echo "Available platforms: beaglebone, rpi4, rpi5"
            exit 1
            ;;
    esac
    echo ""
}

show_patches() {
    case "$1" in
        beaglebone)
            find "$META_CUSTOM_DIR/recipes-core/beaglebone-init-scripts/files" -maxdepth 1 -name '*.patch' -printf '%f
' 2>/dev/null | sort
            ;;
        rpi4)
            echo "Raspberry Pi 4 base recipe does not apply variant patches."
            ;;
        rpi5)
            find "$META_CUSTOM_DIR/recipes-core/rpi5-init-scripts/files" -maxdepth 1 -name '*.patch' -printf '%f
' 2>/dev/null | sort
            ;;
        *)
            echo "Please specify a platform: beaglebone, rpi4, or rpi5"
            exit 1
            ;;
    esac
}

case "${1:-status}" in
    status)
        show_status
        ;;
    version)
        [ -n "$2" ] || { echo "Please specify a platform: beaglebone, rpi4, or rpi5"; exit 1; }
        show_version "$2"
        ;;
    info)
        [ -n "$2" ] || { echo "Please specify a platform: beaglebone, rpi4, or rpi5"; exit 1; }
        show_info "$2"
        ;;
    patch)
        [ -n "$2" ] || { echo "Please specify a platform: beaglebone, rpi4, or rpi5"; exit 1; }
        show_patches "$2"
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
