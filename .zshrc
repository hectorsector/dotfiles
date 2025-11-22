# Load Antigen
source ~/antigen.zsh

# Load the oh-my-zsh's library (this gives you the same base functionality)
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh)
antigen bundle git
antigen bundle jsontools

# Optional: Add more useful plugins
# antigen bundle zsh-users/zsh-syntax-highlighting
# antigen bundle zsh-users/zsh-autosuggestions

# Load the theme
antigen theme fino-time

# Tell Antigen that you're done
antigen apply

# Personal configs

# Homebrew
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Version and env managers for ruby and node
command -v rbenv &> /dev/null && eval "$(rbenv init - zsh)"
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# Fuzzy search
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="node_modules/.bin:$PATH"

# Pagers
export PAGER="cat"
export GIT_PAGER="cat"
export SYSTEMD_PAGER="cat"
export MANPAGER="cat"
export LESS="-F -X -R"  # -F makes less exit if content fits on one screen

# GitHub CLI
command -v gh &> /dev/null && gh config set pager ''

# Git configuration
git config --global core.pager cat 2>/dev/null
command -v go &> /dev/null && export PATH=$PATH:$(go env GOPATH)/bin

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
