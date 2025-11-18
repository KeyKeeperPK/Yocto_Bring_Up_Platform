#!/bin/bash

# PK Platform CLI - Main Build Interface
# Comprehensive command-line interface for Yocto Platform Development Kit

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source PK Logo Class
source "$SCRIPT_DIR/pk-logo-class.sh"

# Import child scripts
SCRIPTS_DIR="$SCRIPT_DIR"
source "$SCRIPTS_DIR/cli-core.sh"
source "$SCRIPTS_DIR/cli-build.sh" 
source "$SCRIPTS_DIR/cli-platform.sh"
source "$SCRIPTS_DIR/cli-config.sh"
source "$SCRIPTS_DIR/cli-utils.sh"

# Version information
CLI_VERSION="1.0.0"
CLI_NAME="PK Platform CLI"

# Main CLI entry point
main() {
    # Display PK logo
    pk_logo_show "popup" "gradient" "PK Platform CLI" "v$CLI_VERSION"
    
    # Parse command line arguments
    case "${1:-help}" in
        # Build commands
        "build"|"b")
            shift
            cli_build_command "$@"
            ;;
        
        # Platform management
        "platform"|"p")
            shift
            cli_platform_command "$@"
            ;;
        
        # Configuration management  
        "config"|"c")
            shift
            cli_config_command "$@"
            ;;
        
        # Utilities
        "utils"|"u")
            shift
            cli_utils_command "$@"
            ;;
            
        # Setup commands
        "setup"|"s")
            shift
            cli_setup_command "$@"
            ;;
            
        # Clean commands
        "clean")
            shift
            cli_clean_command "$@"
            ;;
        
        # Status and information
        "status"|"st")
            cli_status_command
            ;;
            
        # Version information
        "version"|"v"|"-v"|"--version")
            cli_version_command
            ;;
            
        # Help
        "help"|"h"|"-h"|"--help"|*)
            cli_help_command "${2:-general}"
            ;;
    esac
}

# CLI Help System
cli_help_command() {
    local topic="${1:-general}"
    
    case "$topic" in
        "build")
            show_build_help
            ;;
        "platform") 
            show_platform_help
            ;;
        "config")
            show_config_help
            ;;
        "setup")
            show_setup_help
            ;;
        "examples")
            show_examples_help
            ;;
        *)
            show_general_help
            ;;
    esac
}

# General help display
show_general_help() {
    cat << EOF
$(echo -e "\033[1;36m")
╔══════════════════════════════════════════════════════════════╗
║                    PK Platform CLI v$CLI_VERSION                    ║
║              Yocto Platform Development Kit                  ║
╚══════════════════════════════════════════════════════════════╝
$(echo -e "\033[0m")

USAGE:
    pk [COMMAND] [OPTIONS]

COMMANDS:
    build, b        Build platform images
    platform, p     Platform management (list, configure, version)
    config, c       Configuration management
    setup, s        Setup build environments
    clean           Clean build artifacts
    utils, u        Utility commands
    status, st      Show system status
    version, v      Show version information
    help, h         Show help information

QUICK START:
    pk setup beaglebone              # Setup BeagleBone environment
    pk build beaglebone              # Build BeagleBone image
    pk platform list                 # List available platforms
    pk status                        # Show system status

EXAMPLES:
    pk help examples                 # Show detailed examples
    pk help build                    # Show build command help
    pk help platform                 # Show platform command help

For detailed help on specific commands:
    pk help [COMMAND]

EOF
}

# Build help
show_build_help() {
    cat << EOF
$(echo -e "\033[1;33m")BUILD COMMANDS$(echo -e "\033[0m")

USAGE:
    pk build [PLATFORM] [IMAGE] [OPTIONS]

PLATFORMS:
    beaglebone      BeagleBone Industrial IoT
    raspberrypi4    Raspberry Pi 4 Industrial
    jetson-nano     NVIDIA Jetson Nano

IMAGES:
    minimal         core-image-minimal (default)
    base            core-image-base  
    full            core-image-full-cmdline

OPTIONS:
    --clean         Clean before build
    --continue      Continue interrupted build
    --verbose       Verbose output
    --monitor       Show build monitoring
    --logs          Show build logs

EXAMPLES:
    pk build beaglebone                    # Build minimal image
    pk build raspberrypi4 base --clean    # Clean build of base image
    pk build jetson-nano full --monitor   # Build with monitoring

EOF
}

# Platform help
show_platform_help() {
    cat << EOF
$(echo -e "\033[1;35m")PLATFORM COMMANDS$(echo -e "\033[0m")

USAGE:
    pk platform [COMMAND] [OPTIONS]

COMMANDS:
    list            List available platforms
    info [PLATFORM] Show platform information  
    version         Show platform versions
    configure       Configure platform settings

EXAMPLES:
    pk platform list                 # List all platforms
    pk platform info beaglebone     # Show BeagleBone details
    pk platform version             # Show version status

EOF
}

# Setup help
show_setup_help() {
    cat << EOF
$(echo -e "\033[1;32m")SETUP COMMANDS$(echo -e "\033[0m")

USAGE:
    pk setup [PLATFORM] [OPTIONS]

OPTIONS:
    --clean         Clean setup (remove existing)
    --update        Update submodules
    --configure     Auto-configure after setup

EXAMPLES:
    pk setup beaglebone              # Setup BeagleBone environment
    pk setup raspberrypi4 --clean    # Clean setup for RPi4

EOF
}

