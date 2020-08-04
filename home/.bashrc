#!/bin/bash
# Customized bash environment.
#
# Pat Collins <http://burned.com>
#
# With help from Ryan Tomayko <http://tomayko.com/about>

# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
      . /etc/bashrc

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell                 >/dev/null 2>&1
shopt -s extglob                 >/dev/null 2>&1
# Enable history appending instead of overwriting.
shopt -s histappend              >/dev/null 2>&1
shopt -s hostcomplete            >/dev/null 2>&1
shopt -s interactive_comments    >/dev/null 2>&1
shopt -u mailwarn                >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
umask 0022

# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------

# detect interactive shell
case "$-" in
  *i*) INTERACTIVE=yes ;;
  *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
  -*) LOGIN=yes ;;
  *)  unset LOGIN ;;
esac

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"

# history stuff
HISTCONTROL=ignoreboth
HISTFILESIZE=10000
HISTSIZE=10000

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)
HAVE_NVIM=$(command -v nvim)

EDITOR=vi

if [[ -n "$HAVE_VIM" ]]; then
  EDITOR=vim
fi

if [[ -n "$HAVE_NVIM" ]]; then
  EDITOR=nvim
fi

export EDITOR

# LESS
LESS="-FirSwX"
export LESS

# PAGER
if test -n "$(command -v less)" ; then
  PAGER="less $LESS"
  MANPAGER="less $LESS"
else
  PAGER=more
  MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# Ag: The Silver Searcher
alias ag="ag --hidden --path-to-ignore ~/.ignore"
alias agg="ag -Qs"

# Ripgrep
alias rg="rg -p --ignore-file ~/.ignore"
alias rgg="rg -Fs"

