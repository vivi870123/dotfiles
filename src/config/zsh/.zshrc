### paths ###
typeset -gU PATH path
typeset -gU FPATH fpath

#-------------------------------------------------------------------------------
#       ENV VARIABLES
#-------------------------------------------------------------------------------
# PATH.
# (N-/): do not register if the directory does not exists
# (Nn[-1]-/)
#
#  N   : NULL_GLOB option (ignore path if the path does not match the glob)
#  n   : Sort the output
#  [-1]: Select the last item in the array
#  -   : follow the symbol links
#  /   : ignore files
#  t   : tail of the path
# CREDIT: @ahmedelgabri
path+=(
    '/usr/local/bin'(N-/)
    '/usr/bin'(N-/)
    '/bin'(N-/)
    '/usr/local/sbin'(N-/)
    '/usr/sbin'(N-/)
    '/sbin'(N-/)
    "/var/lib/flatpak/exports/share"(N-/)
)

path=(
    "$HOME/.local/bin"(N-/)
    "$HOME/.local/bin/statusbar"(N-/)
    "$HOME/.local/share/flatpak/exports/share"(N-/)
    "$CARGO_HOME/bin"(N-/)
    "$GOPATH/bin"(N-/)
    "$DENO_INSTALL/bin"(N-/)
    "$GEM_HOME/bin"(N-/)
    "$GHRD_DATA_HOME/bin"(N-/)
    # package manager for neovim
    "$HOME/.local/share/bob/nvim-bin"(N-/)
    "$path[@]"
)

fpath=(
  "$GHRD_DATA_HOME/completions"(N-/)
  "$XDG_DATA_HOME/zsh/completions"(N-/)
  "$fpath[@]"
)

### Options ###
setopt AUTO_CD
setopt RM_STAR_WAIT
setopt CORRECT                  # command auto-correction
setopt COMPLETE_ALIASES

### history ###
HISTFILE="$XDG_STATE_HOME/zsh_history"
# HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
export HISTSIZE=120000
export SAVEHIST=100000

# set some history options
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt AUTOPARAMSLASH # tab completing directory appends a slash
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt AUTO_PUSHD                # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack.
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd.


#-------------------------------------------------------------------------------
# source
#-------------------------------------------------------------------------------
source() {
    local input="$1"
    local cache="$input.zwc"
    if [[ ! -f "$cache" || "$input" -nt "$cache" ]]; then
        zcompile "$input"
    fi
    \builtin source "$@"
}

#-------------------------------------------------------------------------------
# hooks
#-------------------------------------------------------------------------------
zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|history|j|lazygit|la|ll|ls|rm|rmdir|trash)($| )" ]]
}


#-------------------------------------------------------------------------------
# key bindings
#-------------------------------------------------------------------------------
widget::history() {
    local selected="$(history -inr 1 | fzf --exit-0 --query "$LBUFFER" | cut -d' ' -f4- | sed 's/\\n/\n/g')"
    if [[ -n "$selected" ]]; then
        BUFFER="$selected"
        CURSOR=$#BUFFER
    fi
    zle -R -c # refresh screen
}

widget::ghq::source() {
    local session color icon green="\e[32m" blue="\e[34m" reset="\e[m" checked="\U000f0132" unchecked="\U000f0131"
    local sessions=($(tmux list-sessions -F "#S" 2>/dev/null))

    ghq list | sort | while read -r repo; do
        session="${repo//[:. ]/-}"
        color="$blue"
        icon="$unchecked"
        if (( ${+sessions[(r)$session]} )); then
            color="$green"
            icon="$checked"
        fi
        printf "$color$icon %s$reset\n" "$repo"
    done
}
widget::ghq::select() {
    local root="$(ghq root)"
    widget::ghq::source | fzf --exit-0 --preview="fzf-preview-git ${(q)root}/{+2}" --preview-window="right:60%" | cut -d' ' -f2-
}
widget::ghq::dir() {
    local selected="$(widget::ghq::select)"
    if [[ -z "$selected" ]]; then
        return
    fi

    local repo_dir="$(ghq list --exact --full-path "$selected")"
    BUFFER="cd ${(q)repo_dir}"
    zle accept-line
    zle -R -c # refresh screen
}
widget::ghq::session() {
    local selected="$(widget::ghq::select)"
    if [[ -z "$selected" ]]; then
        return
    fi

    local repo_dir="$(ghq list --exact --full-path "$selected")"
    local session_name="${selected//[:. ]/-}"

    if [[ -z "$TMUX" ]]; then
        BUFFER="tmux new-session -A -s ${(q)session_name} -c ${(q)repo_dir}"
        zle accept-line
    elif [[ "$(tmux display-message -p "#S")" != "$session_name" ]]; then
        tmux new-session -d -s "$session_name" -c "$repo_dir" 2>/dev/null
        tmux switch-client -t "$session_name"
    else
        BUFFER="cd ${(q)repo_dir}"
        zle accept-line
    fi
    zle -R -c # refresh screen
}

zle -N widget::history
zle -N widget::ghq::dir
zle -N widget::ghq::session
zle -N forward-kill-word


#-------------------------------------------------------------------------------
#               VI-MODE
#-------------------------------------------------------------------------------
# @see: https://thevaluable.dev/zsh-install-configure-mouseless/
bindkey -v # enables vi mode, using -e = emacs
export KEYTIMEOUT=1

bindkey "^R"        widget::history                 # C-r
bindkey "^G"        widget::ghq::session            # C-g
bindkey "^[g"       widget::ghq::dir                # Alt-g
bindkey "^A"        beginning-of-line               # C-a
bindkey "^E"        end-of-line                     # C-e
bindkey "^K"        kill-line                       # C-k
bindkey "^Q"        push-line-or-edit               # C-q
bindkey "^W"        vi-backward-kill-word           # C-w
bindkey "^?"        backward-delete-char            # backspace
bindkey "^[[3~"     delete-char                     # delete
bindkey "^[[1;3D"   backward-word                   # Alt + arrow-left
bindkey "^[[1;3C"   forward-word                    # Alt + arrow-right
bindkey "^[^?"      vi-backward-kill-word           # Alt + backspace
bindkey "^[[1;33~"  kill-word                       # Alt + delete
bindkey -M vicmd "^A" beginning-of-line             # vi: C-a
bindkey -M vicmd "^E" end-of-line                   # vi: C-e

# sheldon
sheldon::load() {
    local profile="$1"
    local plugins_file="$SHELDON_CONFIG_DIR/plugins.toml"
    local cache_file="$XDG_CACHE_HOME/sheldon/$profile.zsh"
    if [[ ! -f "$cache_file" || "$plugins_file" -nt "$cache_file" ]]; then
        mkdir -p "$XDG_CACHE_HOME/sheldon"
        sheldon --profile="$profile" source >"$cache_file"
        zcompile "$cache_file"
    fi
    \builtin source "$cache_file"
}

sheldon::update() {
    sheldon --profile="eager" lock --update
    sheldon --profile="lazy" lock --update
    sheldon --profile="update" --quiet source | zsh
}

sheldon::load eager
