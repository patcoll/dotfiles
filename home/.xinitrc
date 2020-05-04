#!/bin/sh

# invoke global X session script
. /etc/X11/Xsession

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

xbindkeys
