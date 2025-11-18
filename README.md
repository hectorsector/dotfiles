# Dotfiles

Personal shell configuration for macOS and GitHub Codespaces.

## What's Included

- **Zsh Configuration** (`.zshrc`) - Shell preferences, tool integrations, and environment setup
- **iTerm2 Shell Integration** - I use it for command navigation with keyboard shortcuts (`⌘⇧↑`/`⌘⇧↓`)
- **Automatic Installation** - optimized for use with codespaces

## Tools & Integrations

- **[Oh My Zsh](https://ohmyz.sh/)** - Zsh framework, theme
- **[Homebrew](https://brew.sh/)** - Package manager (macOS)
- **[rbenv](https://github.com/rbenv/rbenv)** - Ruby version manager
- **[nvm](https://github.com/nvm-sh/nvm)** - Node.js version manager
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder for command-line searches (files, command history, processes)
- **[direnv](https://direnv.net/)** - Automatically loads/unloads environment variables based on current directory
- **[Go](https://go.dev/)** - Go toolchain
- **[GitHub CLI](https://cli.github.com/)** 

## Key Features

### Pager Settings
Configured to use `cat` instead of `less` for:
- Git diffs and logs
- GitHub CLI output
- Man pages
- System pager

### iTerm2 Navigation
Shell integration enables:
- `⌘⇧↑` - Jump to previous command
- `⌘⇧↓` - Jump to next command
- `⌘←` - Beginning of line
- `⌘→` - End of line

### Oh My Zsh Plugins
- `git` - Git aliases and completions
- `jsontools` - JSON formatting utilities
