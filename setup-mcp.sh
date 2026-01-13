#!/bin/bash
# setup-mcp.sh - MCP 服务器一键部署
# Usage: ./setup-mcp.sh [--minimal | --full]

set -e

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

# Check if claude CLI is available
check_claude_cli() {
    if ! command -v claude &> /dev/null; then
        log_error "Claude CLI not found. Please install Claude Code first."
        echo "  Visit: https://claude.ai/code"
        exit 1
    fi
    log_success "Claude CLI found"
}

# Add MCP server with error handling
add_mcp_server() {
    local name="$1"
    shift

    log_info "Adding MCP server: $name"
    if claude mcp add --scope user "$@" 2>/dev/null; then
        log_success "$name added"
    else
        log_warn "$name may already exist or failed to add"
    fi
}

# Core servers (no API key required)
install_core_servers() {
    log_info "Installing core MCP servers..."
    echo ""

    # HTTP remote servers
    add_mcp_server "notion" --transport http notion https://mcp.notion.com/mcp
    add_mcp_server "github" --transport http github https://api.githubcopilot.com/mcp/

    # Stdio local servers
    add_mcp_server "playwright" playwright -- npx -y @anthropic/mcp-puppeteer
    add_mcp_server "chrome-devtools" chrome-devtools -- npx chrome-devtools-mcp@latest
}

# Optional servers (require API keys)
install_optional_servers() {
    log_info "Installing optional MCP servers..."
    echo ""

    # Context7
    if [ -n "$CONTEXT7_API_KEY" ]; then
        add_mcp_server "context7" --env CONTEXT7_API_KEY="$CONTEXT7_API_KEY" context7 \
            -- npx -y @upstash/context7-mcp
    else
        log_warn "Skipping context7 (CONTEXT7_API_KEY not set)"
    fi

    # Perplexity
    if [ -n "$PERPLEXITY_API_KEY" ]; then
        add_mcp_server "perplexity" --env PERPLEXITY_API_KEY="$PERPLEXITY_API_KEY" perplexity \
            -- npx -y @perplexity-ai/mcp-server
    else
        log_warn "Skipping perplexity (PERPLEXITY_API_KEY not set)"
    fi
}

# Show current MCP servers
show_status() {
    echo ""
    log_info "Current MCP servers:"
    claude mcp list 2>/dev/null || log_warn "Could not list MCP servers"
}

# Main
main() {
    local mode="${1:-full}"

    echo ""
    echo "========================================"
    echo "  MCP Server Setup"
    echo "========================================"
    echo ""

    check_claude_cli
    echo ""

    case "$mode" in
        --minimal)
            install_core_servers
            ;;
        --full|*)
            install_core_servers
            echo ""
            install_optional_servers
            ;;
    esac

    show_status

    echo ""
    echo "========================================"
    log_success "MCP setup complete!"
    echo "========================================"
    echo ""
    echo "To add more servers manually:"
    echo "  claude mcp add <name> -- <command>"
    echo ""
    echo "To set API keys for optional servers:"
    echo "  export CONTEXT7_API_KEY=your-key"
    echo "  export PERPLEXITY_API_KEY=your-key"
    echo "  ./setup-mcp.sh"
    echo ""
}

main "$@"