# Examples help
show_examples_help() {
    cat << EOF
$(echo -e "\033[1;34m")USAGE EXAMPLES$(echo -e "\033[0m")

BASIC WORKFLOW:
    # 1. Setup platform environment
    pk setup beaglebone

    # 2. Build the image  
    pk build beaglebone

    # 3. Check status
    pk status

ADVANCED WORKFLOWS:
    # Clean build with monitoring
    pk build raspberrypi4 base --clean --monitor

    # Continue interrupted build
    pk build jetson-nano --continue

    # Setup and immediately build
    pk setup beaglebone --configure && pk build beaglebone

PLATFORM MANAGEMENT:
    # List all available platforms
    pk platform list

    # Get detailed platform information
    pk platform info raspberrypi4

    # Check platform versions
    pk platform version

CONFIGURATION:
    # Show current configuration
    pk config show

    # Update configuration  
    pk config update

UTILITIES:
    # System diagnostics
    pk utils doctor

    # Clean all builds
    pk clean all

    # Show build logs
    pk utils logs beaglebone

EOF
}

# Version command
cli_version_command() {
    echo "$CLI_NAME v$CLI_VERSION"
    echo "Yocto Platform Development Kit"
    echo ""
    echo "Components:"
    echo "  CLI Core: v$CLI_VERSION"
    echo "  PK Logo: v1.0.0"
    echo "  Platform Manager: v1.0.0"
    echo ""
    echo "Supported Platforms:"
    echo "  - BeagleBone (Industrial IoT)"
    echo "  - Raspberry Pi 4 (Industrial)"  
    echo "  - NVIDIA Jetson Nano"
}

# Status command
cli_status_command() {
    echo "$(echo -e "\033[1;36m")System Status$(echo -e "\033[0m")"
    echo "============="
    echo ""
    
    # Check Git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "✓ Git repository: $(basename "$(git rev-parse --show-toplevel)")"
        echo "✓ Current branch: $(git branch --show-current)"
    else
        echo "✗ Git repository: Not found"
    fi
    
    # Check submodules
    if [ -d "poky" ]; then
        echo "✓ Poky submodule: Available"
    else
        echo "✗ Poky submodule: Missing"
    fi
    
    if [ -d "meta-openembedded" ]; then
        echo "✓ Meta-openembedded: Available" 
    else
        echo "✗ Meta-openembedded: Missing"
    fi
    
    # Check build directories
    echo ""
    echo "Build Directories:"
    for platform in beaglebone raspberrypi4 jetson-nano; do
        if [ -d "build-$platform" ]; then
            echo "✓ build-$platform: Exists"
        else
            echo "- build-$platform: Not created"
        fi
    done
    
    # Check disk space
    echo ""
    echo "Disk Space:"
    df -h . | tail -1 | awk '{print "Available: " $4 " (Used: " $5 ")"}'
}

# Clean command
cli_clean_command() {
    local target="${1:-help}"
    
    case "$target" in
        "all")
            echo "Cleaning all build directories..."
            rm -rf build-*
            echo "✓ All build directories removed"
            ;;
        "builds")
            echo "Cleaning build artifacts..."
            rm -rf build-*/tmp
            echo "✓ Build artifacts cleaned"
            ;;
        "downloads")
            echo "Cleaning downloads..."
            rm -rf downloads/*
            echo "✓ Downloads cleaned"
            ;;
        "sstate")
            echo "Cleaning sstate cache..."
            rm -rf sstate-cache/*
            echo "✓ Sstate cache cleaned"
            ;;
        "beaglebone"|"raspberrypi4"|"jetson-nano")
            echo "Cleaning build-$target..."
            rm -rf "build-$target"
            echo "✓ build-$target cleaned"
            ;;
        *)
            echo "Clean commands:"
            echo "  pk clean all          # Remove all build directories"
            echo "  pk clean builds       # Clean build artifacts only"
            echo "  pk clean downloads    # Clean download cache"
            echo "  pk clean sstate       # Clean sstate cache"
            echo "  pk clean [platform]   # Clean specific platform"
            ;;
    esac
}

# Setup command
cli_setup_command() {
    local platform="${1:-help}"
    local clean_flag=false
    local update_flag=false
    local configure_flag=false
    
    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                clean_flag=true
                shift
                ;;
            --update)
                update_flag=true
                shift
                ;;
            --configure)
                configure_flag=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    case "$platform" in
        "beaglebone"|"raspberrypi4"|"jetson-nano")
            echo "Setting up $platform environment..."
            
            if [ "$clean_flag" = true ]; then
                echo "Cleaning existing setup..."
                rm -rf "build-$platform"
            fi
            
            if [ "$update_flag" = true ]; then
                echo "Updating submodules..."
                git submodule update --init --recursive
            fi
            
            # Use existing setup script
            ./setup-build.sh "$platform"
            
            if [ "$configure_flag" = true ]; then
                echo "Auto-configuring platform..."
                cli_config_command "auto" "$platform"
            fi
            ;;
        *)
            echo "Setup commands:"
            echo "  pk setup beaglebone       # Setup BeagleBone"
            echo "  pk setup raspberrypi4     # Setup Raspberry Pi 4"
            echo "  pk setup jetson-nano      # Setup Jetson Nano"
            echo ""
            echo "Options:"
            echo "  --clean        Clean existing setup"
            echo "  --update       Update submodules"
            echo "  --configure    Auto-configure after setup"
            ;;
    esac
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi