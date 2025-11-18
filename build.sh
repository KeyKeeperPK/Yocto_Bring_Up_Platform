#!/bin/bash

# build.sh - PK Platform CLI Launcher
# This script serves as the main entry point for the PK Platform development kit

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source PK Logo Class
source "$SCRIPT_DIR/scripts/pk-logo-class.sh"

# Function to check if pk CLI is available
check_pk_cli() {
    if [ ! -f "$SCRIPT_DIR/scripts/pk-cli-original.sh" ]; then
        echo "❌ Error: PK CLI not found at $SCRIPT_DIR/scripts/pk-cli-original.sh"
        echo "Make sure you're running this from the project root directory."
        exit 1
    fi
    
    if [ ! -x "$SCRIPT_DIR/scripts/pk-cli-original.sh" ]; then
        echo "Making PK CLI executable..."
        chmod +x "$SCRIPT_DIR/scripts/pk-cli-original.sh"
    fi
}

# Main launcher function
main() {
    # Check if pk CLI is available
    check_pk_cli
    
    # If no arguments provided, show welcome and help
    if [ $# -eq 0 ]; then
        # Show PK Logo with welcome message
        pk_logo_show "animated" "rainbow" "Platform Kit" "Development System"
        echo ""
        echo "� Welcome to PK Platform Development Kit"
        echo "=========================================="
        echo ""
        echo "This is the main launcher for the PK Platform CLI system."
        echo "For detailed help and available commands, use:"
        echo ""
        echo "  $0 help"
        echo "  $0 --help"
        echo ""
        echo "Quick examples:"
        echo "  $0 build beaglebone          # Build BeagleBone image"
        echo "  $0 platform list             # List available platforms"
        echo "  $0 setup raspberrypi4        # Setup Raspberry Pi 4"
        echo "  $0 status                    # Show system status"
        echo ""
        exit 0
    fi
    
    # Pass all arguments to pk CLI
    "$SCRIPT_DIR/scripts/pk-cli-original.sh" "$@"
}

# Handle special cases
case "${1:-}" in
    "-h"|"--help"|"help")
        # Show welcome message and then pass to pk CLI
        echo "🚀 PK Platform Development Kit - Main Launcher"
        echo "=============================================="
        echo ""
        exec "$SCRIPT_DIR/scripts/pk-cli-original.sh" "$@"
        ;;
    "--version"|"-v")
        exec "$SCRIPT_DIR/scripts/pk-cli-original.sh" version
        ;;
    *)
        main "$@"
        ;;
esac