# Global bash customizations. Applies to ALL systems. Use
# ~/.bashrc_<domain> or ~/.bashrc_<hostname> for local customizations.

test -z "$PS1" && return  # Bail if not interactive.

mesg n
umask 027
shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion

export PATH=$PATH:~/bin

export EDITOR=vim
export HISTCONTROL=ignoredups
export HISTSIZE=4096

export LC_COLLATE="C"  # Don't ignore leading dots when sorting.

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
$HOME/.ocd_functions
"
for file in $SOURCE_FILES;do test -f $file && . $file;done
