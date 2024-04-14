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
    "$HOME/.local/bin/dmenu"(N-/)
    "$HOME/.local/share/flatpak/exports/share"(N-/)
    "$HOME/.config/composer/vendor/bin/"(N-/)
    "$CARGO_HOME/bin"(N-/)
    "$GOPATH/bin"(N-/)
    "$DENO_INSTALL/bin"(N-/)
    # package manager for neovim
    "$HOME/.local/share/bob/nvim-bin"(N-/)
    "$HOME/.local/share/fnm/default"(N-/)
    "$path[@]"
)

fpath=(
    "$XDG_DATA_HOME/zsh/completions"(N-/)
    "$fpath[@]"
)

### Options ###
setopt AUTO_CD
setopt GLOBDOTS
setopt RM_STAR_WAIT
setopt CORRECT                  # command auto-correction
setopt COMPLETE_ALIASES
setopt AUTO_PUSHD                # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack.
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd.

### history ###
HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=120000
export SAVEHIST=100000

# set some history options
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt MAGIC_EQUAL_SUBST
setopt NO_FLOW_CONTROL
setopt NO_SHARE_HISTORY # do not share history
setopt AUTOPARAMSLASH # tab completing directory appends a slash

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

# chpwd() {
#     printf "\e[34m%s\e[m:\n" "${PWD/$HOME/~}"
#     if (( ${+commands[eza]} )); then
#         eza --group-directories-first --icons -a
#     else
#         ls -a
#     fi
# }

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

zle -N widget::history
zle -N forward-kill-word

#-------------------------------------------------------------------------------
#               VI-MODE
#-------------------------------------------------------------------------------
# @see: https://thevaluable.dev/zsh-install-configure-mouseless/
bindkey -v # enables vi mode, using -e = emacs
export KEYTIMEOUT=1

bindkey "^R"        widget::history                 # C-r
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
