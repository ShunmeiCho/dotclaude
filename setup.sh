#!/bin/bash
# Claude Code Skills - One-click Setup Script
# Usage: ./setup.sh [--all | --python | --node | --minimal]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check commands
check_command() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 found: $(command -v $1)"
        return 0
    else
        log_warn "$1 not found"
        return 1
    fi
}

# Initialize submodules
init_submodules() {
    log_info "Initializing git submodules..."
    git submodule update --init --recursive
    log_success "Submodules initialized"
}

# Install global Python dependencies for local skills
install_python_deps() {
    log_info "Installing global Python dependencies..."

    local deps="lxml pymupdf pypdf reportlab pillow openpyxl"

    if pip install $deps -q 2>/dev/null; then
        log_success "Python dependencies installed"
    else
        # Try pip3 if pip fails
        if pip3 install $deps -q 2>/dev/null; then
            log_success "Python dependencies installed (via pip3)"
        else
            log_warn "Failed to install some Python dependencies"
            log_info "Try manually: pip install $deps"
        fi
    fi
}

# Setup Python skill with venv
setup_python_skill() {
    local skill_dir="$1"
    local skill_name="$(basename $skill_dir)"

    if [ ! -f "$skill_dir/requirements.txt" ]; then
        return 0
    fi

    log_info "Setting up Python skill: $skill_name"

    cd "$skill_dir"

    # Create venv if not exists
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
    fi

    # Activate and install
    source .venv/bin/activate
    pip install --upgrade pip -q
    pip install -r requirements.txt -q

    # Special handling for notebooklm (needs browser)
    if [ "$skill_name" = "notebooklm-skill" ]; then
        log_info "Installing Chrome for NotebookLM..."
        patchright install chrome 2>/dev/null || log_warn "Chrome installation failed (may need display)"
    fi

    deactivate
    cd "$SCRIPT_DIR"

    log_success "$skill_name setup complete"
}

# Setup Node.js skill
setup_node_skill() {
    local skill_dir="$1"
    local skill_name="$(basename $skill_dir)"

    if [ ! -f "$skill_dir/package.json" ]; then
        return 0
    fi

    log_info "Setting up Node.js skill: $skill_name"

    cd "$skill_dir"

    npm install --silent

    # Special handling for playwright
    if [ "$skill_name" = "playwright-skill" ]; then
        log_info "Installing Chromium for Playwright..."
        npx playwright install chromium 2>/dev/null || log_warn "Chromium installation may have issues"
    fi

    # Build if needed (n8n-skills)
    if grep -q '"build"' package.json 2>/dev/null; then
        npm run build --silent 2>/dev/null || true
    fi

    cd "$SCRIPT_DIR"

    log_success "$skill_name setup complete"
}

# Main setup
main() {
    local mode="${1:-all}"

    echo ""
    echo "========================================"
    echo "  Claude Code Skills Setup"
    echo "========================================"
    echo ""

    # Check prerequisites
    log_info "Checking prerequisites..."
    check_command git

    local has_python=false
    local has_node=false

    if check_command python3; then has_python=true; fi
    if check_command node; then has_node=true; fi
    if check_command npm; then :; else has_node=false; fi

    echo ""

    # Initialize submodules
    init_submodules
    echo ""

    # Setup based on mode
    case "$mode" in
        --minimal)
            log_info "Minimal setup - submodules only"
            ;;
        --python)
            if [ "$has_python" = true ]; then
                log_info "Setting up Python skills..."
                install_python_deps
                setup_python_skill "$SCRIPT_DIR/notebooklm-skill"
            else
                log_error "Python not found, skipping Python skills"
            fi
            ;;
        --node)
            if [ "$has_node" = true ]; then
                log_info "Setting up Node.js skills..."
                setup_node_skill "$SCRIPT_DIR/playwright-skill"
                setup_node_skill "$SCRIPT_DIR/n8n-skills"
            else
                log_error "Node.js not found, skipping Node skills"
            fi
            ;;
        --all|*)
            if [ "$has_python" = true ]; then
                log_info "Setting up Python skills..."
                install_python_deps
                setup_python_skill "$SCRIPT_DIR/notebooklm-skill"
                echo ""
            fi

            if [ "$has_node" = true ]; then
                log_info "Setting up Node.js skills..."
                setup_node_skill "$SCRIPT_DIR/playwright-skill"
                setup_node_skill "$SCRIPT_DIR/n8n-skills"
                echo ""
            fi
            ;;
    esac

    echo ""
    echo "========================================"
    log_success "Setup complete!"
    echo "========================================"
    echo ""
    echo "Skills are ready to use with Claude Code."
    echo ""
    echo "To update submodules in the future:"
    echo "  git submodule update --remote --merge"
    echo ""
}

main "$@"
