#!/bin/bash

# CLI Configuration Functions
# Configuration management functionality for the PK Platform CLI

# Main config command handler
cli_config_command() {
    local subcommand="${1:-help}"
    
    case "$subcommand" in
        "show"|"display"|"list")
            shift
            show_configuration "$@"
            ;;
        "edit")
            shift
            edit_configuration "$@"
            ;;
        "update")
            shift
            update_configuration "$@"
            ;;
        "validate")
            shift
            validate_configuration "$@"
            ;;
        "backup")
            shift
            backup_configuration "$@"
            ;;
        "restore")
            shift
            restore_configuration "$@"
            ;;
        "auto")
            shift
            auto_configure "$@"
            ;;
        "help"|"-h"|"--help"|*)
            show_config_usage
            ;;
    esac
}

# Show current configuration
show_configuration() {
    local platform="${1:-all}"
    
    print_header "Configuration Status"
    echo ""
    
    if [[ "$platform" == "all" ]]; then
        show_all_configurations
    else
        if ! validate_platform "$platform"; then
            print_error "Invalid platform: $platform"
            return 1
        fi
        show_platform_configuration "$platform"
    fi
}

# Show all platform configurations
show_all_configurations() {
    for platform in beaglebone raspberrypi4 jetson-nano; do
        print_subheader "$platform Configuration:"
        
        local build_dir="build-$platform"
        if [ -d "$build_dir" ]; then
            echo -e "  Status: ${CLI_GREEN}✓ Configured${CLI_NC}"
            echo "  Build directory: $build_dir"
            
            # Check config files
            if [ -f "$build_dir/conf/local.conf" ]; then
                local machine=$(grep "^MACHINE" "$build_dir/conf/local.conf" | cut -d'"' -f2 2>/dev/null)
                echo "  Machine: ${machine:-Not specified}"
            fi
            
            if [ -f "$build_dir/conf/bblayers.conf" ]; then
                local layer_count=$(grep -c "meta-" "$build_dir/conf/bblayers.conf" 2>/dev/null || echo "0")
                echo "  Layers: $layer_count configured"
            fi
            
            # Check template source
            if [ -d "conf-templates/$platform" ]; then
                echo "  Template: conf-templates/$platform"
            fi
        else
            echo -e "  Status: ${CLI_YELLOW}Not configured${CLI_NC}"
            print_info "    Run: pk setup $platform"
        fi
        echo ""
    done
}

# Show specific platform configuration
show_platform_configuration() {
    local platform="$1"
    local build_dir="build-$platform"
    
    print_subheader "$platform Configuration Details:"
    echo ""
    
    if [ ! -d "$build_dir" ]; then
        print_error "Platform not configured: $platform"
        print_info "Run: pk setup $platform"
        return 1
    fi
    
    # Show local.conf highlights
    if [ -f "$build_dir/conf/local.conf" ]; then
        print_info "Local Configuration (local.conf):"
        echo ""
        
        # Extract key configuration values
        grep -E "^MACHINE|^DISTRO|^IMAGE_INSTALL|^DISTRO_FEATURES" "$build_dir/conf/local.conf" | \
        while IFS= read -r line; do
            echo "  $line"
        done
        echo ""
    fi
    
    # Show bblayers.conf
    if [ -f "$build_dir/conf/bblayers.conf" ]; then
        print_info "Layer Configuration (bblayers.conf):"
        echo ""
        
        # Extract layer paths
        grep "meta-" "$build_dir/conf/bblayers.conf" | \
        sed 's/.*\(meta-[^/]*\).*/  \1/' | \
        sort | uniq
        echo ""
    fi
    
    # Show disk usage
    if [ -d "$build_dir" ]; then
        local size=$(du -sh "$build_dir" 2>/dev/null | cut -f1)
        print_info "Build directory size: $size"
    fi
}

