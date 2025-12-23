#!/bin/bash

# Simple numbered menu for WSL compatibility
# No fancy terminal control, just works

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
C_TITLE="\033[1;36m"    # Cyan
C_MENU="\033[1;33m"     # Yellow
C_INFO="\033[0;32m"     # Green
C_ERROR="\033[0;31m"    # Red
C_RESET="\033[0m"

# Clear and show header
show_header() {
    clear
    echo -e "${C_TITLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        PK Platform - Yocto Build System                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
}

# Show main menu
show_main_menu() {
    show_header
    echo -e "${C_MENU}Main Menu:${C_RESET}"
    echo ""
    echo "  1) Build Platform Image"
    echo "  2) Setup Build Environment"
    echo "  3) Platform Configuration"
    echo "  4) Kernel Configuration"
    echo "  5) Source Management"
    echo "  6) System Status"
    echo "  7) Flash to SD Card"
    echo "  8) Utils Check"
    echo "  9) Clean Build"
    echo "  0) Exit"
    echo ""
    echo -n "Enter choice [0-8]: "
}

# Show platform menu
show_platform_menu() {
    show_header
    echo -e "${C_MENU}Select Target Platform:${C_RESET}"
    echo ""
    echo "  1) BeagleBone Black/Green"
    echo "  2) Raspberry Pi 4 64-bit"
    echo "  3) NVIDIA Jetson Nano"
    echo "  0) Back to Main Menu"
    echo ""
    echo -n "Enter choice [0-3]: "
}

# Get platform name
get_platform() {
    case $1 in
        1) echo "beaglebone" ;;
        2) echo "raspberrypi4" ;;
        3) echo "jetson-nano" ;;
        *) echo "" ;;
    esac
}

# Execute command with status
execute_command() {
    local title="$1"
    local command="$2"
    
    show_header
    echo -e "${C_INFO}Executing: $title${C_RESET}"
    echo ""
    
    eval "$command"
    local result=$?
    
    echo ""
    if [[ $result -eq 0 ]]; then
        echo -e "${C_INFO}✓ Command completed successfully${C_RESET}"
    else
        echo -e "${C_ERROR}✗ Command failed with exit code $result${C_RESET}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    return $result
}

