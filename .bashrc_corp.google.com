export PATH="$PATH:/home/build/static/projects/virgil:/home/build/google3/corp/ganeti/tools"
export P4DIFF="/home/build/public/google/tools/p4diff"
export P4MERGE="/home/build/public/eng/perforce/mergep4.tcl"
export P4EDITOR=/usr/bin/vim
alias p4.ops="cd $HOME/p4.ops && export P4CONFIG=$HOME/p4.ops/.p4config"
alias p4.0="cd $HOME/p4.0 && export P4CONFIG=$HOME/p4.0/.p4config"
alias p4.1="cd $HOME/p4.1 && export P4CONFIG=$HOME/p4.1/.p4config"

# goobuntu-updater last status
function guls {
  curl http://${1}:3901/varz?var=goobuntu_updater_laststatus
}
