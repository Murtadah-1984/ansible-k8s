#!/bin/bash
# ----
# Script: verify-node-uniqueness.sh
# Version: 1.0.0
# Description: Verify and ensure node has a unique machine ID
# ----

# ============================================================================
# STRICT MODE & SAFETY
# ============================================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# GLOBAL CONFIGURATION
# ============================================================================
SCRIPT_NAME=$(basename "$0")
MACHINE_ID_FILE="/etc/machine-id"
DBUS_MACHINE_ID_FILE="/var/lib/dbus/machine-id"

# ============================================================================
# COLOR FUNCTIONS
# ============================================================================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
generate_machine_id() {
    # Generate a new machine ID using uuidgen
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | head -c 32
    else
        # Fallback: use /dev/urandom
        cat /dev/urandom | tr -dc 'a-f0-9' | head -c 32
    fi
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================
main() {
    local machine_id=""
    local needs_fix=false
    
    # Check /etc/machine-id
    if [ -f "$MACHINE_ID_FILE" ]; then
        machine_id=$(cat "$MACHINE_ID_FILE" | tr -d '\n' | tr '[:upper:]' '[:lower:]')
        
        # Check if machine-id is empty or invalid (should be 32 hex characters)
        if [ -z "$machine_id" ] || [ ${#machine_id} -ne 32 ] || ! echo "$machine_id" | grep -qE '^[a-f0-9]{32}$'; then
            warn "Invalid machine-id found in $MACHINE_ID_FILE"
            needs_fix=true
        else
            info "Valid machine-id found: ${machine_id:0:8}..."
        fi
    else
        warn "Machine-id file not found: $MACHINE_ID_FILE"
        needs_fix=true
    fi
    
    # Check /var/lib/dbus/machine-id (should match)
    if [ -f "$DBUS_MACHINE_ID_FILE" ]; then
        local dbus_id=$(cat "$DBUS_MACHINE_ID_FILE" | tr -d '\n' | tr '[:upper:]' '[:lower:]')
        if [ "$machine_id" != "$dbus_id" ]; then
            warn "Machine-id mismatch between $MACHINE_ID_FILE and $DBUS_MACHINE_ID_FILE"
            needs_fix=true
        fi
    fi
    
    # Fix if needed
    if [ "$needs_fix" = true ]; then
        info "Generating new machine-id..."
        local new_id=$(generate_machine_id)
        
        # Ensure directory exists
        mkdir -p "$(dirname "$MACHINE_ID_FILE")"
        mkdir -p "$(dirname "$DBUS_MACHINE_ID_FILE")"
        
        # Write to /etc/machine-id
        echo -n "$new_id" > "$MACHINE_ID_FILE"
        chmod 0444 "$MACHINE_ID_FILE"
        success "Generated new machine-id: ${new_id:0:8}..."
        
        # Write to /var/lib/dbus/machine-id
        echo -n "$new_id" > "$DBUS_MACHINE_ID_FILE"
        chmod 0444 "$DBUS_MACHINE_ID_FILE"
        success "Updated dbus machine-id"
        
        machine_id="$new_id"
    fi
    
    # Display final machine-id
    info "Node machine-id: ${machine_id:0:8}..."
    success "Node uniqueness verified"
    
    return 0
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Only run if executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

