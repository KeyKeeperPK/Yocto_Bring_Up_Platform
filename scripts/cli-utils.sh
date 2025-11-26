#!/bin/bash

# CLI Utility Functions
# Utility and diagnostic functionality for the PK Platform CLI

# Main utils command handler
cli_utils_command() {
    local subcommand="${1:-help}"
    
    case "$subcommand" in
        "doctor"|"check")
            system_doctor
            ;;
        "logs")
            shift
            show_logs "$@"
            ;;
        "monitor")
            shift
            monitor_system "$@"
            ;;
        "cleanup")
            shift
            cleanup_system "$@"
            ;;
        "benchmark")
            shift
            benchmark_system "$@"
            ;;
        "demo")
            shift
            run_demo "$@"
            ;;
        "env")
            show_environment
            ;;
        "disk")
            check_disk_usage
            ;;
        "help"|"-h"|"--help"|*)
            show_utils_usage
            ;;
    esac
}

# System doctor - comprehensive health check
system_doctor() {
    print_header "PK Platform System Doctor"
    echo ""
    
    local issues=0
    
    # Environment check
    print_subheader "Environment Check:"
    local env=$(detect_environment)
    print_info "Operating System: $env"
    
    # Git repository check
    print_subheader "Git Repository:"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_success "Git repository: $(basename "$(git rev-parse --show-toplevel)")"
        print_info "Current branch: $(git branch --show-current)"
        
        # Check for uncommitted changes
        if ! git diff-index --quiet HEAD --; then
            print_warning "Uncommitted changes detected"
        fi
    else
        print_error "Not in a Git repository"
        ((issues++))
    fi
    
    # Submodules check
    print_subheader "Submodules:"
    if [ -f ".gitmodules" ]; then
        if [ -d "poky" ] && [ -f "poky/oe-init-build-env" ]; then
            print_success "Poky submodule: Initialized"
        else
            print_error "Poky submodule: Missing or not initialized"
            print_info "Run: git submodule update --init --recursive"
            ((issues++))
        fi
        
        if [ -d "meta-openembedded" ] && [ -d "meta-openembedded/meta-oe" ]; then
            print_success "meta-openembedded: Initialized"
        else
            print_error "meta-openembedded: Missing or not initialized"
            ((issues++))
        fi
    else
        print_warning "No .gitmodules file found"
    fi
    
    # Platform BSP check
    print_subheader "Platform BSPs:"
    if [ -d "meta-raspberrypi" ]; then
        print_success "meta-raspberrypi: Available"
    else
        print_warning "meta-raspberrypi: Not found"
    fi
    
    if [ -d "meta-tegra" ]; then
        print_success "meta-tegra: Available"
    else
        print_warning "meta-tegra: Not found"
    fi
    
    # Custom layers check
    print_subheader "Custom Layers:"
    if [ -d "meta-custom" ]; then
        print_success "meta-custom: Available"
        
        if [ -d "meta-custom/recipes-core/beaglebone-init-scripts" ]; then
            print_success "BeagleBone scripts: Available"
        fi
        
        if [ -d "meta-custom/recipes-core/rpi4-init-scripts" ]; then
            print_success "RPi4 scripts: Available"
        fi
    else
        print_warning "meta-custom: Not found"
    fi
    
    # System resources
    print_subheader "System Resources:"
    check_system_resources
    
    # Build directories
    print_subheader "Build Directories:"
    for platform in beaglebone raspberrypi4 jetson-nano; do
        if [ -d "build-$platform" ]; then
            local size=$(du -sh "build-$platform" 2>/dev/null | cut -f1)
            print_success "$platform: Configured ($size)"
        else
            print_info "$platform: Not configured"
        fi
    done
    
    # Tool dependencies
    print_subheader "Tool Dependencies:"
    local tools=("git" "python3" "gcc" "make" "chrpath" "diffstat" "gawk" "pzstd")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            print_success "$tool: Available"
        else
            print_error "$tool: Not found"
            ((issues++))
        fi
    done
    
    # Summary
    echo ""
    print_header "Doctor Summary"
    if [ $issues -eq 0 ]; then
        print_success "System is healthy and ready for building"
    else
        print_warning "$issues issue(s) found - see above for details"
    fi
}

