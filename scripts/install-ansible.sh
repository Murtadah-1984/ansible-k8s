#!/bin/bash
# -------------------------------------------------------------------
# Script: install-ansible.sh
# Version: 1.0.0
# Description: Install Ansible automation tool using best practices
# -------------------------------------------------------------------

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
ANSIBLE_VERSION="${ANSIBLE_VERSION:-latest}"
USE_VENV="${USE_VENV:-0}"
VENV_PATH="${VENV_PATH:-/opt/ansible-venv}"

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

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION_ID="${VERSION_ID:-unknown}"
        debug "Detected OS: $OS_ID $OS_VERSION_ID"
    else
        error "Cannot detect OS: /etc/os-release not found"
        exit 1
    fi
}

install_python_dependencies() {
    step "Installing Python and pip dependencies"
    
    case "$OS_ID" in
        ubuntu|debian)
            info "Installing dependencies for Ubuntu/Debian"
            run_or_die apt-get update
            run_or_die apt-get install -y \
                python3 \
                python3-pip \
                python3-venv \
                python3-dev \
                build-essential \
                libssl-dev \
                libffi-dev \
                git
            ;;
        rhel|centos|fedora|rocky|almalinux)
            info "Installing dependencies for RHEL/CentOS/Fedora"
            if check_command dnf; then
                run_or_die dnf install -y \
                    python3 \
                    python3-pip \
                    python3-devel \
                    gcc \
                    openssl-devel \
                    libffi-devel \
                    git
            else
                run_or_die yum install -y \
                    python3 \
                    python3-pip \
                    python3-devel \
                    gcc \
                    openssl-devel \
                    libffi-devel \
                    git
            fi
            ;;
        *)
            error "Unsupported OS: $OS_ID"
            error "Please install Python3 and pip manually"
            exit 1
            ;;
    esac
    
    success "Python dependencies installed"
}

upgrade_pip() {
    step "Upgrading pip to latest version"
    
    if [ "$USE_VENV" = "1" ]; then
        run_or_die "$VENV_PATH/bin/pip3" install --upgrade pip setuptools wheel
    else
        run_or_die pip3 install --upgrade pip setuptools wheel --user
    fi
    
    success "pip upgraded"
}

create_venv() {
    if [ "$USE_VENV" = "1" ]; then
        step "Creating Python virtual environment"
        
        if [ -d "$VENV_PATH" ]; then
            warn "Virtual environment already exists at $VENV_PATH"
            read -p "Remove existing venv? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                run_or_die rm -rf "$VENV_PATH"
            else
                info "Using existing virtual environment"
                return 0
            fi
        fi
        
        run_or_die python3 -m venv "$VENV_PATH"
        success "Virtual environment created at $VENV_PATH"
    fi
}

install_ansible() {
    step "Installing Ansible"
    
    local pip_cmd
    if [ "$USE_VENV" = "1" ]; then
        pip_cmd="$VENV_PATH/bin/pip3"
        info "Installing Ansible in virtual environment: $VENV_PATH"
    else
        pip_cmd="pip3"
        info "Installing Ansible for current user"
    fi
    
    if [ "$ANSIBLE_VERSION" = "latest" ]; then
        info "Installing latest Ansible version"
        run_or_die "$pip_cmd" install ansible
    else
        info "Installing Ansible version: $ANSIBLE_VERSION"
        run_or_die "$pip_cmd" install "ansible==${ANSIBLE_VERSION}"
    fi
    
    success "Ansible installed"
}

verify_installation() {
    step "Verifying Ansible installation"
    
    local ansible_cmd
    if [ "$USE_VENV" = "1" ]; then
        ansible_cmd="$VENV_PATH/bin/ansible"
    else
        ansible_cmd="ansible"
    fi
    
    if check_command "$ansible_cmd"; then
        local version
        version=$("$ansible_cmd" --version | head -n 1)
        success "Ansible installation verified"
        info "Installed version: $version"
        
        # Test ansible configuration
        if "$ansible_cmd" --version >/dev/null 2>&1; then
            success "Ansible is working correctly"
        else
            warn "Ansible installed but may have configuration issues"
        fi
    else
        error "Ansible command not found in PATH"
        if [ "$USE_VENV" = "1" ]; then
            warn "Virtual environment path: $VENV_PATH/bin"
            warn "Activate with: source $VENV_PATH/bin/activate"
        else
            warn "Ensure ~/.local/bin is in your PATH"
        fi
        exit 1
    fi
}

setup_path() {
    if [ "$USE_VENV" = "0" ]; then
        step "Setting up PATH for user installation"
        
        local user_bin="$HOME/.local/bin"
        local bashrc="$HOME/.bashrc"
        
        if [ -d "$user_bin" ] && ! grep -q "$user_bin" "$bashrc" 2>/dev/null; then
            info "Adding ~/.local/bin to PATH in $bashrc"
            echo "" >> "$bashrc"
            echo "# Add local bin to PATH for Ansible" >> "$bashrc"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$bashrc"
            success "PATH updated in $bashrc"
            warn "Run 'source ~/.bashrc' or log out and back in to use Ansible"
        elif [ -d "$user_bin" ]; then
            info "~/.local/bin already in PATH"
        fi
    fi
}

