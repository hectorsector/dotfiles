#!/bin/bash

set -e

echo "🚀 Running dotfiles installation..."

# Install iTerm2 Shell Integration
echo "📦 Installing iTerm2 Shell Integration..."
if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
    echo "✅ iTerm2 Shell Integration installed"
else
    echo "ℹ️  iTerm2 Shell Integration already installed"
fi

# Symlink dotfiles
echo "🔗 Creating symlinks for dotfiles..."
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"

echo "✅ Dotfiles installation complete!"
