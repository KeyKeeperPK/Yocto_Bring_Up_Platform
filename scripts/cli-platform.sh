#!/bin/bash

# CLI Platform Functions
# Platform management functionality for the PK Platform CLI

# Main platform command handler
cli_platform_command() {
    local subcommand="${1:-help}"
    
    case "$subcommand" in
        "list"|"ls")
            show_platform_list
            ;;
        "info"|"show")
            shift
            show_platform_info "$@"
            ;;
        "version"|"ver")
            show_platform_versions
            ;;
        "configure"|"config")
            shift
            configure_platform "$@"
            ;;
        "status")
            show_platform_status
            ;;
        "help"|"-h"|"--help"|*)
            show_platform_usage
            ;;
    esac
}

# List all available platforms
show_platform_list() {
    print_header "Available Platforms"
    echo ""
    
    print_subheader "Industrial IoT Platforms:"
    echo ""
    
    # BeagleBone
    echo -e "${CLI_CYAN}beaglebone${CLI_NC}"
    echo "  Target: BeagleBone Black/Green"
    echo "  Features: CAN, UART, SPI, WiFi (headless)"
    echo "  Use case: Industrial automation, headless IoT"
    echo "  Recipe: beaglebone-init-scripts"
    if [ -d "build-beaglebone" ]; then
        echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
    else
        echo -e "  Status: ${CLI_YELLOW}- Not configured${CLI_NC}"
    fi
    echo ""
    
    # Raspberry Pi 4
    echo -e "${CLI_MAGENTA}raspberrypi4${CLI_NC}"
    echo "  Target: Raspberry Pi 4 64-bit"
    echo "  Features: SSH, WiFi, Docker, CAN-FD, UART, SPI, Ethernet"
    echo "  Use case: Edge computing, container workloads"
    echo "  Recipe: rpi4-init-scripts"
    if [ -d "build-raspberrypi4" ]; then
        echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
    else
        echo -e "  Status: ${CLI_YELLOW}- Not configured${CLI_NC}"
    fi
    echo ""
    
    # Jetson Nano
    echo -e "${CLI_BLUE}jetson-nano${CLI_NC}"
    echo "  Target: NVIDIA Jetson Nano"
    echo "  Features: GPU acceleration, AI/ML workloads"
    echo "  Use case: Computer vision, AI inference"
    echo "  Recipe: Standard Jetson configuration"
    if [ -d "build-jetson-nano" ]; then
        echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
    else
        echo -e "  Status: ${CLI_YELLOW}- Not configured${CLI_NC}"
    fi
    echo ""
    
    print_info "Use 'pk platform info [platform]' for detailed information"
}

# Show detailed platform information
show_platform_info() {
    local platform="${1:-help}"
    
    if [[ "$platform" == "help" || -z "$platform" ]]; then
        print_info "Usage: pk platform info [PLATFORM]"
        print_info "Available platforms: beaglebone, raspberrypi4, jetson-nano"
        return
    fi
    
    if ! validate_platform "$platform"; then
        print_error "Invalid platform: $platform"
        return 1
    fi
    
    case "$platform" in
        "beaglebone")
            show_beaglebone_info
            ;;
        "raspberrypi4")
            show_raspberrypi4_info
            ;;
        "jetson-nano")
            show_jetson_nano_info
            ;;
    esac
}