# Edit configuration
edit_configuration() {
    local platform="${1:-help}"
    local config_type="${2:-local}"
    
    if [[ "$platform" == "help" || -z "$platform" ]]; then
        print_info "Usage: pk config edit [PLATFORM] [local|layers|template]"
        return
    fi
    
    if ! validate_platform "$platform"; then
        print_error "Invalid platform: $platform"
        return 1
    fi
    
    local build_dir="build-$platform"
    if [ ! -d "$build_dir" ]; then
        print_error "Platform not configured: $platform"
        print_info "Run: pk setup $platform first"
        return 1
    fi
    
    case "$config_type" in
        "local")
            edit_local_conf "$platform"
            ;;
        "layers")
            edit_layers_conf "$platform" 
            ;;
        "template")
            edit_template_conf "$platform"
            ;;
        *)
            print_error "Invalid config type: $config_type"
            print_info "Valid types: local, layers, template"
            return 1
            ;;
    esac
}

# Edit local.conf
edit_local_conf() {
    local platform="$1"
    local conf_file="build-$platform/conf/local.conf"
    
    print_info "Editing local.conf for $platform"
    
    if command -v ${EDITOR:-nano} >/dev/null 2>&1; then
        ${EDITOR:-nano} "$conf_file"
    else
        print_error "No editor found. Please set EDITOR environment variable"
        return 1
    fi
}

# Edit bblayers.conf
edit_layers_conf() {
    local platform="$1"
    local conf_file="build-$platform/conf/bblayers.conf"
    
    print_info "Editing bblayers.conf for $platform"
    
    if command -v ${EDITOR:-nano} >/dev/null 2>&1; then
        ${EDITOR:-nano} "$conf_file"
    else
        print_error "No editor found. Please set EDITOR environment variable"
        return 1
    fi
}

# Edit template configuration
edit_template_conf() {
    local platform="$1"
    local template_dir="conf-templates/$platform"
    
    if [ ! -d "$template_dir" ]; then
        print_error "No template directory for $platform"
        return 1
    fi
    
    print_info "Available template files for $platform:"
    ls -la "$template_dir/"
    
    read -p "Which file to edit? " filename
    local template_file="$template_dir/$filename"
    
    if [ -f "$template_file" ]; then
        if command -v ${EDITOR:-nano} >/dev/null 2>&1; then
            ${EDITOR:-nano} "$template_file"
        else
            print_error "No editor found. Please set EDITOR environment variable"
        fi
    else
        print_error "File not found: $template_file"
    fi
}

# Update configuration
update_configuration() {
    local platform="${1:-help}"
    
    if [[ "$platform" == "help" || -z "$platform" ]]; then
        print_info "Usage: pk config update [PLATFORM]"
        return
    fi
    
    if ! validate_platform "$platform"; then
        print_error "Invalid platform: $platform"
        return 1
    fi
    
    print_info "Updating configuration for $platform"
    
    # Re-copy templates if they exist
    local template_dir="conf-templates/$platform"
    local build_dir="build-$platform"
    
    if [ -d "$template_dir" ] && [ -d "$build_dir" ]; then
        print_warning "This will overwrite existing configuration"
        read -p "Continue? (y/N) " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$template_dir"/* "$build_dir/conf/" 2>/dev/null || true
            print_success "Configuration updated from templates"
        else
            print_info "Update cancelled"
        fi
    else
        print_error "Template or build directory not found"
    fi
}

# Validate configuration
validate_configuration() {
    local platform="${1:-all}"
    
    print_header "Configuration Validation"
    echo ""
    
    if [[ "$platform" == "all" ]]; then
        validate_all_configurations
    else
        if ! validate_platform "$platform"; then
            print_error "Invalid platform: $platform"
            return 1
        fi
        validate_platform_configuration "$platform"
    fi
}

# Validate all configurations
validate_all_configurations() {
    local has_errors=false
    
    for platform in beaglebone raspberrypi4 jetson-nano; do
        print_subheader "Validating $platform:"
        
        if ! validate_platform_configuration "$platform"; then
            has_errors=true
        fi
        echo ""
    done
    
    if [ "$has_errors" = false ]; then
        print_success "All configurations are valid"
    else
        print_warning "Some configurations have issues"
    fi
}

