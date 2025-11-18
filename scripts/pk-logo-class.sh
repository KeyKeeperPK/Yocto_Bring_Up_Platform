#!/bin/bash

# pk-logo-class.sh - PK Platform Logo Class and Animation System
# Professional logo system for PK Platform Development Kit

# Color definitions
declare -A PK_COLORS=(
    [RESET]='\033[0m'
    [BOLD]='\033[1m'
    [DIM]='\033[2m'
    [ITALIC]='\033[3m'
    [UNDERLINE]='\033[4m'
    [BLINK]='\033[5m'
    [REVERSE]='\033[7m'
    [STRIKETHROUGH]='\033[9m'
    
    # Basic colors
    [BLACK]='\033[30m'
    [RED]='\033[31m'
    [GREEN]='\033[32m'
    [YELLOW]='\033[33m'
    [BLUE]='\033[34m'
    [MAGENTA]='\033[35m'
    [CYAN]='\033[36m'
    [WHITE]='\033[37m'
    
    # Bright colors
    [BRIGHT_BLACK]='\033[90m'
    [BRIGHT_RED]='\033[91m'
    [BRIGHT_GREEN]='\033[92m'
    [BRIGHT_YELLOW]='\033[93m'
    [BRIGHT_BLUE]='\033[94m'
    [BRIGHT_MAGENTA]='\033[95m'
    [BRIGHT_CYAN]='\033[96m'
    [BRIGHT_WHITE]='\033[97m'
    
    # Background colors
    [BG_BLACK]='\033[40m'
    [BG_RED]='\033[41m'
    [BG_GREEN]='\033[42m'
    [BG_YELLOW]='\033[43m'
    [BG_BLUE]='\033[44m'
    [BG_MAGENTA]='\033[45m'
    [BG_CYAN]='\033[46m'
    [BG_WHITE]='\033[47m'
)

# Logo styles
PK_LOGO_ASCII="
╔══════════════════════════════════════════════════════════════╗
║                      PK Platform CLI                        ║
║               Yocto Development Kit v1.0.0                  ║
╚══════════════════════════════════════════════════════════════╝
"

PK_LOGO_MINIMAL="
═══════════════════════════════════════════════════════════════
 PK Platform Kit - Yocto Development System
═══════════════════════════════════════════════════════════════
"

PK_LOGO_COMPACT="[PK Platform CLI v1.0.0]"

PK_LOGO_BANNER="
██████╗ ██╗  ██╗    ██████╗ ██╗      █████╗ ████████╗███████╗ ██████╗ ██████╗ ███╗   ███╗
██╔══██╗██║ ██╔╝    ██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗████╗ ████║
██████╔╝█████╔╝     ██████╔╝██║     ███████║   ██║   █████╗  ██║   ██║██████╔╝██╔████╔██║
██╔═══╝ ██╔═██╗     ██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║
██║     ██║  ██╗    ██║     ███████╗██║  ██║   ██║   ██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
                              Development Kit v1.0.0
"

PK_LOGO_SIMPLE="
┌─────────────────────────────────────────────┐
│          PK Platform Development Kit        │
│              Yocto Build System             │
└─────────────────────────────────────────────┘
"

PK_LOGO_DOUBLE="
╔═════════════════════════════════════════════╗
║          PK Platform Development Kit        ║
║              Yocto Build System             ║
╚═════════════════════════════════════════════╝
"

# Spinner characters for different styles
declare -A PK_SPINNERS=(
    [classic]='|/-\'
    [dots]='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    [arrow]='←↖↑↗→↘↓↙'
    [circle]='◐◓◑◒'
    [square]='◰◳◲◱'
    [star]='✦✧'
)

# Progress bar characters
declare -A PK_PROGRESS=(
    [filled]='█'
    [empty]='░'
    [partial]='▌'
)

# Main logo display function
pk_logo_show() {
    local style="${1:-ascii}"
    local animation="${2:-none}"
    local title="${3:-}"
    local subtitle="${4:-}"
    local color_scheme="${5:-default}"
    
    case "$animation" in
        "typewriter")
            pk_logo_typewriter "$style" "$title" "$subtitle" "$color_scheme"
            ;;
        "fade")
            pk_logo_fade "$style" "$title" "$subtitle" "$color_scheme"
            ;;
        "slide")
            pk_logo_slide "$style" "$title" "$subtitle" "$color_scheme"
            ;;
        "matrix")
            pk_logo_matrix "$style" "$title" "$subtitle" "$color_scheme"
            ;;
        "rainbow")
            pk_logo_rainbow "$style" "$title" "$subtitle"
            ;;
        "animated")
            pk_logo_animated "$style" "$title" "$subtitle" "$color_scheme"
            ;;
        *)
            pk_logo_static "$style" "$title" "$subtitle" "$color_scheme"
            ;;
    esac
}

