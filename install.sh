#!/bin/bash
# dotclaude - Claude Code Configuration Installer
# Usage: ./install.sh [--link | --copy | --merge-claude-md]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo "dotclaude - Claude Code Configuration Installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --link           Create symlinks (recommended, keeps sync with repo)"
    echo "  --copy           Copy files (standalone installation)"
    echo "  --merge-claude-md  Append repo CLAUDE.md to existing one"
    echo "  --skills-only    Only install skills"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./install.sh --link              # Symlink all configs"
    echo "  ./install.sh --copy              # Copy all configs"
    echo "  ./install.sh --skills-only       # Only install skills"
    echo ""
}

backup_existing() {
    if [ -d "$CLAUDE_DIR" ]; then
        log_info "Backing up existing ~/.claude to $BACKUP_DIR"
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
        log_success "Backup created"
    fi
}

install_skills_link() {
    log_info "Installing skills (symlink mode)..."
    mkdir -p "$CLAUDE_DIR/skills"

    for skill in "$SCRIPT_DIR/skills"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            target="$CLAUDE_DIR/skills/$skill_name"

            if [ -L "$target" ]; then
                rm "$target"
            elif [ -d "$target" ]; then
                log_warn "Skipping $skill_name (directory exists, use --copy to overwrite)"
                continue
            fi

            ln -s "$skill" "$target"
            echo "  ✓ $skill_name"
        fi
    done

    log_success "Skills installed (symlinks)"
}

install_skills_copy() {
    log_info "Installing skills (copy mode)..."
    mkdir -p "$CLAUDE_DIR/skills"

    for skill in "$SCRIPT_DIR/skills"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            cp -r "$skill" "$CLAUDE_DIR/skills/"
            echo "  ✓ $skill_name"
        fi
    done

    log_success "Skills installed (copied)"
}

install_config() {
    local mode=$1
    log_info "Installing config files..."

    # settings.json
    if [ -f "$SCRIPT_DIR/settings.json" ]; then
        if [ "$mode" = "link" ]; then
            [ -f "$CLAUDE_DIR/settings.json" ] && mv "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
            ln -sf "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
        else
            cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/"
        fi
        echo "  ✓ settings.json"
    fi

    log_success "Config files installed"
}

install_claude_md() {
    local mode=$1
    log_info "Installing CLAUDE.md..."

    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        log_warn "CLAUDE.md already exists"
        echo "  Options:"
        echo "    1. Keep existing (skip)"
        echo "    2. Replace with repo version"
        echo "    3. Merge (append repo version)"
        read -p "  Choose [1/2/3]: " choice

        case $choice in
            2)
                if [ "$mode" = "link" ]; then
                    mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
                    ln -sf "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
                else
                    cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/"
                fi
                log_success "CLAUDE.md replaced"
                ;;
            3)
                echo "" >> "$CLAUDE_DIR/CLAUDE.md"
                echo "# ====== Merged from dotclaude ======" >> "$CLAUDE_DIR/CLAUDE.md"
                echo "" >> "$CLAUDE_DIR/CLAUDE.md"
                cat "$SCRIPT_DIR/CLAUDE.md" >> "$CLAUDE_DIR/CLAUDE.md"
                log_success "CLAUDE.md merged"
                ;;
            *)
                log_info "Keeping existing CLAUDE.md"
                ;;
        esac
    else
        if [ "$mode" = "link" ]; then
            ln -sf "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
        else
            cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/"
        fi
        log_success "CLAUDE.md installed"
    fi
}

main() {
    local mode="interactive"
    local skills_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --link)
                mode="link"
                shift
                ;;
            --copy)
                mode="copy"
                shift
                ;;
            --skills-only)
                skills_only=true
                shift
                ;;
            --merge-claude-md)
                if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
                    echo "" >> "$CLAUDE_DIR/CLAUDE.md"
                    echo "# ====== Merged from dotclaude ======" >> "$CLAUDE_DIR/CLAUDE.md"
                    cat "$SCRIPT_DIR/CLAUDE.md" >> "$CLAUDE_DIR/CLAUDE.md"
                    log_success "CLAUDE.md merged"
                fi
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo ""
    echo "========================================"
    echo "  dotclaude Installer"
    echo "========================================"
    echo ""

    # Interactive mode selection
    if [ "$mode" = "interactive" ]; then
        echo "Installation mode:"
        echo "  1. Symlink (recommended - stays in sync with repo)"
        echo "  2. Copy (standalone installation)"
        read -p "Choose [1/2]: " mode_choice

        case $mode_choice in
            1) mode="link" ;;
            2) mode="copy" ;;
            *) mode="link" ;;
        esac
    fi

    log_info "Mode: $mode"
    echo ""

    # Create ~/.claude if not exists
    mkdir -p "$CLAUDE_DIR"

    # Backup
    if [ "$skills_only" = false ]; then
        backup_existing
        echo ""
    fi

    # Install skills
    if [ "$mode" = "link" ]; then
        install_skills_link
    else
        install_skills_copy
    fi
    echo ""

    if [ "$skills_only" = false ]; then
        # Install config files
        install_config "$mode"
        echo ""

        # Install CLAUDE.md
        install_claude_md "$mode"
        echo ""
    fi

    echo "========================================"
    log_success "Installation complete!"
    echo "========================================"
    echo ""
    echo "Installed:"
    echo "  - Skills: $(ls "$CLAUDE_DIR/skills" 2>/dev/null | wc -l) skills"
    [ "$skills_only" = false ] && echo "  - Config: settings.json"
    [ "$skills_only" = false ] && echo "  - CLAUDE.md"
    echo ""
    echo "Next steps:"
    echo "  ./setup-mcp.sh   - Configure MCP servers (Notion, GitHub, etc.)"
    echo "  ./setup.sh       - Install skill dependencies (Python/Node.js)"
    echo ""
}

main "$@"
