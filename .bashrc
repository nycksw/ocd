# ~eater/.bashrc
# http://eater.org/
#
# Global bash customizations. This should apply to ALL your systems.
#
# Use ~/.bashrc_<domain> or ~/.bashrc_<hostname> for local customizations.

mesg n
umask 027
shopt -s checkwinsize

# Non-interactive bail-out.
test -z "$PS1" && return

export EDITOR=vim
export HISTCONTROL=ignoredups
export HISTSIZE=4096
export PATH="~/bin:/bin:/sbin:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:"

# To enable ISO en_US for ANSI charsets:
#   sudo sh -c "echo en_US ISO-8859-1 > /var/lib/locales/supported.d/local"
#   sudo locale-gen
#export LANG=en_US
#export LANG=en_US.UTF-8

# Don't ignore leading dots when sorting.
export LC_COLLATE="C" 

test -f ~/.pythonrc.py && export PYTHONSTARTUP="$HOME/.pythonrc.py" \
                       && export PYTHONPATH="$HOME/py:$PYTHONPATH"

if [ "$TERM" != "dumb" ];then
  eval "`dircolors -b`"
  alias ls='ls --color=auto'
fi

if [ "$USER" = "root" ]; then
  alias vim="vim -u /home/$SUDO_USER/.vimrc"
  alias vi="vim"
fi

alias rc="source $HOME/.bashrc"
alias vi="vim"

SOURCE_FILES="
/etc/bash_completion
$HOME/.agentrc
$HOME/.bash_prompts
$HOME/.bashrc_$(hostname -f)
$HOME/.bashrc_$(dnsdomainname)
"
for file in $SOURCE_FILES;do test -f $file && . $file;done