# Static logo display
pk_logo_static() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    local logo_content
    case "$style" in
        "banner") logo_content="$PK_LOGO_BANNER" ;;
        "minimal") logo_content="$PK_LOGO_MINIMAL" ;;
        "compact") logo_content="$PK_LOGO_COMPACT" ;;
        "simple") logo_content="$PK_LOGO_SIMPLE" ;;
        "double") logo_content="$PK_LOGO_DOUBLE" ;;
        *) logo_content="$PK_LOGO_ASCII" ;;
    esac
    
    # Apply color scheme
    pk_apply_color_scheme "$logo_content" "$color_scheme" "$title" "$subtitle"
}

# Typewriter animation
pk_logo_typewriter() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    local logo_content
    case "$style" in
        "banner") logo_content="$PK_LOGO_BANNER" ;;
        "minimal") logo_content="$PK_LOGO_MINIMAL" ;;
        "compact") logo_content="$PK_LOGO_COMPACT" ;;
        "simple") logo_content="$PK_LOGO_SIMPLE" ;;
        "double") logo_content="$PK_LOGO_DOUBLE" ;;
        *) logo_content="$PK_LOGO_ASCII" ;;
    esac
    
    # Clear screen and hide cursor
    clear
    printf '\033[?25l'
    
    # Typewriter effect
    while IFS= read -r line; do
        for ((i=0; i<${#line}; i++)); do
            printf '%s' "${line:$i:1}"
            sleep 0.01
        done
        printf '\n'
        sleep 0.05
    done <<< "$logo_content"
    
    # Add title and subtitle
    if [[ -n "$title" ]]; then
        echo ""
        pk_center_text "$title" "${PK_COLORS[BOLD]}${PK_COLORS[CYAN]}"
    fi
    
    if [[ -n "$subtitle" ]]; then
        pk_center_text "$subtitle" "${PK_COLORS[DIM]}${PK_COLORS[WHITE]}"
    fi
    
    # Show cursor
    printf '\033[?25h'
}

# Fade animation
pk_logo_fade() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    # Fade in effect
    for brightness in 0 1 2; do
        clear
        case $brightness in
            0) echo -e "${PK_COLORS[DIM]}" ;;
            1) echo -e "${PK_COLORS[RESET]}" ;;
            2) echo -e "${PK_COLORS[BOLD]}" ;;
        esac
        
        pk_logo_static "$style" "$title" "$subtitle" "$color_scheme"
        sleep 0.3
    done
    
    echo -e "${PK_COLORS[RESET]}"
}

# Slide animation
pk_logo_slide() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    local logo_content
    case "$style" in
        "banner") logo_content="$PK_LOGO_BANNER" ;;
        "minimal") logo_content="$PK_LOGO_MINIMAL" ;;
        "compact") logo_content="$PK_LOGO_COMPACT" ;;
        "simple") logo_content="$PK_LOGO_SIMPLE" ;;
        "double") logo_content="$PK_LOGO_DOUBLE" ;;
        *) logo_content="$PK_LOGO_ASCII" ;;
    esac
    
    local lines
    readarray -t lines <<< "$logo_content"
    local total_lines=${#lines[@]}
    
    clear
    
    # Slide down effect
    for ((i=0; i<total_lines; i++)); do
        clear
        for ((j=0; j<=i; j++)); do
            echo "${lines[$j]}"
        done
        sleep 0.1
    done
    
    # Add title and subtitle
    if [[ -n "$title" ]]; then
        echo ""
        pk_center_text "$title" "${PK_COLORS[BOLD]}${PK_COLORS[CYAN]}"
    fi
    
    if [[ -n "$subtitle" ]]; then
        pk_center_text "$subtitle" "${PK_COLORS[DIM]}${PK_COLORS[WHITE]}"
    fi
}

# Matrix-style animation
pk_logo_matrix() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    # Matrix effect
    printf '\033[?25l'  # Hide cursor
    
    for ((frame=0; frame<20; frame++)); do
        clear
        
        # Random matrix characters
        for ((i=0; i<5; i++)); do
            local line=""
            for ((j=0; j<60; j++)); do
                if ((RANDOM % 4 == 0)); then
                    line+="${PK_COLORS[GREEN]}$(printf \\$(printf '%03o' $((RANDOM%94+33))))"
                else
                    line+=" "
                fi
            done
            echo -e "$line${PK_COLORS[RESET]}"
        done
        sleep 0.1
    done
    
    # Show final logo
    clear
    pk_logo_static "$style" "$title" "$subtitle" "green"
    printf '\033[?25h'  # Show cursor
}