# Main loop
main() {
    cd "$PROJECT_ROOT" || exit 1
    
    while true; do
        show_main_menu
        read choice
        
        case $choice in
            1)  # Build
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                if [[ -n "$platform" ]]; then
                    execute_command "Build $platform" \
                        "'$SCRIPT_DIR/pk-cli-original.sh' build '$platform'"
                fi
                ;;
            2)  # Setup
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                if [[ -n "$platform" ]]; then
                    execute_command "Setup $platform" \
                        "'$SCRIPT_DIR/pk-cli-original.sh' setup '$platform'"
                fi
                ;;
            3)  # Config
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                if [[ -n "$platform" ]]; then
                    execute_command "Update Configuration for $platform" \
                        "'$SCRIPT_DIR/pk-cli-original.sh' config update '$platform'"
                fi
                ;;
            4)  # Kernel
                show_header
                echo -e "${C_MENU}Kernel Management:${C_RESET}"
                echo ""
                echo "  1) Kernel Menuconfig"
                echo "  2) Build Kernel Only"
                echo "  3) Clean Kernel"
                echo "  0) Back"
                echo ""
                read -p "Enter choice [0-3]: " kernel_choice
                
                case $kernel_choice in
                    1)
                        show_platform_menu
                        read platform_choice
                        platform=$(get_platform $platform_choice)
                        if [[ -n "$platform" ]]; then
                            execute_command "Kernel Menuconfig for $platform" \
                                "'$SCRIPT_DIR/pk-cli-original.sh' kernel-menuconfig '$platform'"
                        fi
                        ;;
                    2)
                        show_platform_menu
                        read platform_choice
                        platform=$(get_platform $platform_choice)
                        if [[ -n "$platform" ]]; then
                            execute_command "Build Kernel for $platform" \
                                "'$SCRIPT_DIR/pk-cli-original.sh' kernel-build '$platform'"
                        fi
                        ;;
                    3)
                        show_platform_menu
                        read platform_choice
                        platform=$(get_platform $platform_choice)
                        if [[ -n "$platform" ]]; then
                            execute_command "Clean Kernel for $platform" \
                                "'$SCRIPT_DIR/pk-cli-original.sh' kernel-clean '$platform'"
                        fi
                        ;;
                esac
                ;;
            5)  # Sources
                show_header
                echo -e "${C_MENU}Source Management:${C_RESET}"
                echo ""
                echo "  1) Update Sources"
                echo "  2) Clean Downloads"
                echo "  3) Clean Shared State Cache"
                echo "  0) Back"
                echo ""
                read -p "Enter choice [0-3]: " source_choice
                
                case $source_choice in
                    1)
                        execute_command "Update Sources" \
                            "'$SCRIPT_DIR/pk-cli-original.sh' sources-update"
                        ;;
                    2)
                        execute_command "Clean Downloads" \
                            "'$SCRIPT_DIR/pk-cli-original.sh' sources-clean-downloads"
                        ;;
                    3)
                        execute_command "Clean Shared State Cache" \
                            "'$SCRIPT_DIR/pk-cli-original.sh' sources-clean-sstate"
                        ;;
                esac
                ;;
            6)  # Status
                execute_command "System Status" \
                    "'$SCRIPT_DIR/pk-cli-original.sh' status"
                ;;
            7)  # Flash SD Card
                show_header
                echo -e "${C_MENU}Flash to SD Card:${C_RESET}"
                echo ""
                
                # Select platform
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                
                if [[ -n "$platform" ]]; then
                    echo ""
                    echo -e "${C_INFO}Available block devices:${C_RESET}"
                    lsblk -d -o NAME,SIZE,TYPE,TRAN,MODEL 2>/dev/null | grep -E "disk|NAME" || true
                    echo ""
                    read -p "Enter device path (e.g., /dev/sdb): " device
                    
                    if [[ -n "$device" ]]; then
                        execute_command "Flash $platform to $device" \
                            "'$SCRIPT_DIR/flash-sdcard.sh' -p '$platform' -d '$device'"
                    else
                        echo -e "${C_ERROR}No device specified${C_RESET}"
                        sleep 2
                    fi
                fi
                ;;
            8)  # check utils
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                if [[ -n "$platform" ]]; then
                    # Source required dependencies
                    source "$SCRIPT_DIR/pk-logo-class.sh"
                    source "$SCRIPT_DIR/cli-core.sh"
                    source "$SCRIPT_DIR/cli-utils.sh"
                    execute_command "Check $platform utils" \
                        "cli_utils_command check"
                    
                    # Offer to fix missing dependencies
                    echo ""
                    echo -e "${C_MENU}Would you like to install missing dependencies? (y/N): ${C_RESET}"
                    read -p "" fix_confirm
                    if [[ "$fix_confirm" =~ ^[Yy]$ ]]; then
                        show_header
                        echo -e "${C_INFO}Installing missing dependencies from requirements.txt...${C_RESET}"
                        echo ""
                        
                        # Read requirements.txt and check for missing tools
                        local requirements_file="$PROJECT_ROOT/requirements.txt"
                        if [[ ! -f "$requirements_file" ]]; then
                            echo -e "${C_ERROR}requirements.txt not found!${C_RESET}"
                            read -p "Press Enter to continue..."
                            continue
                        fi
                        
                        local missing_tools=()
                        while IFS= read -r line || [[ -n "$line" ]]; do
                            # Skip comments and empty lines
                            [[ "$line" =~ ^#.*$ ]] && continue
                            [[ -z "$line" ]] && continue
                            
                            local tool=$(echo "$line" | xargs)  # Trim whitespace
                            
                            # Check if tool is installed
                            if ! command -v "$tool" >/dev/null 2>&1 && ! dpkg -l | grep -q "^ii  $tool "; then
                                missing_tools+=("$tool")
                            fi
                        done < "$requirements_file"
                        
                        if [ ${#missing_tools[@]} -gt 0 ]; then
                            echo -e "${C_INFO}Missing packages: ${missing_tools[*]}${C_RESET}"
                            echo ""
                            
                            # Detect package manager and install
                            if command -v apt-get >/dev/null 2>&1; then
                                echo "Using apt-get..."
                                sudo apt-get update
                                sudo apt-get install -y "${missing_tools[@]}"
                            elif command -v dnf >/dev/null 2>&1; then
                                echo "Using dnf..."
                                sudo dnf install -y "${missing_tools[@]}"
                            elif command -v yum >/dev/null 2>&1; then
                                echo "Using yum..."
                                sudo yum install -y "${missing_tools[@]}"
                            else
                                echo -e "${C_ERROR}No supported package manager found${C_RESET}"
                                echo "Please install manually: ${missing_tools[*]}"
                            fi
                            
                            echo ""
                            echo -e "${C_INFO}✓ Installation complete${C_RESET}"
                        else
                            echo -e "${C_INFO}All required tools are already installed${C_RESET}"
                        fi
                        
                        echo ""
                        read -p "Press Enter to continue..."
                    fi
                fi
                ;;

            9)  # Clean
                show_platform_menu
                read platform_choice
                platform=$(get_platform $platform_choice)
                if [[ -n "$platform" ]]; then
                    echo ""
                    read -p "Are you sure you want to clean $platform? (y/N): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        execute_command "Clean $platform" \
                            "'$SCRIPT_DIR/pk-cli-original.sh' clean '$platform'"
                    fi
                fi
                ;;
            0)  # Exit
                clear
                echo -e "${C_INFO}Goodbye!${C_RESET}"
                exit 0
                ;;
            *)
                echo -e "${C_ERROR}Invalid choice. Please try again.${C_RESET}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