# Validate specific platform configuration
validate_platform_configuration() {
    local platform="$1"
    local build_dir="build-$platform"
    local valid=true
    
    # Check if build directory exists
    if [ ! -d "$build_dir" ]; then
        print_error "  Build directory not found: $build_dir"
        return 1
    fi
    
    # Check local.conf
    if [ -f "$build_dir/conf/local.conf" ]; then
        print_success "  local.conf exists"
        
        # Check for required variables
        if grep -q "^MACHINE" "$build_dir/conf/local.conf"; then
            print_success "  MACHINE variable set"
        else
            print_error "  MACHINE variable missing"
            valid=false
        fi
        
        if grep -q "^DISTRO" "$build_dir/conf/local.conf"; then
            print_success "  DISTRO variable set"
        else
            print_warning "  DISTRO variable not explicitly set (using default)"
        fi
    else
        print_error "  local.conf missing"
        valid=false
    fi
    
    # Check bblayers.conf
    if [ -f "$build_dir/conf/bblayers.conf" ]; then
        print_success "  bblayers.conf exists"
        
        # Check for required layers
        if grep -q "meta-openembedded/meta-oe" "$build_dir/conf/bblayers.conf"; then
            print_success "  meta-oe layer included"
        else
            print_warning "  meta-oe layer not found"
        fi
    else
        print_error "  bblayers.conf missing"
        valid=false
    fi
    
    return $([ "$valid" = true ] && echo 0 || echo 1)
}

# Backup configuration
backup_configuration() {
    local platform="${1:-all}"
    local backup_dir="config-backups/$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$backup_dir"
    
    print_info "Backing up configuration to: $backup_dir"
    
    if [[ "$platform" == "all" ]]; then
        for p in beaglebone raspberrypi4 jetson-nano; do
            backup_platform_config "$p" "$backup_dir"
        done
    else
        if ! validate_platform "$platform"; then
            print_error "Invalid platform: $platform"
            return 1
        fi
        backup_platform_config "$platform" "$backup_dir"
    fi
    
    print_success "Backup completed: $backup_dir"
}

# Backup specific platform config
backup_platform_config() {
    local platform="$1"
    local backup_dir="$2"
    local build_dir="build-$platform"
    
    if [ -d "$build_dir/conf" ]; then
        mkdir -p "$backup_dir/$platform"
        cp -r "$build_dir/conf"/* "$backup_dir/$platform/"
        print_info "  Backed up $platform configuration"
    fi
}

# Auto configure
auto_configure() {
    local platform="${1:-help}"
    
    if [[ "$platform" == "help" || -z "$platform" ]]; then
        print_info "Usage: pk config auto [PLATFORM]"
        print_info "This applies optimized settings for the platform"
        return
    fi
    
    if ! validate_platform "$platform"; then
        print_error "Invalid platform: $platform"
        return 1
    fi
    
    print_info "Auto-configuring $platform with optimized settings"
    print_warning "This feature is planned for future release"
    print_info "For now, use the existing templates"
}

# Show config usage
show_config_usage() {
    cat << EOF
$(print_header "CONFIG COMMAND USAGE")

SYNTAX:
    pk config [COMMAND] [OPTIONS]

COMMANDS:
    show [PLATFORM]       Show current configuration
    edit [PLATFORM] [TYPE] Edit configuration files
    update [PLATFORM]     Update from templates
    validate [PLATFORM]   Validate configuration
    backup [PLATFORM]     Backup configuration
    restore [PLATFORM]    Restore configuration
    auto [PLATFORM]       Auto-configure platform

EDIT TYPES:
    local                 Edit local.conf
    layers                Edit bblayers.conf
    template              Edit template files

EXAMPLES:
    pk config show                    # Show all configurations
    pk config show beaglebone        # Show specific platform
    pk config edit beaglebone local  # Edit local.conf
    pk config validate all           # Validate all platforms
    pk config backup all             # Backup all configs

CONFIGURATION FILES:
    local.conf            Main build configuration
    bblayers.conf         Layer configuration
    Templates: conf-templates/[platform]/

EOF
}