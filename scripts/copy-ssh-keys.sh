#!/bin/bash
# ----
# Script: copy-ssh-keys.sh
# Version: 1.0.0
# Description: Helper script to copy SSH keys to all servers using ssh-copy-id
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
LOGFILE="/var/log/${SCRIPT_NAME%.sh}.log"
DEBUG=${DEBUG:-0}
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519.pub}"
INVENTORY="${INVENTORY:-inventory.ini}"

# ============================================================================
# COLOR FUNCTIONS
# ============================================================================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
debug()   { [ "$DEBUG" = "1" ] && echo -e "${MAGENTA}[DEBUG]${RESET} $*"; }

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
step() {
    echo -e "\n${BOLD}${CYAN}🚀 $*${RESET}"
}

run_or_die() {
    debug "Running: $*"
    if ! "$@"; then
        error "Failed: $*"
        exit 1
    fi
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        debug "$1 not found"
        return 1
    fi
    return 0
}

# ============================================================================
# ERROR HANDLING
# ============================================================================
trap 'error "Script failed at line $LINENO: $BASH_COMMAND"' ERR

# ============================================================================
# MAIN SCRIPT
# ============================================================================
main() {
    step "SSH Key Copy Script"
    
    # Check prerequisites
    step "Checking prerequisites..."
    
    if [ ! -f "$SSH_KEY" ]; then
        error "SSH public key not found at: $SSH_KEY"
        error "Please generate a key with: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519"
        exit 1
    fi
    success "SSH key found: $SSH_KEY"
    
    if [ ! -f "$INVENTORY" ]; then
        error "Inventory file not found: $INVENTORY"
        exit 1
    fi
    success "Inventory file found: $INVENTORY"
    
    if ! check_command ssh-copy-id; then
        error "ssh-copy-id not found. Please install openssh-client"
        exit 1
    fi
    success "ssh-copy-id available"
    
    # Extract hosts from inventory
    step "Extracting hosts from inventory..."
    
    # Read ansible_user from inventory
    ANSIBLE_USER=$(grep -E "^ansible_user=" "$INVENTORY" | head -1 | cut -d'=' -f2 || echo "")
    if [ -z "$ANSIBLE_USER" ]; then
        warn "ansible_user not found in inventory, defaulting to current user"
        ANSIBLE_USER=$(whoami)
    fi
    info "Using SSH user: $ANSIBLE_USER"
    
    # Extract all host IPs from inventory
    HOSTS=$(grep -E "^[a-zA-Z0-9-]+.*ansible_host=" "$INVENTORY" | grep -v "^\[" | sed 's/.*ansible_host=\([0-9.]*\).*/\1/' || true)
    
    if [ -z "$HOSTS" ]; then
        error "No hosts found in inventory file"
        exit 1
    fi
    
    info "Found $(echo "$HOSTS" | wc -l) host(s) in inventory"
    
    # Copy keys to each host
    step "Copying SSH keys to hosts..."
    
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    
    while IFS= read -r host_ip; do
        if [ -z "$host_ip" ]; then
            continue
        fi
        
        info "Copying key to $ANSIBLE_USER@$host_ip..."
        
        if ssh-copy-id -i "$SSH_KEY" -o StrictHostKeyChecking=no "$ANSIBLE_USER@$host_ip" 2>/dev/null; then
            success "✓ Key copied to $host_ip"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            error "✗ Failed to copy key to $host_ip"
            warn "  You may need to manually run: ssh-copy-id -i $SSH_KEY $ANSIBLE_USER@$host_ip"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done <<< "$HOSTS"
    
    # Summary
    step "Summary"
    success "Successfully copied keys to $SUCCESS_COUNT host(s)"
    if [ $FAIL_COUNT -gt 0 ]; then
        warn "Failed to copy keys to $FAIL_COUNT host(s)"
        warn "You may need to manually copy keys or check network connectivity"
    fi
    
    if [ $SUCCESS_COUNT -gt 0 ]; then
        success "You can now use Ansible without passwords!"
        info "Test with: ansible all -i $INVENTORY -m ping"
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug|-d)
            DEBUG=1
            set -x
            ;;
        --key|-k)
            SSH_KEY="$2"
            shift
            ;;
        --inventory|-i)
            INVENTORY="$2"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--debug] [--key PATH] [--inventory PATH]"
            echo ""
            echo "Options:"
            echo "  --debug, -d          Enable debug mode"
            echo "  --key, -k PATH       Path to SSH public key (default: ~/.ssh/id_ed25519.pub)"
            echo "  --inventory, -i PATH Path to Ansible inventory (default: inventory.ini)"
            echo "  --help, -h           Show this help message"
            exit 0
            ;;
        *)
            warn "Unknown option: $1"
            ;;
    esac
    shift
done

# Setup logging
mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true
exec > >(tee -a "$LOGFILE" 2>/dev/null || cat) 2>&1

# Run main function
main "$@"

