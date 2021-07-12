#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_symlinks() {

    declare -a FILES_TO_SYMLINK=(
        ".config/zsh/zshenv"

        "git/gitconfig"
        "git/gitignore"

        "stylua.toml"
        "ignore"
    )

    local i=""
    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    for i in "${FILES_TO_SYMLINK[@]}"; do

        sourceFile="$(cd .. && pwd)/$i"
        targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ ! -e "$targetFile" ] || $skipQuestions; then

            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"

        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else

            if ! $skipQuestions; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then

                    rm -rf "$targetFile"

                    execute \
                        "ln -fs $sourceFile $targetFile" \
                        "$targetFile → $sourceFile"

                else
                    print_error "$targetFile → $sourceFile"
                fi

            fi

        fi

    done

}

create_local_symlinks() {
    declare -a FILES_TO_SYMLINK=(
        "bin/ext"
        "bin/nightly"
        "bin/podentr"
        "bin/qndl"
        "bin/queueandnotify"
        "bin/shortcuts"
        "bin/transadd"
        "bin/vifmimg"
    )

    local i=""
    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    for i in "${FILES_TO_SYMLINK[@]}"; do

        sourceFile="$(cd .. && pwd)/$i"
        targetFile="$HOME/.local/bin/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ ! -e "$targetFile" ] || $skipQuestions; then

            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"

        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else

            if ! $skipQuestions; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then

                    rm -rf "$targetFile"

                    execute \
                        "ln -fs $sourceFile $targetFile" \
                        "$targetFile → $sourceFile"

                else
                    print_error "$targetFile → $sourceFile"
                fi

            fi

        fi

    done

}

create_config_symlinks() {
    declare -a FILES_TO_SYMLINK=(
	alacritty
	composer
	kitty
	lazygit
	mpv/input.conf
	mpv/mpv.conf
	mpv/scripts
	newsboat
	rg
	shell
	sxiv
	tmux
	vifm
	wget
	zsh
	zathura
)

local i=""
local sourceFile=""
local targetFile=""
local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
	    && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    for i in "${FILES_TO_SYMLINK[@]}"; do

	    sourceFile="$(cd ../.config && pwd)/$i"
	    targetFile="$HOME/.config/$i"

	    if [ ! -e "$targetFile" ] || $skipQuestions; then

		    execute \
			    "ln -fs $sourceFile $targetFile" \
			    "$targetFile → $sourceFile"

	    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
		    print_success "$targetFile → $sourceFile"
	    else

		    if ! $skipQuestions; then

			    ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
			    if answer_is_yes; then

				    rm -rf "$targetFile"

				    execute \
					    "ln -fs $sourceFile $targetFile" \
					    "$targetFile → $sourceFile"

			    else
				    print_error "$targetFile → $sourceFile"
			    fi

		    fi

	    fi

    done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
	print_in_purple "\n • Create symbolic links\n\n"
	create_symlinks "$@"
	create_local_symlinks "$@"
	create_config_symlinks "$@"
}

main "$@"