# BeagleBone detailed info
show_beaglebone_info() {
    print_header "BeagleBone Industrial Platform"
    echo ""
    
    print_subheader "Hardware Specifications:"
    echo "  CPU: TI AM3358 ARM Cortex-A8 @ 1GHz"
    echo "  RAM: 512MB DDR3"
    echo "  Storage: microSD card"
    echo "  Connectivity: Ethernet, USB"
    echo ""
    
    print_subheader "Industrial Features:"
    echo "  CAN bus support (classic CAN + CAN-FD via patch)"
    echo "  Multiple UART interfaces (ttyO1-5)"
    echo "  SPI interface support (2 buses)"
    echo "  WiFi support (USB adapters)"
    echo "  Headless operation (no UI dependencies)"
    echo "  Industrial IoT tools included"
    echo ""
    
    print_subheader "Configuration:"
    echo "  Recipe: beaglebone-init-scripts v1.0.0"
    echo "  Machine: beaglebone-yocto"
    echo "  Init system: systemd"
    echo "  Features: CAN, UART, SPI, WiFi"
    echo ""
    
    print_subheader "Build Information:"
    if [ -d "build-beaglebone" ]; then
        echo -e "  Status: ${CLI_GREEN} Configured${CLI_NC}"
        echo "  Build dir: build-beaglebone"
        if [ -f "build-beaglebone/conf/local.conf" ]; then
            echo "  Config:  local.conf present"
        fi
        if [ -f "build-beaglebone/conf/bblayers.conf" ]; then
            echo "  Layers: bblayers.conf present"
        fi
    else
        echo -e "  Status: ${CLI_YELLOW}Not configured${CLI_NC}"
        print_info "Run 'pk setup beaglebone' to configure"
    fi
    echo ""
    
    print_subheader "Available Scripts:"
    echo "  beagle-hardware-init.sh - Main initialization"
    echo "  beagle-can-setup.sh - CAN interface setup"
    echo "  beagle-uart-setup.sh - UART configuration"
    echo "  beagle-spi-setup.sh - SPI configuration"
    echo "  beagle-wifi-setup.sh - WiFi setup"
}

# Raspberry Pi 4 detailed info
show_raspberrypi4_info() {
    print_header "Raspberry Pi 4 Industrial Platform"
    echo ""
    
    print_subheader "Hardware Specifications:"
    echo "  CPU: Broadcom BCM2711 ARM Cortex-A72 @ 1.5GHz (quad-core)"
    echo "  RAM: 2GB/4GB/8GB DDR4"
    echo "  Storage: microSD card"
    echo "  Connectivity: Gigabit Ethernet, WiFi 5, Bluetooth 5.0, USB 3.0"
    echo ""
    
    print_subheader "Industrial Features:"
    echo "  SSH server (secure remote access)"
    echo "  WiFi and Bluetooth connectivity"
    echo "  Docker container platform"
    echo "  Advanced CAN-FD support with hardware detection"
    echo "  Multiple UART interfaces (ttyAMA1-5)"
    echo "  6 SPI buses with extensive device support"
    echo "  Gigabit Ethernet for reliable networking"
    echo "  GPIO and I2C access for sensors"
    echo ""
    
    print_subheader "Configuration:"
    echo "  Recipe: rpi4-init-scripts v1.0.0"
    echo "  Machine: raspberrypi4-64"
    echo "  Init system: systemd"
    echo "  Features: SSH, WiFi, Docker, CAN-FD, UART, SPI, Ethernet"
    echo ""
    
    print_subheader "Build Information:"
    if [ -d "build-raspberrypi4" ]; then
        echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
        echo "  Build dir: build-raspberrypi4"
        if [ -f "build-raspberrypi4/conf/local.conf" ]; then
            echo "  Config: ✓ local.conf present"
        fi
        if [ -f "build-raspberrypi4/conf/bblayers.conf" ]; then
            echo "  Layers: ✓ bblayers.conf present"
        fi
    else
        echo -e "  Status: ${CLI_YELLOW}Not configured${CLI_NC}"
        print_info "Run 'pk setup raspberrypi4' to configure"
    fi
    echo ""
    
    print_subheader "Available Scripts:"
    echo "  rpi4-hardware-init.sh - Complete system initialization"
    echo "  rpi4-can-setup.sh - CAN/CAN-FD setup with hardware detection"
    echo "  rpi4-uart-setup.sh - Multi-UART configuration"
    echo "  rpi4-spi-setup.sh - 6-bus SPI support with utilities"
    echo ""
    
    print_subheader "Runtime Utilities:"
    echo "  rpi4-system-info - Comprehensive system information"
    echo "  uart-test - UART interface testing"
    echo "  spi-test - SPI interface testing"
    echo "  spi-speed-test - SPI performance benchmarking"
}

