#!/bin/bash

set -e

echo "🚀 Running dotfiles installation..."

# Change default shell to zsh first
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔧 Setting zsh as default shell..."
    sudo chsh -s $(which zsh) $(whoami) 2>/dev/null || chsh -s $(which zsh)
    echo "✅ Default shell changed to zsh (reconnect to apply)"
else
    echo "ℹ️  zsh is already the default shell"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed"
else
    echo "ℹ️  Oh My Zsh already installed"
fi

# Install iTerm2 Shell Integration
echo "📦 Installing iTerm2 Shell Integration..."
if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
    echo "✅ iTerm2 Shell Integration installed"
else
    echo "ℹ️  iTerm2 Shell Integration already installed"
fi

echo "✅ Dotfiles installation complete!"


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
