# vim: fdm=marker fdl=0

### ls-colors ###
export LS_COLORS="di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32"

#-------------------------------------------------------------------------------
# Functions {{{
#-------------------------------------------------------------------------------
# A Handful of very useful functions courtesy of
# https://github.com/jdsimcoe/dotfiles/blob/master/.zshrc
function port() {
  lsof -n -i ":$@" | grep LISTEN
}

# neovim
function e() {
  nvim "$@"
}

# chmod a directory
function ch() {
  sudo chmod -R 775 "$@"
}

# chown a directory
function cho() {
  sudo chown -R www:www "$@"
}

# Do a Git clone
function clone() {
  git clone "$@"
}

# Do a Git commit
function quickie() {
  git add .
  git add -u :/
  git commit -m "$@"
}

function quickpush() {
  git add .
  git commit -m "$@"
  echo "🍏 commit message: [$@]"
  git push
  echo 🚀 quick push success... or not.
}

# Do a Git commit/push
function gcap() {
  git add .
  git add -u :/
  git commit -m "$@"
  git push
}

# Do a Git push from the current branch
function push() {
  git push origin "$@"
}

# Install a generic NPM module and save to devDependencies
function npmi() {
  npm install --save-dev "$@"
}

J() {
  local root dir
  root="${$(git rev-parse --show-cdup 2>/dev/null):-.}"
  dir="$(fd --color=always --hidden --follow --type=d . "$root" | fzf --select-1 --query="$*" --preview='fzf-preview-file {}')"
  [[ -n "$dir" ]] && builtin cd "$dir"
}


pathed() {
  PATH="$(tr ':' '\n' <<<"$PATH" | ped | tr '\n' ':' | sed -E 's/:(:|$)//g')"
}

re() {
  [[ $# -eq 0 ]] && return 1
  local selected="$(rg --color=always --line-number "$@" | fzf -d ':' --preview='
  local file={1} line={2} n=10
  local start="$(( line > n ? line - n : 1 ))"
  bat --color=always --highlight-line="$line" --line-range="$start:" "$file"
  ')"
  [[ -z "$selected" ]] && return
  local file="$(cut -d ':' -f 1 <<<"$selected")" line="$(cut -d ':' -f 2 <<<"$selected")"
  "$EDITOR" +"$line" "$file"
}

# script edit: edit script files from script directory
se() {
  choice="$(find ~/.local/bin -mindepth 1 -printf '%P\n' | fzf)"
  [ -f "$HOME/.local/bin/$choice" ] && $EDITOR "$HOME/.local/bin/$choice"

}

### fzf ###
# fshow - git commit browser
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
  (grep -o '[a-f0-9]\{7\}' | head -1 |
  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
  {}
  FZF-EOF"
}

# tm with no sessions open it will create a session called "new".
# tm irc it will attach to the irc session (if it exists), else it will create it.
# tm with one session open, it will attach to that session.
# tm with more than one session open it will let you select the session via fzf.
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# fs [FUZZY PATTERN] - Select selected tmux session
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview\
  'bat --color "always" {}' --preview-window=right:60% ))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff "$sha"
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" "$sha"
      break;
    else
      git stash show -p "$sha"
    fi
  done
}

# }}}
#-------------------------------------------------------------------------------
# Aliases {{{
#-------------------------------------------------------------------------------
alias open='xdg-open'

alias ref="shortcuts >/dev/null; source \${XDG_CONFIG_HOME:-\$HOME/.config}/shell/shortcutrc ; source \${XDG_CONFIG_HOME:-\$HOME/.config}/shell/zshnameddirrc"

# sudo not required for some system commands
for command in mount umount sv pacman updatedb su shutdown poweroff reboot ; do
  alias $command="sudo $command"
done; unset command

alias j="z"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias cp="cp -iv"
alias cpr="cp -ivr"
alias mv="mv -iv"
alias md="mkdir -p"
alias rd="rmdir"
alias rm="rm -vI"
alias del="rm -rf"

alias :q="exit"
alias dots="cd $DOTFILES"
alias c='clear'

alias la='ls -a'
alias ll='ls -al'
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'

alias fuckit='export THEFUCK_REQUIRE_CONFIRMATION=False; fuck; export THEFUCK_REQUIRE_CONFIRMATION=True'
alias icat="kitty +kitten icat"
alias pip="pip3"

alias minimalvim="nvim -u ~/minimal.vim"
alias notes="cd $SYNC_DIR/notes/neorg/ && nvim"
alias vimdiff="nvim -d"

alias art="php artisan "
### yarn/npm ###
alias ns="clear && npm start"
alias nt="clear && npm test"
alias yt="clear && yarn test"
alias ys="clear && yarn start"

### yay ###
alias ys="yay -Sy"
alias yu="yay -Syu"
alias yq="yay -Q"
alias yr="yay -Rs"

### tremc ###
alias tremc='transmission-daemon && tremc'

### zathura ###
alias Z="zathura"

# Use neovim for vim if present.
[ -x "$(command -v nvim)" ] && alias   e="nvim"
[ -x "$(command -v nvim)" ] && alias   v="nvim" vimdiff="nvim -d"
[ -x "$(command -v nvim)" ] && alias  vi="nvim" vimdiff="nvim -d"
[ -x "$(command -v nvim)" ] && alias vim="nvim" vimdiff="nvim -d"