alias xclip="xclip -sel clip"

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREY}[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[[33;1m\] \[[0m[1m\]> "
}

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

test -z "$BASH_COMPLETION" && {
  bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
  test -n "$PS1" && test $bmajor -gt 1 && {
    # search for a bash_completion file to source
    for f in /usr/local/etc/bash_completion \
             /etc/bash_completion
      do
        if [ -f $f ]; then
          . $f
          break
        fi
      done
    }
  unset bash bmajor bminor
}

# override and disable tilde expansion
_expand() {
  return 0
}

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hB"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
  COLORS=/etc/DIR_COLORS
  test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
  test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
  test ! -e "$COLORS"               && COLORS=
  eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"

# --------------------------------------------------------------------
# PATH MANIPULATION FUNCTIONS
# --------------------------------------------------------------------

# Usage: pls [<var>]
# List path entries of PATH or environment variable <var>.
pls () { eval echo \$${1:-PATH} |tr : '\n'; }

# Usage: pshift [-n <num>] [<var>]
# Shift <num> entries off the front of PATH or environment var <var>.
# with the <var> option. Useful: pshift $(pwd)
pshift () {
  local n=1
  [ "$1" = "-n" ] && { n=$(( $2 + 1 )); shift 2; }
  eval "${1:-PATH}='$(pls |tail -n +$n |tr '\n' :)'"
}

# Usage: ppop [-n <num>] [<var>]
# Pop <num> entries off the end of PATH or environment variable <var>.
ppop () {
  local n=1 i=0
  [ "$1" = "-n" ] && { n=$2; shift 2; }
  while [ $i -lt $n ]
  do eval "${1:-PATH}='\${${1:-PATH}%:*}'"
    i=$(( i + 1 ))
  done
}

# Usage: prm <path> [<var>]
# Remove <path> from PATH or environment variable <var>.
prm () { eval "${2:-PATH}='$(pls $2 |grep -v "^$1\$" |tr '\n' :)'"; }

# Usage: punshift <path> [<var>]
# Shift <path> onto the beginning of PATH or environment variable <var>.
punshift () { eval "${2:-PATH}='$1:$(eval echo \$${2:-PATH})'"; }

# Usage: ppush <path> [<var>]
ppush () { eval "${2:-PATH}='$(eval echo \$${2:-PATH})':$1"; }

# Usage: puniq [<path>]
# Remove duplicate entries from a PATH style value while retaining
# the original order. Use PATH if no <path> is given.
#
# Example:
#   $ puniq /usr/bin:/usr/local/bin:/usr/bin
#   /usr/bin:/usr/local/bin
puniq () {
  echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
    cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

# bring in rbdev functions
# . rbdev 2>/dev/null || true

# source ~/.shenv now if it exists
# test -r ~/.shenv &&
# . ~/.shenv

#
# Homebrew on Linux
#
HOMEBREW_LINUX=no

if [[ -d ~/.linuxbrew ]]; then
  HOMEBREW_LINUX=yes
  eval $(~/.linuxbrew/bin/brew shellenv)
fi

if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  HOMEBREW_LINUX=yes
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if [[ "$HOMEBREW_LINUX" = "yes" ]]; then
  eval $($(brew --prefix)/bin/brew shellenv)
fi


# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
ppush "/usr/sbin"
ppush "/sbin"

punshift "/usr/local/sbin"
punshift "/usr/local/bin"

punshift "$HOME/bin"

# condense PATH entries
if [[ ${PATH+x} ]]; then
  export PATH=$(puniq $PATH)
fi

if [[ ${MANPATH+x} ]]; then
  export MANPATH=$(puniq $MANPATH)
fi

# Use the color prompt by default when interactive
test -n "$PS1" &&
prompt_color

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
  uname -npsr
  uptime
}

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# bundle exec
alias be='bundle exec'
alias bi='bundle install'

# git
alias gaa='git add -A'
alias gp='git push'
alias gco='git checkout'

# tmux aliases
alias tmux="TERM=screen-256color-bce tmux -2 -u"
alias t="tmux"
# alias tn='tmux new -s "$(basename `pwd`)" || tmux at -t "$(basename `pwd`)"'
alias ta='tmux attach'

# vim aliases
alias vim="nvim"

# go conveniences
# mkdir -p $HOME/go/src/github.com/patcoll
# export GOPATH=$HOME/go
# export PATH=$PATH:$GOPATH/bin

# if [[ "$UNAME" = Darwin ]]; then
#   GOBREWRAN=.gobrewran
#
#   gobrew () {
#     if [[ ! -f "$HOME/$GOBREWRAN" ]]; then
#       # Set gobrewran so this only happens once.
#       touch "$HOME/$GOBREWRAN"
#
#       # brew install gnu-tar
#       # brew install curl-openssl
#       # brew install wget
#       #
#       # brew install asdf
#       #
#       # brew install ack
#       # brew install the_silver_searcher
#       # brew install ripgrep
#       # brew install bat
#       # brew install fd
#       # brew install jq
#       #
#       # brew install git
#       # brew install tmux
#       # brew install vim
#       # brew install nvim
#       #
#       # brew install watchman
#       # brew install redis
#
#       # brew cask install textmate
#       #
#       # brew cask install postgres
#       # brew cask install postico
#       # brew cask install sequel-pro
#       # brew cask install tad
#       #
#       # brew cask install rowanj-gitx
#       # brew cask install spectacle
#       # brew cask install sublime-merge
#       #
#       # brew cask install 1password
#       # brew cask install docker
#       # brew cask install dropbox
#       # brew cask install firefox
#       # brew cask install google-chrome
#       # brew cask install iterm2
#       # brew cask install notion
#       # brew cask install spotify
#       #
#       # brew cask install slack
#       # brew cask install discord
#       # brew cask install telegram
#       #
#       # brew cask install fluid
#       # brew cask install istat-menus
#       # brew cask install jqbx
#       # brew cask install licecap
#       # brew cask install ngrok
#       # brew cask install rocket
#       # brew cask install sublime-merge
#       # brew cask install vlc
#       # brew cask install workflowy
#       # brew cask install zeplin
#     fi
#   }
#
#   # Install Homebrew if not found.
#   which brew >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#   # Install specified packages if it's never been done before.
#   which brew >/dev/null 2>&1 && gobrew
# fi

# if [[ "$(uname -a)" == *"Ubuntu"* ]]; then
#   sudo -n ls >/dev/null 2>&1
#   has_sudo=$?
#
#   GOAPTRAN=.goaptran
#
#   goapt () {
#     if [[ ! -f "$HOME/$GOAPTRAN" ]]; then
#       touch "$HOME/$GOAPTRAN"
#
#       sudo apt-get update -y
#       sudo apt-get install -y silversearcher-ag
#       sudo apt-get install -y vim
#       sudo apt-get install -y nvim
#     fi
#   }
#
#   if [[ "$has_sudo" == 0 ]]; then
#     goapt
#   fi
# fi

# The next line updates PATH for the Google Cloud SDK.
# [[ -s $HOME/google-cloud-sdk/path.bash.inc ]] && source "$HOME/google-cloud-sdk/path.bash.inc"

# The next line enables bash completion for gcloud.
# [[ -s $HOME/google-cloud-sdk/completion.bash.inc ]] && source "$HOME/google-cloud-sdk/completion.bash.inc"

# export JAVA_CMD=drip

#alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'

# export PATH="$HOME/.cabal/bin:$PATH"

punshift "$HOME/.cabal/bin"

# docker-osx-dev
#export DOCKER_HOST=tcp://localhost:2375

[ -f "$HOME/.git-completion.bash" ] && source $HOME/.git-completion.bash

# added by travis gem
# [ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ -d "$NVM_DIR" ]]; then
  NODE_DEFAULT_VERSION=$(<"$NVM_DIR/alias/default")
else
  NODE_DEFAULT_VERSION=""
fi

if [[ "$NODE_DEFAULT_VERSION" != "" ]]; then
  export PATH="$NVM_DIR/versions/node/$NODE_DEFAULT_VERSION/bin":$PATH
fi

# source /usr/local/opt/autoenv/activate.sh
[[ "$(which direnv 2> /dev/null)" != "" ]] && eval "$(direnv hook bash)"
[[ "$(which npm 2> /dev/null)" != "" ]] && eval "$(npm completion)"

# [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Add yarn bin folder
punshift "$HOME/.yarn/bin"

# Use curl from homebrew first.
punshift "/usr/local/opt/curl/bin"

# Use curl with updated openssl from homebrew first.
punshift "/usr/local/opt/curl-openssl/bin"

# For ChooseNim
punshift "$HOME/.nimble/bin"

ASDF_HOME=""

if [[ -d "$HOME/.asdf" ]]; then
  ASDF_HOME="$HOME/.asdf"
fi

if [[ -d "/opt/asdf-vm" ]]; then
  ASDF_HOME="/opt/asdf-vm"
fi

if [[ "${ASDF_HOME}" != "" ]]; then
  # Load asdf
  if [[ -f "${ASDF_HOME}/asdf.sh" ]]; then
    . "${ASDF_HOME}/asdf.sh"
  fi

  # Load asdf bash completion
  if [[ -f "${ASDF_HOME}/completions/asdf.bash" ]]; then
    . "${ASDF_HOME}/completions/asdf.bash"
  fi
fi

# tmux bash completion
[[ -s $HOME/bin/bash_completion_tmux.sh ]] && source $HOME/bin/bash_completion_tmux.sh

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
  POSTGRES_BIN="/Applications/Postgres.app/Contents/Versions/latest/bin"
  if [[ -d "$POSTGRES_BIN" ]]; then
    export PATH="$POSTGRES_BIN:$PATH"
  fi

  # Customize hide commands for kitty.app so we can use Cmd-H and Option-Cmd-H key commands.
  if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents >/dev/null 2>&1 | grep -q "Hide kitty"; then
    defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add "Hide kitty" '@~^$-'
  fi

  if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents >/dev/null 2>&1 | grep -q "Hide Others"; then
    defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add "Hide Others" '@~^$='
  fi
fi

if [[ -d "$HOME/.nix-profile" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi


[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

# added by travis gem
[ ! -s /home/pat/.travis/travis.sh ] || source /home/pat/.travis/travis.sh
