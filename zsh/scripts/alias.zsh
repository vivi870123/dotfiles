# Verbosity and settings that you pretty much just always are going to want.
# This allow using neovim remote when nvim is called from inside a running vim instance

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    alias nvim=nvr -cc split --remote-wait +'set bufhidden=wipe'
fi

if which kitty >/dev/null; then
  alias icat="kitty +kitten icat"
fi

alias \
	vim="nvim" \
	vimdiff="nvim -d" \
	batt="acpi" \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI" \
	del="trash" \
	mkd="mkdir -pv" \
	yt="youtube-dl --add-metadata -i" \
	yta="yt -x -f bestaudio/best" \
	ffmpeg="ffmpeg -hide_banner"\
	vtop="vtop -t nord"

# Colorize commands when possible.
alias \
	grep="grep --color=auto" \
	ls="exa --color=always" \
	l="ls -l" \
	ll"ls -la" \
	lh="ls -alt=changed | head -n 15" \
	la="ls -alFh" \
	ld="ls -ld .*" \
	lr="ls -R" \
	dud='du -d 1 -h' \
	duf='du -sh *' \
	diff="diff --color=auto" \
	cat="bat"


alias o='a -e xdg-open' # quick opening files with xdg-open
alias open='xdg-open'

# Git shortcuts
alias \
	gi='git init' \
	gl='git log' \
	gd='git diff' \
	ga='git add' \
	gaa='git add --all' \
	gs='git status' \
	gss='git status -s' \
	gc='git commit -m' \
	gpom='git push origin master' \

# These common commands are just too long! Abbreviate them.
alias \
	ka="killall" \
	trem="transmission-remote" \
	YT="youtube-viewer" \
	yt="youtube-dl --add-metadata -i" \
	yta="yt -x -f bestaudio/best" \
	sdn="sudo shutdown -h now" \
	sdr="sudo shutdown -r now" \
	f="$FILE" \
	e="$EDITOR" \
	v="$EDITOR" \
	Z="zathura"

# Some other stuff
alias \
	magit="nvim -c MagitOnly" \
	:q="exit" \
	j="z" \
	c="clear" \
	clear-password-cache="gpgconf --reload gpg-agent" \
	tmux="tmux -f ${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf" \
	ta="tmux attach -t" \
	td="tmux detach" \
	tls="tmux ls" \
	tkss="killall tmux" \
	tkill="tmux kill-session -t"

# Tree
alias \
	t1='tree -L 1' \
	t1a='tree -La 1' \
	t2='tree -L 2' \
	t2a='tree -La 2' \
	t3='tree -L 3' \
	t3a='tree -La 3' \
	t4='tree -L 4' \
	t4a='tree -La 4'
	tree='tree -CF'


# homestead aliases
alias \
	hp='homestead provision' \
	hu='homestead up' \
	hr='homestead reload' \
	hs='homestead suspend' \
	hh='homestead halt' \
	hssh='homestead ssh'

# laravel aliases
alias \
	a='php artisan' \
	art='php artisan' \
	amc="php artisan make" \
	amc="php artisan make:controller" \
	ame="php artisan make:event" \
	amj="php artisan make:job" \
	amm="php artisan make:migration" \
	amr="php artisan make:request" \
	ams="php artisan make:seeder" \
	amt="php artisan make:test" \
	aia="php artisan infyom:api" \
	aias="php artisan infyom:api_scaffold" \
	aim="php artisan infyom:model" \
	aiM="php artisan infyom:migration" \
	aip="php artisan infyom:publish" \
	air="php artisan infyom:repository" \
	aiR="php artisan infyom:rollback" \
	ais="php artisan infyom:scaffold" \
	apic="php artisan infyom.api:controller" \
	apir="php artisan infyom.api:request" \
	apit="php artisan infyom.api:tests" \
	isc="php artisan infyom.scaffold:controller" \
	isr="php artisan infyom.scaffold:request" \
	isv="php artisan infyom.scaffold:views" \
	test="./vendor/bin/phpunit"
