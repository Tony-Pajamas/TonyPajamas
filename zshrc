# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# override default virtualenv indicator in prompt
VIRTUAL_ENV_DISABLE_PROMPT=1
venv_info() {
    [ $VIRTUAL_ENV ] && echo "(%B%F{reset}$(basename $VIRTUAL_ENV)%b%F{%(#.blue.green)})"
}

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# PS1 Control
TPrompt=1

# IP Off
CURRENTIP0=''
P0=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '

# P1 - Main IP Single
CURRENTIP1=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' )
P1=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.cyan.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})─(%F{reset}$CURRENTIP1%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{blue}#.%F{blue}$)%b%F{reset} '

# P2 - Multiple IP
CURRENTIP2=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' | sed -n ':a;N;${s/\n/|/g;p};ba' )
#CURRENTIP2=$(ifconfig | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' | sed -n ':a;N;${s/\n/|/g;p};ba' )
P2=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.cyan.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})─(%F{reset}$CURRENTIP2%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{blue}#.%F{blue}$)%b%F{reset} '

# P3 - Main + Date
CURRENTIP3=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' )
P3=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.cyan.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})─(%F{reset}$CURRENTIP3%F{%(#.blue.green)})-(%F{reset}%W%F{%(#.blue.green)})-(%F{reset}%t%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{blue}#.%F{blue}$)%b%F{reset} '

# P4 - Multi IP + Date
CURRENTIP4=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})' | sed -n ':a;N;${s/\n/|/g;p};ba' )
P4=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.cyan.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})─(%F{reset}$CURRENTIP4%F{%(#.blue.green)})-(%F{reset}%W%F{%(#.blue.green)})-(%F{reset}%t%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{blue}#.%F{blue}$)%b%F{reset} '



if [ "$color_prompt" = yes ]; then
    #PROMPT=$'%F{%(#.red.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.cyan.blue)}%n%(#.💀.㉿)%m%b%F{%(#.red.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.red.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '

	case $TPrompt in
		1)
			PROMPT=$P1
			;;

		2)
			PROMPT=$P2
			;;
		
		3)
			PROMPT=$P3
			;;
		
		4)
			PROMPT=$P4
			;;

		*)
			PROMPT=$P1
			;;
	esac

    RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && [ "$color_prompt" = yes ]; then
	. /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
	ZSH_HIGHLIGHT_STYLES[default]=none
	ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[path]=underline
	ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[command-substitution]=none
	ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[process-substitution]=none
	ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[assign]=none
	ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
	ZSH_HIGHLIGHT_STYLES[named-fd]=none
	ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
	ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
	ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a'
    ;;
*)
    ;;
esac

new_line_before_prompt=yes
precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$new_line_before_prompt" = yes ]; then
	if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
	    _NEW_LINE_BEFORE_PROMPT=1
	else
	    print ""
	fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

#GO Variables
export GOPATH=/root/go-workspace
export GOROOT=/usr/local/go
PATH=$PATH:$GOROOT/bin/:$GOPATH/bin

# some more ls aliases
alias ll='ls -ahl'
alias la='ls -A'
alias l='ls -CF'


#### TP SECTION
#TP Sets
export PATH="$PATH:/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
tpuser=$(whoami)
U=$(eval echo ~$USER)

#TP Aliases
alias ipconfig='ip -c -br addr'
alias ipc='ip -c -br addr'
alias simple='python /root/Works/Mains/SimpleHTTPServerWithUpload.py'
alias ns='netstat -antp | grep --color=always -e "^" -e "LISTEN"'
alias public='curl https://checkip.amazonaws.com/'
alias TPRC='rm -d -r -f /opt/TonyPajamas; cd /opt/; git clone https://github.com/Tony-Pajamas/TonyPajamas.git; cd ~ && cp /opt/TonyPajamas/zshrc ./.zshrc; source .zshrc'
alias t0='sed -i -e '86s/TPrompt=[0-9]/TPrompt=1/' $U/.zshrc; sleep 1; source $U/.zshrc'
alias t1='sed -i -e '86s/TPrompt=[0-9]/TPrompt=1/' $U/.zshrc; sleep 1; source $U/.zshrc'
alias t2='sed -i -e '86s/TPrompt=[0-9]/TPrompt=2/' $U/.zshrc; sleep 1; source $U/.zshrc'
alias t3='sed -i -e '86s/TPrompt=[0-9]/TPrompt=3/' $U/.zshrc; sleep 1; source $U/.zshrc'
alias t4='sed -i -e '86s/TPrompt=[0-9]/TPrompt=4/' $U/.zshrc; sleep 1; source $U/.zshrc'


#TP Tool Aliases
alias LDAPtoHTTP='bash /root/Works/Mains/LDAPtoHTTP.sh'
alias Drop-1='ssh drop@localhost -p 9001' #Dropbox Connections
alias Drop-2='ssh drop@localhost -p 9002' #Dropbox Connections
alias ToDrop-1='/root/Works/Mains/CloudToDrop.sh 1'
alias ToDrop-2='/root/Works/Mains/CloudToDrop.sh 2'
alias ToCloud='/root/Works/Mains/DropToCloud.sh'
alias ACSGSpace='ssh -i /root/.ssh/r-avkali kv@ACSGSpace -p 443'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi
