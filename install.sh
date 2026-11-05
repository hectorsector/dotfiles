#!/bin/bash

set -e

echo "🚀 Running dotfiles installation..."

# Determine the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Symlink .zshrc from dotfiles repo to home directory
echo "📝 Installing .zshrc..."
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    echo "✅ .zshrc symlinked"
else
    echo "⚠️  .zshrc not found in dotfiles directory"
fi

# Change default shell to zsh first
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔧 Setting zsh as default shell..."
    sudo chsh -s $(which zsh) $(whoami) 2>/dev/null || chsh -s $(which zsh)
    echo "✅ Default shell changed to zsh (reconnect to apply)"
else
    echo "ℹ️  zsh is already the default shell"
fi

# Install Antigen if not already installed
if [ ! -f "$HOME/antigen.zsh" ]; then
    echo "📦 Installing Antigen..."
    curl -L git.io/antigen > "$HOME/antigen.zsh"
    echo "✅ Antigen installed"
else
    echo "ℹ️  Antigen already installed"
fi

# Install fzf for command and history search
if command -v fzf >/dev/null 2>&1; then
    echo "ℹ️  fzf is already installed"
elif command -v brew >/dev/null 2>&1; then
    echo "📦 Installing fzf..."
    brew install fzf
    echo "✅ fzf installed"
else
    echo "⚠️  Homebrew is not installed; skipping fzf installation"
fi

# Install iTerm2 Shell Integration
echo "📦 Installing iTerm2 Shell Integration..."
if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    curl -L https://iterm2.com/shell_integration/zsh -o "$HOME/.iterm2_shell_integration.zsh"
    echo "✅ iTerm2 Shell Integration installed"
else
    echo "ℹ️  iTerm2 Shell Integration already installed"
fi

# Load iTerm2 preferences from the dotfiles repo (macOS only)
if [ "$(uname)" = "Darwin" ] && [ -f "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" ]; then
    echo "🔧 Configuring iTerm2 to load preferences from dotfiles..."
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    echo "✅ iTerm2 preferences configured (restart iTerm2 to apply)"
fi

# Private agent instructions (skills + Claude Code instructions): clone (or update),
# symlink ~/.copilot/skills and ~/.copilot/copilot-instructions.md, and import
# claude/CLAUDE.md from ~/.claude/CLAUDE.md
AGENT_REPO="git@github-personal:hectorsector/agent-instructions.git"
AGENT_DIR="$HOME/hectorsector/agent-instructions"
SKILLS_DIR="$AGENT_DIR"
echo "🧠 Installing private agent instructions..."
if [ -d "$AGENT_DIR/.git" ]; then
    git -C "$AGENT_DIR" pull --ff-only --quiet || echo "⚠️  Could not update $AGENT_DIR"
else
    mkdir -p "$(dirname "$AGENT_DIR")"
    if ! git clone --quiet "$AGENT_REPO" "$AGENT_DIR" 2>/dev/null; then
        echo "⚠️  Could not clone $AGENT_REPO (no access?); skipping agent instructions"
    fi
fi

if [ -f "$AGENT_DIR/claude/CLAUDE.md" ]; then
    CLAUDE_IMPORT="@~/hectorsector/agent-instructions/claude/CLAUDE.md"
    mkdir -p "$HOME/.claude"
    touch "$HOME/.claude/CLAUDE.md"
    if ! grep -qxF "$CLAUDE_IMPORT" "$HOME/.claude/CLAUDE.md"; then
        printf '\n%s\n' "$CLAUDE_IMPORT" >> "$HOME/.claude/CLAUDE.md"
        echo "✅ ~/.claude/CLAUDE.md imports claude/CLAUDE.md"
    fi
fi

if [ -d "$SKILLS_DIR/skills" ]; then
    mkdir -p "$HOME/.copilot"
    if [ -d "$HOME/.copilot/skills" ] && [ ! -L "$HOME/.copilot/skills" ]; then
        BACKUP="$HOME/.copilot/skills.backup.$(date +%Y%m%d%H%M%S)"
        mv "$HOME/.copilot/skills" "$BACKUP"
        echo "ℹ️  Existing ~/.copilot/skills moved to $BACKUP"
    fi
    ln -sfn "$SKILLS_DIR/skills" "$HOME/.copilot/skills"
    echo "✅ ~/.copilot/skills symlinked"
fi

if [ -f "$AGENT_DIR/shared/instructions.md" ]; then
    mkdir -p "$HOME/.copilot"
    COPILOT_INSTRUCTIONS="$HOME/.copilot/copilot-instructions.md"
    if [ -f "$COPILOT_INSTRUCTIONS" ] && [ ! -L "$COPILOT_INSTRUCTIONS" ]; then
        BACKUP="$COPILOT_INSTRUCTIONS.backup.$(date +%Y%m%d%H%M%S)"
        mv "$COPILOT_INSTRUCTIONS" "$BACKUP"
        echo "ℹ️  Existing ~/.copilot/copilot-instructions.md moved to $BACKUP"
    fi
    ln -sfn "$AGENT_DIR/shared/instructions.md" "$COPILOT_INSTRUCTIONS"
    echo "✅ ~/.copilot/copilot-instructions.md symlinked"
fi

echo "✅ Dotfiles installation complete!"