# Rainbow animation
pk_logo_rainbow() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    
    local colors=("RED" "YELLOW" "GREEN" "CYAN" "BLUE" "MAGENTA")
    
    for color in "${colors[@]}"; do
        clear
        echo -e "${PK_COLORS[$color]}"
        pk_logo_static "$style" "$title" "$subtitle" "$color"
        sleep 0.3
    done
    
    echo -e "${PK_COLORS[RESET]}"
}

# Animated loading effect
pk_logo_animated() {
    local style="${1:-ascii}"
    local title="${2:-}"
    local subtitle="${3:-}"
    local color_scheme="${4:-default}"
    
    local spinner_chars="${PK_SPINNERS[dots]}"
    local spinner_len=${#spinner_chars}
    
    # Show loading animation
    for ((i=0; i<20; i++)); do
        local char_index=$((i % spinner_len))
        local spinner_char="${spinner_chars:$char_index:1}"
        
        printf '\r%60s%s' "" "$spinner_char Loading..."
        sleep 0.1
    done
    
    # Clear loading line and show logo
    printf '\r%80s\r' ""
    pk_logo_static "$style" "$title" "$subtitle" "$color_scheme"
}

# Apply color scheme to logo
pk_apply_color_scheme() {
    local content="$1"
    local scheme="${2:-default}"
    local title="$3"
    local subtitle="$4"
    
    case "$scheme" in
        "green")
            echo -e "${PK_COLORS[GREEN]}$content${PK_COLORS[RESET]}"
            ;;
        "blue")
            echo -e "${PK_COLORS[BLUE]}$content${PK_COLORS[RESET]}"
            ;;
        "red")
            echo -e "${PK_COLORS[RED]}$content${PK_COLORS[RESET]}"
            ;;
        "cyan")
            echo -e "${PK_COLORS[CYAN]}$content${PK_COLORS[RESET]}"
            ;;
        "yellow")
            echo -e "${PK_COLORS[YELLOW]}$content${PK_COLORS[RESET]}"
            ;;
        "magenta")
            echo -e "${PK_COLORS[MAGENTA]}$content${PK_COLORS[RESET]}"
            ;;
        "bright")
            echo -e "${PK_COLORS[BOLD]}${PK_COLORS[WHITE]}$content${PK_COLORS[RESET]}"
            ;;
        *)
            echo -e "${PK_COLORS[CYAN]}$content${PK_COLORS[RESET]}"
            ;;
    esac
    
    # Add title and subtitle if provided
    if [[ -n "$title" ]]; then
        echo ""
        pk_center_text "$title" "${PK_COLORS[BOLD]}${PK_COLORS[CYAN]}"
    fi
    
    if [[ -n "$subtitle" ]]; then
        pk_center_text "$subtitle" "${PK_COLORS[DIM]}${PK_COLORS[WHITE]}"
    fi
}

# Center text in terminal
pk_center_text() {
    local text="$1"
    local color="${2:-}"
    local terminal_width
    terminal_width=$(tput cols 2>/dev/null || echo 80)
    local text_length=${#text}
    local padding=$(((terminal_width - text_length) / 2))
    
    printf "%*s" $padding ""
    echo -e "${color}${text}${PK_COLORS[RESET]}"
}

# Progress bar functionality
pk_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local label="${4:-Progress}"
    
    local percentage=$((current * 100 / total))
    local filled_width=$((current * width / total))
    local empty_width=$((width - filled_width))
    
    local filled_bar=""
    local empty_bar=""
    
    for ((i=0; i<filled_width; i++)); do
        filled_bar+="${PK_PROGRESS[filled]}"
    done
    
    for ((i=0; i<empty_width; i++)); do
        empty_bar+="${PK_PROGRESS[empty]}"
    done
    
    printf '\r%s: [%s%s%s%s] %d%%' \
        "$label" \
        "${PK_COLORS[GREEN]}" \
        "$filled_bar" \
        "${PK_COLORS[RESET]}" \
        "$empty_bar" \
        "$percentage"
}

# Spinner functionality
pk_spinner() {
    local message="${1:-Loading}"
    local style="${2:-dots}"
    local duration="${3:-5}"
    
    local spinner_chars="${PK_SPINNERS[$style]}"
    local spinner_len=${#spinner_chars}
    local end_time=$((SECONDS + duration))
    
    printf '\033[?25l'  # Hide cursor
    
    while [[ $SECONDS -lt $end_time ]]; do
        for ((i=0; i<spinner_len; i++)); do
            local char="${spinner_chars:$i:1}"
            printf '\r%s %s' "$char" "$message"
            sleep 0.1
            
            if [[ $SECONDS -ge $end_time ]]; then
                break
            fi
        done
    done
    
    printf '\r%*s\r' $((${#message} + 3)) ""  # Clear line
    printf '\033[?25h'  # Show cursor
}

# Export functions for use in other scripts
export -f pk_logo_show
export -f pk_logo_static
export -f pk_progress_bar
export -f pk_spinner
export -f pk_center_text