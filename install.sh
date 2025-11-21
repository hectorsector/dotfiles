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

# Install iTerm2 Shell Integration
echo "📦 Installing iTerm2 Shell Integration..."
if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    SHELL=$(which zsh) curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
    echo "✅ iTerm2 Shell Integration installed"
else
    echo "ℹ️  iTerm2 Shell Integration already installed"
fi

if [ -n "$GIST_ADDITIONAL_SETUP_URL" ] && [ -d "/workspaces/github" ]; then
  ADDITIONAL_SETUP_DIR="$HOME/.additional-setup"

  echo "➕ Cloning additional setup from gist..."
  if gh gist clone "$GIST_ADDITIONAL_SETUP_URL" "$ADDITIONAL_SETUP_DIR" 2>/dev/null; then
    echo "✅ Gist with additional setup cloned"

    if [ -f "$ADDITIONAL_SETUP_DIR/additional-setup.sh" ]; then
      echo "➕ Running additional setup..."
      bash "$ADDITIONAL_SETUP_DIR/additional-setup.sh"
      echo "✅ Additional setup completed succesfully."
    else
      echo "⚠️ Could not run additional setup script from gist."
    fi

  else
    echo "⚠️ Could not run private setup, gist may not be accessible"
  fi
else
  echo "ℹ️ No additional setup is available for this codespace."
fi

# Configure default directory for Codespaces
echo "🔧 Configuring default directory for Codespaces..."

# Add directory change to .zshrc if not already present
if ! grep -q "cd /workspaces/copilot-code-review-agent" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" << 'EOF'

# Auto-change to copilot-code-review-agent directory in Codespaces
if [ -d "/workspaces/copilot-code-review-agent" ]; then
    cd /workspaces/copilot-code-review-agent
fi
EOF

  echo "✅ Default directory configured"
else
  echo "ℹ️ Default directory already configured"
fi

echo "✅ Dotfiles installation complete!"
