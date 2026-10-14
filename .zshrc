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

# History search
bindkey '^R' history-incremental-search-backward

# Homebrew
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Version and env managers for ruby and node
command -v rbenv &> /dev/null && eval "$(rbenv init - zsh)"
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# Fuzzy search
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif command -v brew &> /dev/null && [ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi
(( $+functions[fzf-history-widget] )) && bindkey '^R' fzf-history-widget
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

# Synced repos: dotfiles (.zshrc, iTerm2 prefs) and private Copilot skills
DOTFILES_DIR="${${:-$HOME/.zshrc}:A:h}"
SYNCED_REPOS=("$DOTFILES_DIR" "$HOME/copilot-skills")

# Startup reminder; local-only checks (no fetch) so it stays fast
for _repo in $SYNCED_REPOS; do
  [ -d "$_repo/.git" ] || continue
  _dirty=$(git -C "$_repo" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  _ahead=$(git -C "$_repo" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  (( _dirty || _ahead )) && echo "⚠️  ${_repo:t}: $_dirty uncommitted, $_ahead unpushed (run dotsync)"
done
unset _repo _dirty _ahead

# Summarize staged changes, e.g. "Add foo skill; update .zshrc and iTerm2 settings"
_dotsync_summary() {
  local code file item msg part
  local -aU added updated removed
  git -C "$1" diff --cached --name-status --no-renames | while IFS=$'\t' read -r code file; do
    case $file in
      skills/*/*) item="${${file#skills/}%%/*} skill" ;;
      iterm2/*)   item="iTerm2 settings" ;;
      *)          item=$file ;;
    esac
    case $code in
      A) added+=$item ;;
      D) removed+=$item ;;
      *) updated+=$item ;;
    esac
  done
  updated=(${updated:|added})
  for part in "add:added" "update:updated" "remove:removed"; do
    local -a items=(${(P)${part#*:}})
    (( $#items )) || continue
    if (( $#items > 1 )); then
      items="${(j:, :)items[1,-2]} and ${items[-1]}"
    fi
    msg+="${msg:+; }${part%%:*} $items"
  done
  echo "${(C)msg[1]}${msg[2,-1]}"
}

# Commit, pull, and push all synced repos. Usage: dotsync ["commit message"]
dotsync() {
  local repo
  for repo in $SYNCED_REPOS; do
    [ -d "$repo/.git" ] || continue
    echo "🔄 ${repo:t}"
    git -C "$repo" status --short
    git -C "$repo" add -A
    git -C "$repo" diff --cached --quiet || git -C "$repo" commit -qm "${1:-$(_dotsync_summary "$repo")}"
    git -C "$repo" pull --rebase --quiet && git -C "$repo" push --quiet
  done
}