### GIT ###
alias   g="git"
alias  gi="git init"
alias  gs="git status"
alias  gl="git log"
alias gss="git status -s"
alias  gc="git commit -m"
alias  gd="git diff"
alias gcb='git checkout -b'
alias gco="git checkout"
alias  ga='git add'
alias gaa='git add --all'
alias  gb='git branch'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbr='git branch --remote'
alias  gp='git push'

### bat ###
if (( ${+commands[bat]} )); then
  export MANPAGER='nvim +Man!'
  export MANPATH="/usr/local/man:$MANPATH"
  alias cat='bat --paging=never'
fi

### eza ###
if (( ${+commands[eza]} )); then
alias l="eza -l"
  alias ls="eza"
  alias l='eza --group-directories-first -l --header --color-scale --git --icons --time-style=long-iso'
  alias ls='eza --group-directories-first'
  alias la='eza --group-directories-first -a'
  alias ll='eza --group-directories-first -al --header --color-scale --git --icons --time-style=long-iso'
  alias tree='eza --group-directories-first --tree --icons'
fi

### diff ###
diff() {
  command diff "$@" | bat --paging=never --plain --language=diff
  return "${pipestatus[1]}"
}
alias diffall='diff --new-line-format="+%L" --old-line-format="-%L" --unchanged-line-format=" %L"'

### hgrep ###
alias hgrep="hgrep --hidden --glob='!.git/'"
# }}}
#-------------------------------------------------------------------------------

### navi ###
export NAVI_CONFIG="$XDG_CONFIG_HOME/navi/config.yaml"

__navi_search() {
  LBUFFER="$(navi --print --query="$LBUFFER")"
  zle reset-prompt
}
zle -N __navi_search
bindkey '^N' __navi_search

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - hup int quit term pwr exit' hup int quit term pwr exit
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'

#-------------------------------------------------------------------------------
# Completion
#-------------------------------------------------------------------------------
if [[ "$TERM" == "xterm-kitty" ]]; then
  kitty + complete setup zsh | source /dev/stdin
fi

# persistent reshahing i.e puts new executables in the $path
# if no command is set typing in a line will cd by default
zstyle ':completion:*' rehash true

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# Colorize completions using default `ls` colors.
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


# Make completion:
# (stolen from Wincent)
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' \
  '+m:{[:lower:]}={[:upper:]}' \
  '+m:{[:upper:]}={[:lower:]}' \
  '+m:{_-}={-_}' \
  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select
zmodload zsh/complist

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

### Docker ###
docker() {
  if [[ "$#" -eq 0 ]] || [[ "$1" = "compose" ]] || ! command -v "docker-$1" >/dev/null; then
    command docker "${@:1}"
  else
    "docker-$1" "${@:2}"
  fi
}

docker-rm() {
if [[ "$#" -eq 0 ]]; then
  command docker ps -a | fzf --exit-0 --multi --header-lines=1 | awk '{ print $1 }' | xargs -r docker rm --
else
  command docker rm "$@"
fi
}

docker-rmi() {
if [[ "$#" -eq 0 ]]; then
  command docker images | fzf --exit-0 --multi --header-lines=1 | awk '{ print $3 }' | xargs -r docker rmi --
else
  command docker rmi "$@"
fi
}


# ~/.icons
export XCURSOR_PATH=/usr/share/icons:"$XDG_DATA_HOME"/icons

export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export SUDO_ASKPASS="$HOME/.local/bin/bemenupass"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"

### Editor ###
export EDITOR="vi"
(( ${+commands[vim]} )) && EDITOR="vim"
(( ${+commands[nvim]} )) && EDITOR="nvim"

export GIT_EDITOR="$EDITOR"

### GPG ###
export GPG_TTY="$TTY"

### less ###
export LESSHISTFILE='-'

### Node.js ###
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_history"

### npm ###
export NPM_CONFIG_DIR="$XDG_CONFIG_HOME/npm"
export NPM_DATA_DIR="$XDG_DATA_HOME/npm"
export NPM_CACHE_DIR="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_USERCONFIG="$NPM_CONFIG_DIR/npmrc"

### SQLite3 ###
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"

### MySQL ###
export MYSQL_HISTFILE="$XDG_STATE_HOME/mysql_history"

### PostgreSQL ###
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"

### fzf ###
export FZF_DEFAULT_OPTS='--reverse --border --ansi --bind="ctrl-d:print-query,ctrl-p:replace-query"'
export FZF_DEFAULT_COMMAND='fd --hidden --color=always'

### ripgrep ###
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/rg/.ripgreprc" # RG

### wget ###
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc" # WGET

### tealdeer ###
export TEALDEER_CONFIG_DIR="$XDG_CONFIG_HOME/tealdeer"

if (( ${+commands[zoxide]} )); then
	eval "$(zoxide init zsh)"
fi

if (( ${+commands[nvr]} )) && (( ${+commands[pip3]} )); then
	pip3 install neovim-remote
fi

if (( ${+commands[fnm]} )); then
	eval "$(fnm env --use-on-cd)"
fi

if which bemenu >/dev/null; then
  source $XDG_CONFIG_HOME/bemenu/bemenurc
fi

### local ###
if [[ -f "$ZDOTDIR/local.zsh" ]]; then
  source "$ZDOTDIR/local.zsh"
fi

sheldon::load lazy
