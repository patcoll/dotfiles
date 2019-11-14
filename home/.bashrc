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
# PATH
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/sbin:/sbin"
PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" &&
PATH="$HOME/bin:$PATH"

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

# EDITOR
test -n "$HAVE_VIM" &&
EDITOR=vim ||
EDITOR=vi
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

# Ack
ACK_PAGER="$PAGER"
ACK_PAGER_COLOR="$PAGER"

# Ag: The Silver Searcher
alias ag="ag --path-to-ignore ~/.ignore --pager=\"$PAGER\""
# Only for when we're really sold on ag ;)
# alias ack="ag --pager=\"$PAGER\""

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
elif hostname | grep -q 'github\.com'; then
    GITHUB=yep
    COLOR1="\[\e[0;94m\]"
    COLOR2="\[\e[0;92m\]"
    P="\$"
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
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    # setup java environment. puke.
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"

    # hold jruby's hand
    test -d /opt/jruby &&
    export JRUBY_HOME="/opt/jruby"
fi

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
. rbdev 2>/dev/null || true

# bundle exec
alias be='bundle exec'
alias bi='bundle install'

# git
alias gp='git push'
alias gco='git checkout'

# source ~/.shenv now if it exists
test -r ~/.shenv &&
. ~/.shenv

# condense PATH entries
PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

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

# beep
alias beep='tput bel'

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

alias cd..="cd .."

# tmux aliases
alias tmux="TERM=screen-256color-bce tmux -2 -u"
alias t="tmux"

# disk usage with human sizes and minimal depth
alias du1='du -h --max-depth=1'
alias fn='find . -name'
alias hi='history | tail -20'

if command -v tmux >/dev/null ; then
  alias tn='tmux new -s "$(basename `pwd`)" || tmux at -t "$(basename `pwd`)"'
  alias ta='tmux attach'
fi

alias bek='bundle exec kitchen'
alias bekl='bundle exec kitchen list'
alias bekc='bundle exec kitchen converge'
alias beks='bundle exec kitchen setup'
alias bekv='bundle exec kitchen verify'
alias bekd='bundle exec kitchen destroy'
alias bekt='bundle exec kitchen test'

alias kl='kitchen list'
alias kc='kitchen converge'
alias ks='kitchen setup'
alias kv='kitchen verify'
alias kd='kitchen destroy'
alias kt='kitchen test'

# alias dc='docker-compose'
# alias dm='docker-machine'

# grep with fixed strings. useful for finding variables in files.
# tgrep () {
#   ack $@
# }
#
# tgrepi () {
#   ack -i $@
# }

# ec2 cert and private key setup
if [[ -d $HOME/.ec2 ]]; then
  export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
  export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
fi

# ec2-api-tools setup
if [[ -d /usr/local/Cellar/ec2-api-tools ]]; then
  export EC2_HOME="$(/bin/ls -d /usr/local/Cellar/ec2-api-tools/*/jars)"
fi

# load ec2 configuration.
# this is where we'd export the EC2_ACCESS_KEY and EC2_SECRET_KEY variables.
[[ -s $HOME/.ec2rc ]] && source $HOME/.ec2rc

[[ -s $HOME/bin/bash_completion_tmux.sh ]] && source $HOME/bin/bash_completion_tmux.sh

#export CLICOLOR=1
#export LSCOLORS=GxFxCxDxBxegedabagaced

### Added by the Heroku Toolbelt
#if [[ -d /usr/local/heroku/bin ]]; then
  #export PATH="/usr/local/heroku/bin:$PATH"
#fi

# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#ulimit -n 2048

if [[ -d /Applications/Postgres.app/Contents/Versions/latest/bin ]]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"
fi

# vim: ts=4 sts=4 shiftwidth=4 expandtab

# go conveniences
mkdir -p $HOME/go/src/github.com/patcoll
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# pyenv
#if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# virtualenv
#eval "$(pyenv virtualenv-init -)"

# if [[ "$UNAME" = Darwin ]]; then
#   GOBREWRAN=.gobrewran
#
#   gobrew () {
#     if [[ ! -f "$HOME/$GOBREWRAN" ]]; then
#       # Set gobrewran so this only happens once.
#       touch "$HOME/$GOBREWRAN"
#
#       brew install gnu-tar
#
#       brew install nvm
#       brew install rbenv
#       brew install rbenv-gemset
#
#       brew tap caskroom/cask
#       # brew cask install postgres
#       brew cask install rowanj-gitx
#     fi
#   }
#
#   # Install Homebrew if not found.
#   which brew >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#   # Install specified packages if it's never been done before.
#   which brew >/dev/null 2>&1 && gobrew
# fi

if [[ "$(uname -a)" == *"Ubuntu"* ]]; then
  sudo -n ls >/dev/null 2>&1
  has_sudo=$?
  goapt () {
    sudo aptitude update -y
    sudo aptitude install -y ack-grep
    sudo aptitude install -y silversearcher-ag
    sudo dpkg-divert --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep
    sudo aptitude install -y vim
  }

  GOAPTRAN=.goaptran
  if [[ "$has_sudo" == 0 ]] && [[ ! -f "$HOME/$GOAPTRAN" ]]; then
    goapt && touch "$HOME/$GOAPTRAN"
  fi
fi

# The next line updates PATH for the Google Cloud SDK.
[[ -s $HOME/google-cloud-sdk/path.bash.inc ]] && source "$HOME/google-cloud-sdk/path.bash.inc"

# The next line enables bash completion for gcloud.
[[ -s $HOME/google-cloud-sdk/completion.bash.inc ]] && source "$HOME/google-cloud-sdk/completion.bash.inc"

# export JAVA_CMD=drip

#alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'

export PATH="$HOME/.cabal/bin:$PATH"

# docker-osx-dev
#export DOCKER_HOST=tcp://localhost:2375

[ -f "$HOME/.git-completion.bash" ] && source $HOME/.git-completion.bash

# added by travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

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
[[ "$(which direnv)" != "" ]] && eval "$(direnv hook bash)"
[[ "$(which npm)" != "" ]] && eval "$(npm completion)"

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias chrome-canary="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary"
alias chromium="/Applications/Chromium.app/Contents/MacOS/Chromium"

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="/usr/local/opt/php@7.1/bin:$PATH"

# Use curl from homebrew first.
export PATH="/usr/local/opt/curl/bin:$PATH"

# Use curl with updated openssl from homebrew first.
export PATH="/usr/local/opt/curl-openssl/bin:$PATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"


. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash
