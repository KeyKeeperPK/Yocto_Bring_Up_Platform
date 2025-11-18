#!/bin/bash

# PK Logo Demo Script
# Showcases all available logo styles and animations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pk-logo-class.sh"

show_demo_menu() {
    clear
    echo "======================================"
    echo "    PK Logo Class Demonstration"
    echo "======================================"
    echo ""
    echo "Available demos:"
    echo ""
    echo "1. Basic Style Logo"
    echo "2. 3D Style Logo"
    echo "3. Neon Style Logo"
    echo "4. Gradient Style Logo"
    echo "5. Matrix Style Logo"
    echo "6. Fire Style Logo"
    echo "7. Animated Matrix"
    echo "8. Animated Fire"
    echo "9. Typewriter Effect"
    echo "10. Random Style"
    echo "11. All Styles Showcase"
    echo "12. Usage Examples"
    echo "0. Exit"
    echo ""
    read -p "Select option (0-12): " choice
    echo ""
}

demo_basic() {
    echo "Basic Style Demo:"
    echo "================="
    pk_logo_style_basic '\033[1;36m'
    echo ""
    read -p "Press Enter to continue..."
}

demo_3d() {
    echo "3D Style Demo:"
    echo "=============="
    pk_logo_style_3d '\033[1;33m' '\033[0;90m'
    echo ""
    read -p "Press Enter to continue..."
}

demo_neon() {
    echo "Neon Style Demo:"
    echo "================"
    pk_logo_style_neon
    echo ""
    read -p "Press Enter to continue..."
}

demo_gradient() {
    echo "Gradient Style Demo:"
    echo "==================="
    pk_logo_style_gradient
    echo ""
    read -p "Press Enter to continue..."
}

demo_matrix() {
    echo "Matrix Style Demo:"
    echo "=================="
    pk_logo_style_matrix
    echo ""
    read -p "Press Enter to continue..."
}

demo_fire() {
    echo "Fire Style Demo:"
    echo "================"
    pk_logo_style_fire
    echo ""
    read -p "Press Enter to continue..."
}

demo_animated_matrix() {
    echo "Starting animated matrix demo..."
    sleep 1
    pk_logo_popup_animated "matrix" "Platform Kit" "Matrix Mode"
}

demo_animated_fire() {
    echo "Starting animated fire demo..."
    sleep 1
    pk_logo_popup_animated "fire" "Platform Kit" "Fire Mode"
}

demo_typewriter() {
    echo "Starting typewriter effect demo..."
    sleep 1
    pk_logo_popup_typewriter "PK Platform Development Kit" '\033[1;32m'
}

demo_random() {
    echo "Starting random style demo..."
    sleep 1
    pk_logo_popup_random
}

demo_all_styles() {
    echo "All Styles Showcase"
    echo "==================="
    echo ""
    
    styles=("basic" "3d" "neon" "gradient" "matrix" "fire")
    
    for style in "${styles[@]}"; do
        echo "Style: $style"
        echo "-------------"
        
        case "$style" in
            "basic") pk_logo_style_basic '\033[1;36m' ;;
            "3d") pk_logo_style_3d '\033[1;33m' '\033[0;90m' ;;
            "neon") pk_logo_style_neon ;;
            "gradient") pk_logo_style_gradient ;;
            "matrix") pk_logo_style_matrix ;;
            "fire") pk_logo_style_fire ;;
        esac
        
        echo ""
        sleep 2
    done
    
    read -p "Press Enter to continue..."
}

show_usage_examples() {
    clear
    cat << 'EOF'
PK Logo Class Usage Examples
============================

1. Basic popup logo:
   pk_logo_show "popup" "basic" "My Title" "My Subtitle"

2. Animated logo:
   pk_logo_show "animated" "matrix" "Platform Kit" "Loading"

3. Typewriter effect:
   pk_logo_show "typewriter" "Welcome to Platform Kit"

4. Random style:
   pk_logo_show "random"

5. Just display a style:
   pk_logo_show "style" "neon"

6. In shell scripts:
   # Source the logo class
   source "pk-logo-class.sh"
   
   # Show logo at script start
   pk_logo_show "popup" "gradient" "Build System" "Starting"

7. Different styles available:
   - basic: Simple colored logo
   - 3d: Logo with shadow effect
   - neon: Boxed neon-style logo
   - gradient: Rainbow gradient colors
   - matrix: Matrix-style green
   - fire: Fire-colored gradient

8. Function calls:
   pk_logo_popup_centered "style" "title" "subtitle" "duration"
   pk_logo_popup_animated "style" "title" "subtitle"
   pk_logo_popup_typewriter "text" "color" "delay"
   pk_logo_popup_random

9. Integration in build scripts:
   #!/bin/bash
   source "pk-logo-class.sh"
   pk_logo_show "animated" "fire" "Build System" "Compiling"
   # ... rest of script

10. Customization:
    - Modify colors in pk-logo-class.sh
    - Add new styles by creating new functions
    - Adjust animation timing and effects
    - Create custom ASCII art variations

EOF
    echo ""
    read -p "Press Enter to return to menu..."
}

# Main demo loop
while true; do
    show_demo_menu
    
    case $choice in
        1) demo_basic ;;
        2) demo_3d ;;
        3) demo_neon ;;
        4) demo_gradient ;;
        5) demo_matrix ;;
        6) demo_fire ;;
        7) demo_animated_matrix ;;
        8) demo_animated_fire ;;
        9) demo_typewriter ;;
        10) demo_random ;;
        11) demo_all_styles ;;
        12) show_usage_examples ;;
        0) 
            echo "Thanks for trying PK Logo Class!"
            pk_logo_show "popup" "gradient" "Goodbye!" "See you later"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            ;;
    esac
done