# Show logs
show_logs() {
    local platform="${1:-all}"
    local log_type="${2:-build}"
    
    local logs_dir="logs"
    
    if [ ! -d "$logs_dir" ]; then
        print_error "Logs directory not found: $logs_dir"
        return 1
    fi
    
    case "$log_type" in
        "build")
            show_build_logs "$platform"
            ;;
        "cli")
            show_cli_logs
            ;;
        "error")
            show_error_logs
            ;;
        "latest")
            show_latest_logs "$platform"
            ;;
        *)
            print_error "Unknown log type: $log_type"
            print_info "Valid types: build, cli, error, latest"
            return 1
            ;;
    esac
}

# Show build logs
show_build_logs() {
    local platform="$1"
    local logs_dir="logs"
    
    if [[ "$platform" == "all" ]]; then
        print_header "All Build Logs"
        ls -la "$logs_dir"/build-*.log 2>/dev/null || print_info "No build logs found"
    else
        if ! validate_platform "$platform"; then
            print_error "Invalid platform: $platform"
            return 1
        fi
        
        print_header "Build Logs for $platform"
        local logs=($(ls -t "$logs_dir"/build-${platform}-*.log 2>/dev/null))
        
        if [ ${#logs[@]} -eq 0 ]; then
            print_info "No build logs found for $platform"
            return
        fi
        
        print_info "Available logs:"
        for i in "${!logs[@]}"; do
            local log="${logs[$i]}"
            local size=$(ls -lh "$log" | awk '{print $5}')
            local date=$(ls -l "$log" | awk '{print $6, $7, $8}')
            echo "  $((i+1)). $(basename "$log") ($size, $date)"
        done
        
        read -p "Select log number (1-${#logs[@]}) or Enter for latest: " selection
        
        if [[ -z "$selection" ]]; then
            selection=1
        fi
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#logs[@]} ]; then
            local selected_log="${logs[$((selection-1))]}"
            print_info "Showing: $(basename "$selected_log")"
            echo ""
            
            if command -v less >/dev/null 2>&1; then
                less "$selected_log"
            else
                tail -100 "$selected_log"
            fi
        else
            print_error "Invalid selection"
        fi
    fi
}

# Show CLI logs
show_cli_logs() {
    local cli_log="logs/cli.log"
    
    if [ -f "$cli_log" ]; then
        print_header "CLI Command Log"
        tail -50 "$cli_log"
    else
        print_info "No CLI log file found"
    fi
}

# Show error logs
show_error_logs() {
    local error_log="logs/cli-errors.log"
    
    if [ -f "$error_log" ]; then
        print_header "Error Log"
        tail -20 "$error_log"
    else
        print_info "No error log file found"
    fi
}

# Show latest logs
show_latest_logs() {
    local platform="$1"
    local logs_dir="logs"
    
    if [[ "$platform" == "all" ]]; then
        local latest=$(ls -t "$logs_dir"/*.log 2>/dev/null | head -1)
    else
        local latest=$(ls -t "$logs_dir"/build-${platform}-*.log 2>/dev/null | head -1)
    fi
    
    if [ -n "$latest" ]; then
        print_header "Latest Log: $(basename "$latest")"
        tail -50 "$latest"
    else
        print_info "No logs found"
    fi
}

# Monitor system resources
monitor_system() {
    local duration="${1:-60}"
    
    print_header "System Monitor (${duration}s)"
    print_info "Press Ctrl+C to stop"
    echo ""
    
    local start_time=$(date +%s)
    local end_time=$((start_time + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        local timestamp=$(date '+%H:%M:%S')
        
        # CPU usage
        local cpu_usage=""
        if command -v top >/dev/null 2>&1; then
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        fi
        
        # Memory usage
        local mem_usage=""
        if command -v free >/dev/null 2>&1; then
            mem_usage=$(free | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
        fi
        
        # Disk usage
        local disk_usage=$(df . | tail -1 | awk '{print $5}')
        
        printf "\r%s | CPU: %s | Memory: %s | Disk: %s" \
               "$timestamp" "${cpu_usage:-N/A}" "${mem_usage:-N/A}" "$disk_usage"
        
        sleep 2
    done
    
    echo ""
    print_info "Monitoring completed"
}

# System cleanup
cleanup_system() {
    local target="${1:-help}"
    
    case "$target" in
        "logs")
            cleanup_logs
            ;;
        "temp")
            cleanup_temp_files
            ;;
        "cache")
            cleanup_cache
            ;;
        "all")
            cleanup_logs
            cleanup_temp_files
            cleanup_cache
            ;;
        *)
            print_info "Cleanup options:"
            print_info "  pk utils cleanup logs    # Clean old log files"
            print_info "  pk utils cleanup temp    # Clean temporary files"
            print_info "  pk utils cleanup cache   # Clean build cache"
            print_info "  pk utils cleanup all     # Clean everything"
            ;;
    esac
}

# Cleanup logs
cleanup_logs() {
    local logs_dir="logs"
    
    if [ -d "$logs_dir" ]; then
        print_info "Cleaning old log files..."
        
        # Keep only logs from last 7 days
        find "$logs_dir" -name "*.log" -mtime +7 -delete
        
        print_success "Old log files cleaned"
    fi
}

# Cleanup temporary files
cleanup_temp_files() {
    print_info "Cleaning temporary files..."
    
    # Clean build temp directories but preserve the build structure
    for build_dir in build-*; do
        if [ -d "$build_dir/tmp" ]; then
            rm -rf "$build_dir/tmp/work" "$build_dir/tmp/stamps" 2>/dev/null || true
        fi
    done
    
    print_success "Temporary files cleaned"
}

# Cleanup cache
cleanup_cache() {
    print_info "Cleaning build cache..."
    
    # Clean sstate cache (keep structure)
    if [ -d "sstate-cache" ]; then
        find sstate-cache -name "*.tgz" -mtime +30 -delete 2>/dev/null || true
    fi
    
    print_success "Build cache cleaned"
}

# System benchmark
benchmark_system() {
    print_header "System Benchmark"
    echo ""
    
    # CPU benchmark
    print_subheader "CPU Test:"
    local cpu_start=$(date +%s)
    echo "scale=1000; 4*a(1)" | bc -l >/dev/null
    local cpu_end=$(date +%s)
    local cpu_time=$((cpu_end - cpu_start))
    print_info "CPU calculation time: ${cpu_time}s"
    
    # Disk I/O benchmark
    print_subheader "Disk I/O Test:"
    local test_file="/tmp/pk_benchmark_$$"
    
    # Write test
    local write_start=$(date +%s%3N)
    dd if=/dev/zero of="$test_file" bs=1M count=100 2>/dev/null
    local write_end=$(date +%s%3N)
    local write_time=$((write_end - write_start))
    
    # Read test
    local read_start=$(date +%s%3N)
    dd if="$test_file" of=/dev/null bs=1M 2>/dev/null
    local read_end=$(date +%s%3N)
    local read_time=$((read_end - read_start))
    
    rm -f "$test_file"
    
    print_info "Write speed: ~$((100000/write_time)) MB/s"
    print_info "Read speed: ~$((100000/read_time)) MB/s"
    
    # Build estimation
    print_subheader "Build Time Estimation:"
    print_info "Based on system performance:"
    print_info "  BeagleBone minimal: ~$(((cpu_time * 30 + 30)))min"
    print_info "  RPi4 minimal: ~$(((cpu_time * 45 + 45)))min"
    print_info "  Jetson Nano: ~$(((cpu_time * 60 + 60)))min"
    print_warning "Actual times may vary significantly"
}

# Run demo
run_demo() {
    local demo_type="${1:-logo}"
    
    case "$demo_type" in
        "logo")
            if [ -f "./scripts/pk-logo-demo.sh" ]; then
                ./scripts/pk-logo-demo.sh
            else
                print_error "Logo demo script not found"
            fi
            ;;
        "platform")
            if [ -f "./scripts/platform-version-manager.sh" ]; then
                ./scripts/platform-version-manager.sh
            else
                print_error "Platform version manager not found"
            fi
            ;;
        *)
            print_info "Available demos:"
            print_info "  pk utils demo logo       # PK logo demonstration"
            print_info "  pk utils demo platform   # Platform manager demo"
            ;;
    esac
}

# Show environment information
show_environment() {
    print_header "Environment Information"
    echo ""
    
    print_subheader "System:"
    print_info "OS: $(detect_environment)"
    print_info "Shell: $SHELL"
    print_info "User: $(whoami)"
    print_info "Working Directory: $(pwd)"
    
    print_subheader "Tools:"
    local tools=("git" "python3" "gcc" "make" "bitbake")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version=$(${tool} --version 2>/dev/null | head -1 || echo "Unknown")
            print_info "$tool: $version"
        else
            print_warning "$tool: Not found"
        fi
    done
    
    print_subheader "Git Repository:"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_info "Repository: $(basename "$(git rev-parse --show-toplevel)")"
        print_info "Branch: $(git branch --show-current)"
        print_info "Commit: $(git rev-parse --short HEAD)"
        print_info "Remote: $(git remote get-url origin 2>/dev/null || echo "None")"
    else
        print_warning "Not in a Git repository"
    fi
}

# Check disk usage
check_disk_usage() {
    print_header "Disk Usage Analysis"
    echo ""
    
    print_subheader "Overall Disk Usage:"
    df -h .
    echo ""
    
    print_subheader "Directory Sizes:"
    local dirs=("." "build-*" "downloads" "sstate-cache" "logs")
    
    for dir_pattern in "${dirs[@]}"; do
        if [ "$dir_pattern" = "." ]; then
            local size=$(du -sh . 2>/dev/null | cut -f1)
            print_info "Total project size: $size"
        elif [ "$dir_pattern" = "build-*" ]; then
            for build_dir in build-*; do
                if [ -d "$build_dir" ]; then
                    local size=$(du -sh "$build_dir" 2>/dev/null | cut -f1)
                    print_info "$build_dir: $size"
                fi
            done
        else
            if [ -d "$dir_pattern" ]; then
                local size=$(du -sh "$dir_pattern" 2>/dev/null | cut -f1)
                print_info "$dir_pattern: $size"
            fi
        fi
    done
    
    echo ""
    print_subheader "Cleanup Recommendations:"
    
    # Check if there are large temp directories
    for build_dir in build-*; do
        if [ -d "$build_dir/tmp" ]; then
            local temp_size=$(du -sh "$build_dir/tmp" 2>/dev/null | cut -f1)
            print_info "Can clean $build_dir/tmp ($temp_size): pk utils cleanup temp"
        fi
    done
    
    # Check old logs
    if [ -d "logs" ]; then
        local old_logs=$(find logs -name "*.log" -mtime +7 2>/dev/null | wc -l)
        if [ "$old_logs" -gt 0 ]; then
            print_info "Can clean $old_logs old log files: pk utils cleanup logs"
        fi
    fi
}

# Show utils usage
show_utils_usage() {
    cat << EOF
$(print_header "UTILS COMMAND USAGE")

SYNTAX:
    pk utils [COMMAND] [OPTIONS]

COMMANDS:
    doctor, check           System health check
    logs [PLATFORM] [TYPE]  View build and system logs
    monitor [SECONDS]       Monitor system resources
    cleanup [TARGET]        Clean up files and cache
    benchmark              Run system performance test
    demo [TYPE]            Run demonstration scripts
    env                    Show environment information
    disk                   Analyze disk usage

LOG TYPES:
    build                  Build logs (default)
    cli                    CLI command history
    error                  Error logs
    latest                 Most recent log

CLEANUP TARGETS:
    logs                   Old log files
    temp                   Temporary build files
    cache                  Build cache files
    all                    Everything above

EXAMPLES:
    pk utils doctor                    # Check system health
    pk utils logs beaglebone          # Show BeagleBone build logs
    pk utils monitor 120              # Monitor for 2 minutes
    pk utils cleanup all              # Clean everything
    pk utils benchmark                # Test system performance

EOF
}
