# ~/.bashrc

# ─────────────────────────────────────────────────────
# Shell Settings
# ─────────────────────────────────────────────────────
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'TAB:menu-complete'

# ─────────────────────────────────────────────────────
# Environment Variables
# ─────────────────────────────────────────────────────
export GOROOT=/usr/local/go
export GOPATH=$HOME/Dev/go
export GOBIN=$GOPATH/bin
export PATH=$GOROOT/bin:$GOBIN:$PATH
export PATH=$PATH:$(go env GOPATH)/bin

export HISTFILESIZE=10000
export HISTSIZE=10000

# ─────────────────────────────────────────────────────
# Load External Config
# ─────────────────────────────────────────────────────
[ -f ~/.bash_functions ] && source ~/.bash_functions
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# ─────────────────────────────────────────────────────
# Starship
# ─────────────────────────────────────────────────────
eval "$(starship init bash)"
