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

# Private Copilot CLI skills: clone (or update) and symlink into ~/.copilot/skills
SKILLS_REPO="git@github-personal:hectorsector/copilot-skills.git"
SKILLS_DIR="$HOME/copilot-skills"
echo "🧠 Installing Copilot CLI skills..."
if [ -d "$SKILLS_DIR/.git" ]; then
    git -C "$SKILLS_DIR" pull --ff-only --quiet || echo "⚠️  Could not update $SKILLS_DIR"
elif ! git clone --quiet "$SKILLS_REPO" "$SKILLS_DIR" 2>/dev/null; then
    echo "⚠️  Could not clone $SKILLS_REPO (no access?); skipping skills"
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

echo "✅ Dotfiles installation complete!"
