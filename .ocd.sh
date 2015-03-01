# OCD: Obesssive Compulsive Directory
# See https://github.com/obeyeater/ocd/blob/master/ for detailed information.
#
# Functions and usage:
#   ocd-restore:        pull from git master and copy files to homedir
#   ocd-backup:         push local changes to master
#   ocd-status:         check if OK or Behind
#   ocd-missing-debs:   compare system against $HOME/.favdebs and report missing
#   ocd-extra-debs:     compare system against $HOME/.favdebs and report extras

OCD_IGNORE_RE="^\./(README|\.git/)"
OCD_INSTALL_FROM="git@github.com:obeyeater/ocd.git"
OCD_DIR="$HOME/.ocd"

ocd::err()  { echo "ocd(ERROR): $@" >&2; }
ocd::warn() { echo "ocd(WARNING): $@"; }

ocd::yn() {
  echo -n "$@ (yes/no): "
  while true; do
    read ANS
    if [[ $ANS == "yes" ]];then
      return 0
    elif [[ $ANS == "no" ]];then
      return 1
    else
      echo -n "$@ (yes/no): "
    fi
  done
}

ocd-restore() {
  if [[ ! -d "$OCD_DIR" ]]; then
    echo "$OCD_DIR: doesn't exist!" && continue
  fi
  pushd $OCD_DIR >/dev/null
  echo "ocd: git-pull:"
  git pull || {
    ocd::err  "error: couldn't git-pull; check status in $OCD_DIR"
    popd >/dev/null
    return 1
  }

  files=$(find . -type f | egrep -v  "$OCD_IGNORE_RE")
  dirs=$(find . -type d | egrep -v  "$OCD_IGNORE_RE")

  for dir in $dirs; do
    mkdir -p $HOME/$dir
  done

  echo -n "ocd: restoring"
  for file in $files; do
    echo -n .
    src="$file"
    dst="$HOME/$file"
    if [[ -f $dst ]]; then
      rm -f $dst
    fi
    ln $file $dst
  done
  echo

  # Some changes require cleanup that OCD won't handle; e.g., if you rename
  # a file the old file will remain. Housekeeping commands that need to be
  # run may be put in $OCD_DIR/.ocd_cleanup; they run only once.
  if ! cmp $HOME/.ocd_cleanup{,_ran} &>/dev/null; then
    echo -e "ocd: running $HOME/.ocd_cleanup:"
    $HOME/.ocd_cleanup && cp $HOME/.ocd_cleanup{,_ran}
  fi
  popd >/dev/null
}

ocd-backup() {
  pushd $OCD_DIR >/dev/null
  echo -e "git status in `pwd`:\n"
  git status
  if ! git status | grep -q "working directory clean"; then
    git diff
    if ocd::yn "Commit and push now?"; then
      git commit -a
      git push
    fi
  fi
  popd >/dev/null
}

ocd-status() {
  pushd $OCD_DIR >/dev/null
  git remote update &>/dev/null
  if git status -uno | grep -q behind; then
    echo "Behind"
    popd >/dev/null && return 1
  else
    echo "OK"
    popd >/dev/null && return 0
  fi
  echo "Error"
  popd >/dev/null && return 1
}

ocd-missing-debs() {
  [ -f $HOME/.favdebs ] || touch $HOME/.favdebs
  dpkg --get-selections | grep '\sinstall$' | awk '{print $1}' | sort \
      | comm -13 - <(egrep -v '(^-|^ *#)' $HOME/.favdebs \
      | sed 's/ *#.*$//' |sort)
}

ocd-extra-debs() {
  [ -f $HOME/.favdebs ] || touch $HOME/.favdebs
  dpkg --get-selections | grep '\sinstall$' | awk '{print $1}' | sort \
      | comm -12 - <(grep -v '^ *#' $HOME/.favdebs | grep '^-' | cut -b2- \
      | sed 's/ *#.*$//' |sort)
}

ocd-add() {
  if [[ ! -f "$1" ]];then
    echo "Usage: ocd-add <filename>"
    return 1
  fi
  base=$(basename $1)
  abspath=$(cd "`dirname $1`";pwd)
  relpath=${abspath/#$HOME\//}
  echo $relpath
  echo "${HOME}/${relpath}/$base != ${abspath}/${base}"
  if [[ "${HOME}/${relpath}/$base" != "${abspath}/${base}" ]]; then
    echo "$1 is not in $HOME"
    return 1
  fi
  mkdir -p ${OCD_DIR}/${relpath}
  ln -f ${HOME}/${relpath}/${base} $OCD_DIR/${relpath}/${base}
  pushd $OCD_DIR >/dev/null
  git add ${relpath}/${base} && echo "Added: $1"
  popd >/dev/null
}

# TODO: finish this
#ocd-rm() {
#  if [ ! -f "$1" ];then
#    echo "Usage: ocd-rm <filename>"
#    return 1
#  fi
#  # Must:
#  # 1. make sure arg isn't in $HOME/.ocd
#  # 2. git rm relative <file> from $HOME/.ocd (leave original in $HOME)
#  # 3. clean up empty dirs in $HOME/.ocd?
#}

# Check if installed. If not, fix it.
if [[ ! -d "$OCD_DIR/.git" ]]; then

  # Have SSH ID set up for the rw git repository.
  get_idents() { ssh-add -l 2>/dev/null |awk '{print $3}' |sort |xargs; }
  idents="$(get_idents)"
  echo "ocd: not installed!"
  [ -z "$idents" ] && ssh-add 2>/dev/null
  if [[ -z "$(get_idents)" ]]; then
    if ocd::yn "No SSH IDs! Copy them from another host?"; then
      echo -n "Enter user@hostname: "
      read SRC
      mkdir -p $HOME/.ssh
      scp ${SRC}:.ssh/id\* .ssh/
      echo "Done copying SSH IDs from ${SRC}"
      ssh-agent > .ssh/agent.$(hostname)
      source .ssh/agent.$(hostname) 2>/dev/null
      ssh-add
      if [[ -z "$(get_idents)" ]]; then
        ocd::err "Still no SSH IDs; something went wrong :("
        return 1
      fi
    else
      return 1
    fi
  fi

  # Fetch the repository.
  if ocd::yn "Fetch from git repository \"$OCD_INSTALL_FROM?\""; then
    echo "Checking for git..."
    which git || sudo apt-get install git-core
    if git clone $OCD_INSTALL_FROM "$HOME/.ocd"; then
      if ! cmp "$HOME/.ocd.sh" "$HOME/.ocd/.ocd.sh"; then
        cp "$HOME/.ocd.sh" "$HOME/.ocd/.ocd.sh"
        cp "$HOME/.ocd/.gitconfig" "$HOME/.gitconfig"
        echo "Done! to finish, run ocd-backup to push changes, then: ocd-restore && source .bashrc"
      else
        echo "Done! to finish, run: ocd-restore && source .bashrc"
      fi
    fi
  fi
fi