# Jetson Nano detailed info
show_jetson_nano_info() {
    print_header "NVIDIA Jetson Nano Platform"
    echo ""
    
    print_subheader "Hardware Specifications:"
    echo "  CPU: Quad-core ARM Cortex-A57 @ 1.43GHz"
    echo "  GPU: 128-core Maxwell GPU"
    echo "  RAM: 4GB 64-bit LPDDR4"
    echo "  Storage: microSD card"
    echo "  Connectivity: Gigabit Ethernet, USB 3.0/2.0"
    echo ""
    
    print_subheader "AI/ML Features:"
    echo "  ✓ CUDA support"
    echo "  ✓ TensorRT optimization"
    echo "  ✓ Computer vision libraries"
    echo "  ✓ AI inference acceleration"
    echo ""
    
    print_subheader "Configuration:"
    echo "  Recipe: Standard Jetson configuration"
    echo "  Machine: jetson-nano"
    echo "  BSP: meta-tegra"
    echo ""
    
    print_subheader "Build Information:"
    if [ -d "build-jetson-nano" ]; then
        echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
        echo "  Build dir: build-jetson-nano"
    else
        echo -e "  Status: ${CLI_YELLOW}Not configured${CLI_NC}"
        print_info "Run 'pk setup jetson-nano' to configure"
    fi
}

# Show platform versions
show_platform_versions() {
    print_header "Platform Versions"
    
    # Use existing platform version manager
    if [ -f "./scripts/platform-version-manager.sh" ]; then
        ./scripts/platform-version-manager.sh status
    else
        echo ""
        print_subheader "BeagleBone:"
        echo "  Version: 1.0.0"
        echo "  Recipe: beaglebone-init-scripts"
        echo ""
        
        print_subheader "Raspberry Pi 4:"
        echo "  Version: 1.0.0"  
        echo "  Recipe: rpi4-init-scripts"
        echo ""
        
        print_subheader "Jetson Nano:"
        echo "  Version: Standard"
        echo "  Recipe: Standard Tegra configuration"
    fi
}

# Configure platform
configure_platform() {
    local platform="${1:-help}"
    local action="${2:-interactive}"
    
    if [[ "$platform" == "help" || -z "$platform" ]]; then
        print_info "Usage: pk platform configure [PLATFORM] [auto|interactive]"
        return
    fi
    
    if ! validate_platform "$platform"; then
        print_error "Invalid platform: $platform"
        return 1
    fi
    
    print_info "Configuring $platform platform..."
    
    case "$action" in
        "auto")
            auto_configure_platform "$platform"
            ;;
        "interactive"|*)
            interactive_configure_platform "$platform"
            ;;
    esac
}

# Auto configure platform
auto_configure_platform() {
    local platform="$1"
    print_info "Auto-configuring $platform with default settings"
    
    # This would use the existing setup script
    ./scripts/setup-build.sh "$platform"
}

# Interactive configure platform
interactive_configure_platform() {
    local platform="$1"
    
    print_info "Interactive configuration for $platform"
    print_warning "This feature is planned for future release"
    print_info "For now, use: pk setup $platform"
}

# Show platform status
show_platform_status() {
    print_header "Platform Status Overview"
    echo ""
    
    for platform in beaglebone raspberrypi4 jetson-nano; do
        if [ -d "build-$platform" ]; then
            echo -e "${CLI_GREEN}✓ $platform${CLI_NC} - Configured"
        else
            echo -e "${CLI_YELLOW}- $platform${CLI_NC} - Not configured"
        fi
    done
    
    echo ""
    print_info "Use 'pk platform info [platform]' for detailed information"
}

# Show platform usage
show_platform_usage() {
    cat << EOF
$(print_header "PLATFORM COMMAND USAGE")

SYNTAX:
    pk platform [COMMAND] [OPTIONS]

COMMANDS:
    list, ls            List all available platforms
    info [PLATFORM]     Show detailed platform information
    version, ver        Show platform versions and status
    configure [PLATFORM] Configure platform settings
    status              Show platform status overview

EXAMPLES:
    pk platform list                    # List all platforms
    pk platform info beaglebone        # Show BeagleBone details
    pk platform version                # Show all platform versions
    pk platform status                 # Show configuration status

PLATFORM DETAILS:
    beaglebone     - Industrial IoT, headless operation
    raspberrypi4   - Edge computing, Docker support  
    jetson-nano    - AI/ML inference, GPU acceleration

EOF
}