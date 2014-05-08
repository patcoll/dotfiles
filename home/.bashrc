# Enable history appending instead of overwriting.
shopt -s histappend

UNAMESTR=`uname`

# Set prompt.
export PS1="[\u@\h \W]\$ "

# grep with fixed strings. useful for finding variables in files.
tgrep () {
  str="$*"
  #for arg in $*; do str="$str $(printf '%q' $arg)"; done
  str="${str#"${str%%[![:space:]]*}"}"
  str="${str%"${str##*[![:space:]]}"}"
  echo "grep --color --fixed-strings --with-filename --line-number --recursive \"$str\" ."
        grep --color --fixed-strings --with-filename --line-number --recursive "$str" .
}

tgrepi () {
  str="$*"
  #for arg in $*; do str="$str $(printf '%q' $arg)"; done
  str="${str#"${str%%[![:space:]]*}"}"
  str="${str%"${str##*[![:space:]]}"}"
  echo "grep --ignore-case --color --fixed-strings --with-filename --line-number --recursive \"$str\" ."
        grep --ignore-case --color --fixed-strings --with-filename --line-number --recursive "$str" .
}

export EDITOR=vim

# java
if [[ "$UNAMESTR" == 'Darwin' ]]; then
  export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
fi

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

# Make sure /usr/local/bin is near the front of the line.
export PATH=$HOME/local/bin:$HOME/bin:/usr/local/share/npm/bin:/usr/local/bin:/usr/local/sbin:$PATH

alias tmux="TERM=screen-256color-bce tmux -2 -u"
alias t="tmux"

[[ -s $HOME/bin/bash_completion_tmux.sh ]] && source $HOME/bin/bash_completion_tmux.sh

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

ulimit -n 2048

export PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:$PATH"
