#!/usr/bin/env bash
# Public installer for teraforge-kb private KB.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/huypqapero/teraforge-kb-installer/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/huypqapero/teraforge-kb-installer/main/install.sh | bash -s -- --with-hooks
#
# Env vars (optional):
#   TFKB_REPO     Private repo (default: huypqapero/teraforge-kb)
#   TFKB_DIR      Install path (default: $HOME/.tfkb)
#   TFKB_REF      Git ref      (default: main)
#   TFKB_BIN      Bin dir      (default: $HOME/.local/bin)
#
# Prerequisite: git, curl, gh (GitHub CLI).
# Installs: uv (static binary) + Python 3.11 managed + MCP tools + Claude skill.

set -euo pipefail

readonly PRIVATE_REPO="${TFKB_REPO:-huypqapero/teraforge-kb}"
readonly INSTALL_DIR="${TFKB_DIR:-$HOME/.tfkb}"
readonly BIN_DIR="${TFKB_BIN:-$HOME/.local/bin}"
readonly REF="${TFKB_REF:-main}"

readonly C_G='\033[0;32m'
readonly C_Y='\033[1;33m'
readonly C_R='\033[0;31m'
readonly C_B='\033[0;34m'
readonly C_X='\033[0m'

log()     { printf "${C_B}▶${C_X} %s\n" "$*"; }
success() { printf "${C_G}✓${C_X} %s\n" "$*"; }
warn()    { printf "${C_Y}!${C_X} %s\n" "$*"; }
die()     { printf "${C_R}✗${C_X} %s\n" "$*" >&2; exit 1; }

check_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

check_gh_auth() {
    check_cmd gh
    if ! gh auth status >/dev/null 2>&1; then
        warn "GitHub CLI not authenticated. Launching: gh auth login"
        gh auth login
    fi
    gh auth setup-git
    success "GitHub CLI authenticated"
}

install_uv_if_missing() {
    if command -v uv >/dev/null 2>&1; then
        success "uv already installed ($(uv --version))"
        return
    fi
    log "Installing uv (static binary, ~10MB)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    [[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env" 2>/dev/null || true
    command -v uv >/dev/null 2>&1 || die "uv install succeeded but command not found. Reopen terminal."
    success "uv installed"
}

install_python_managed() {
    log "Checking Python 3.11 (managed by uv)..."
    if uv python list 2>/dev/null | grep -q "cpython-3.11"; then
        success "Python 3.11 already present"
        return
    fi
    log "Downloading Python 3.11 standalone (~15MB)..."
    uv python install 3.11
    success "Python 3.11 installed (isolated, system Python not touched)"
}

clone_or_update_repo() {
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        log "Updating existing install at $INSTALL_DIR..."
        git -C "$INSTALL_DIR" fetch origin "$REF"
        git -C "$INSTALL_DIR" reset --hard "FETCH_HEAD"
        success "Updated to origin/$REF"
    else
        log "Cloning $PRIVATE_REPO (private) via gh auth..."
        gh repo clone "$PRIVATE_REPO" "$INSTALL_DIR" -- --branch "$REF"
        success "Repo cloned"
    fi
}

install_symlink() {
    mkdir -p "$BIN_DIR"
    local target="$INSTALL_DIR/bin/tfkb"
    [[ -f "$target" ]] || die "tfkb CLI not found at $target. Repo content missing?"
    chmod +x "$target"
    ln -sf "$target" "$BIN_DIR/tfkb"
    success "Linked $BIN_DIR/tfkb"
}

ensure_path_in_rc() {
    if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
        return
    fi
    local rc
    case "${SHELL:-/bin/bash}" in
        */zsh)  rc="$HOME/.zshrc" ;;
        */bash) rc="$HOME/.bashrc" ;;
        */fish) rc="$HOME/.config/fish/config.fish" ;;
        *)      rc="$HOME/.profile" ;;
    esac
    if ! grep -q "$BIN_DIR" "$rc" 2>/dev/null; then
        warn "$BIN_DIR not in PATH. Adding to $rc..."
        echo "" >> "$rc"
        echo "# tfkb" >> "$rc"
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$rc"
        warn "Restart terminal or: source $rc"
    fi
    export PATH="$BIN_DIR:$PATH"
}

main() {
    log "=============================="
    log " TeraForge Knowledge Base Installer"
    log "=============================="

    check_cmd git
    check_cmd curl

    check_gh_auth
    install_uv_if_missing
    install_python_managed
    clone_or_update_repo
    install_symlink
    ensure_path_in_rc

    log ""
    log "Bootstrap complete. Running tfkb install..."
    log ""
    exec "$BIN_DIR/tfkb" install "$@"
}

main "$@"