clone_project_repo() {
    step "Cloning ansible-k8s project repository"
    
    # Check if git is installed
    if ! check_command git; then
        warn "git is not installed - skipping repository clone"
        warn "Please install git manually to clone the repository"
        return 0
    fi
    
    local repo_url="https://github.com/Murtadah-1984/ansible-k8s"
    local ansible_dir="$HOME/ansible"
    local temp_clone
    temp_clone=$(mktemp -d)
    
    # Create ~/ansible directory
    if [ -d "$ansible_dir" ]; then
        warn "Directory $ansible_dir already exists"
        read -p "Remove existing directory and clone fresh? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Removing existing directory: $ansible_dir"
            run_or_die rm -rf "$ansible_dir"
        else
            info "Keeping existing directory - skipping clone"
            return 0
        fi
    fi
    
    # Clone repository to temporary location
    info "Cloning repository from $repo_url"
    debug "Temporary clone location: $temp_clone"
    run_or_die git clone "$repo_url" "$temp_clone/ansible-k8s"
    
    # Create ~/ansible directory
    info "Creating directory: $ansible_dir"
    run_or_die mkdir -p "$ansible_dir"
    
    # Copy cloned repository contents to ~/ansible
    info "Copying repository contents to $ansible_dir"
    run_or_die cp -r "$temp_clone/ansible-k8s"/* "$ansible_dir/"
    run_or_die cp -r "$temp_clone/ansible-k8s"/.git "$ansible_dir/" 2>/dev/null || true
    
    # Clean up temporary clone
    info "Cleaning up temporary files"
    run_or_die rm -rf "$temp_clone"
    
    success "Project repository cloned to $ansible_dir"
    info "Project location: $ansible_dir"
}

# ============================================================================
# ERROR HANDLING
# ============================================================================
trap 'error "Script failed at line $LINENO: $BASH_COMMAND"' ERR

# ============================================================================
# MAIN SCRIPT
# ============================================================================
main() {
    step "Installing Ansible automation tool"
    
    # Setup logging
    mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true
    
    # Check if running as root (required for package installation)
    if [ "$EUID" -ne 0 ] && [ "$USE_VENV" = "0" ]; then
        warn "Not running as root - will install Ansible for current user only"
        warn "Some dependencies may need to be installed manually"
    fi
    
    # Detect OS
    step "Detecting operating system"
    detect_os
    success "OS detected: $OS_ID $OS_VERSION_ID"
    
    # Check if Ansible is already installed
    local ansible_check_cmd="ansible"
    if [ "$USE_VENV" = "1" ] && [ -f "$VENV_PATH/bin/ansible" ]; then
        ansible_check_cmd="$VENV_PATH/bin/ansible"
    fi
    
    if check_command "$ansible_check_cmd"; then
        local current_version
        current_version=$("$ansible_check_cmd" --version | head -n 1)
        warn "Ansible is already installed: $current_version"
        read -p "Continue with installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Install Python dependencies (requires root)
    if [ "$EUID" -eq 0 ]; then
        install_python_dependencies
    else
        warn "Skipping system package installation (not running as root)"
        info "Please ensure Python3 and pip are installed"
        
        if ! check_command python3; then
            error "python3 is required but not found"
            error "Please install Python3 manually or run this script as root"
            exit 1
        fi
        
        if ! check_command pip3; then
            error "pip3 is required but not found"
            error "Please install pip3 manually or run this script as root"
            exit 1
        fi
    fi
    
    # Create virtual environment if requested
    if [ "$USE_VENV" = "1" ]; then
        create_venv
    fi
    
    # Upgrade pip
    upgrade_pip
    
    # Install Ansible
    install_ansible
    
    # Verify installation
    verify_installation
    
    # Setup PATH if needed
    if [ "$USE_VENV" = "0" ]; then
        setup_path
    fi
    
    # Clone project repository
    clone_project_repo
    
    # Final instructions
    step "Installation Summary"
    if [ "$USE_VENV" = "1" ]; then
        success "Ansible installed in virtual environment: $VENV_PATH"
        info "To use Ansible, activate the virtual environment:"
        info "  source $VENV_PATH/bin/activate"
    else
        success "Ansible installed for current user"
        if [ "$EUID" -ne 0 ]; then
            info "Ensure ~/.local/bin is in your PATH"
            info "Run: source ~/.bashrc (or log out and back in)"
        fi
    fi
    
    info "Project repository available at: ~/ansible"
    info "Navigate to the project: cd ~/ansible"
    
    success "Ansible installation completed successfully! 🎉"
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
        --version|-v)
            ANSIBLE_VERSION="$2"
            shift
            ;;
        --venv)
            USE_VENV=1
            ;;
        --venv-path)
            VENV_PATH="$2"
            USE_VENV=1
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --debug, -d              Enable debug mode"
            echo "  --version VERSION, -v     Install specific Ansible version (default: latest)"
            echo "  --venv                    Install in Python virtual environment"
            echo "  --venv-path PATH         Virtual environment path (default: /opt/ansible-venv)"
            echo "  --help, -h                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                       # Install latest Ansible for current user"
            echo "  $0 --venv                # Install in virtual environment"
            echo "  $0 --version 9.0.0       # Install specific version"
            echo "  sudo $0                  # Install system-wide (requires root)"
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

