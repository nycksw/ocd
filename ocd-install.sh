#!/usr/bin/env bash
# ocd-install.sh - Setup script for minimalistic Git dotfile tracking.
# <https://github.com/nycksw/ocd>

set -e

usage() {
  echo "Usage: $0 [-r <REMOTE>] [-c] [-h] [-g] [-H <OCD_HOME>] [-B <OCD_BARE>]"
  echo
  echo "  -r <REMOTE>    Set remote repo URL (e.g., git@github.com:USER/REPO.git)."
  echo "  -c             Clobber local dotfiles with the remote version."
  echo "  -h             Install a pre-commit hook to prevent large commits."
  echo "  -g             Fetch a large excludesFile to ignore secrets/junk."
  echo
  echo "  -H <OCD_HOME>  Working tree (default: \$HOME)."
  echo "  -B <OCD_BARE>  Bare repo dir (default: \$OCD_HOME/.ocd)."
  echo
  echo "Examples:"
  echo "  # Basic usage"
  echo "  $0 -r git@github.com:USER/REPO.git -c -h -g"
  echo
  echo "  # Custom home and bare repo directory"
  echo "  $0 -r git@github.com:USER/REPO.git -c -h -g -H /tmp/ocdtest -B /tmp/ocdtest/.ocd"
  exit 1
}

while getopts "r:H:B:chg" opt; do
  case "$opt" in
    r) OCD_REMOTE="$OPTARG" ;;
    H) OCD_HOME="$OPTARG"   ;;
    B) OCD_BARE="$OPTARG"   ;;
    c) OCD_CLOBBER='y'      ;;
    h) OCD_HOOK='y'         ;;
    g) OCD_GITIGNORE='y'    ;;
    *) usage                ;;
  esac
done

OCD_HOME="${OCD_HOME:-$HOME}"
OCD_BARE="${OCD_BARE:-$OCD_HOME/.ocd}"
SKIP_CLONE=n

fail_if_not_interactive() {
  if [ ! -t 0 ]; then
    echo "Non-interactive mode requires -r, -c, -h, and -g flags (no prompts)." >&2
    exit 1
  fi
}

if [ -d "$OCD_BARE" ]; then
  if [[ $OCD_CLOBBER =~ ^[yY] ]]; then
    OCD_BACKUP="${OCD_BARE}_backup_$(date +%s)"
    mv "$OCD_BARE" "$OCD_BACKUP"
    echo "[!] $OCD_BARE -> $OCD_BACKUP"
  else
    if [[ "$OCD_HOOK" =~ ^[yY] || "$OCD_GITIGNORE" =~ ^[yY] ]]; then
      SKIP_CLONE=y
    else
      echo "$OCD_BARE already exists." >&2
      echo "Move or remove it before re-running, or use -c, -h, or -g." >&2
      exit 1
    fi
  fi
fi

if [[ "$SKIP_CLONE" == n ]]; then
  cat << 'END'
This will create a bare local repo for managing dotfiles using your
homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, local versions
will be overwritten.

END

  # Prompt if OCD_REMOTE is missing
  while [[ -z "$OCD_REMOTE" ]]; do
    fail_if_not_interactive
    read -p "Enter Git remote URL (e.g., git@github.com:USER/REPO.git): " \
      -r OCD_REMOTE
  done

  # Prompt if OCD_CLOBBER isn't set.
  if [[ -z "$OCD_CLOBBER" ]]; then
    fail_if_not_interactive
    read -p "Overwrite local dotfiles with $OCD_REMOTE? (y/N): " -r OCD_CLOBBER
    [ -z "$OCD_CLOBBER" ] && OCD_CLOBBER='n'
  fi

  if [[ "$OCD_CLOBBER" =~ ^[nN] ]]; then
    echo "This setup overwrites any local dotfiles with those in your remote " \
        "repo. Exiting."
    exit
  else
    echo "OCD_CLOBBER='y' => local files may be overwritten."
    echo
  fi

  OCD="git --git-dir=$OCD_BARE --work-tree=$OCD_HOME"

  # Clone remote as a bare repo.
  git clone --bare "$OCD_REMOTE" "$OCD_BARE"
  chmod 700 "$OCD_BARE"

  # Local untracked files remain hidden in Git status.
  $OCD config --local status.showUntrackedFiles no

  # Overwrite local files from remote HEAD.
  $OCD reset --hard HEAD

  echo -e "\n[*] $OCD_REMOTE cloned into $OCD_BARE as a bare repo."
fi

# Optional pre-commit hook.
if [[ -z "$OCD_HOOK" ]]; then
  fail_if_not_interactive
  read -p "Install pre-commit hook to prevent accidental commits? (Y/n): " \
    -r OCD_HOOK
  [ -z "$OCD_HOOK" ] && OCD_HOOK='y'
fi
if [[ "$OCD_HOOK" =~ ^[yY] ]]; then
  mkdir -p "$OCD_BARE/hooks"
  HOOK="$OCD_BARE/hooks/pre-commit"
  cat << 'END' > "$HOOK"
#!/usr/bin/env bash
MAX_ALLOWED=20
STAGED_COUNT=$(git diff --cached --name-only | wc -l)
WORK_TREE=$(git rev-parse --work-tree)
if [[ "$STAGED_COUNT" -gt "$MAX_ALLOWED" ]]; then
  echo "[!] You are about to commit $STAGED_COUNT files from: $WORK_TREE"
  echo "If you really want to do this, use '--no-verify'."
  exit 1
fi
END
  chmod +x "$HOOK"
  echo "[*] Pre-commit hook installed at: $HOOK"
fi

# Optional excludesFile.
if [[ -z "$OCD_GITIGNORE" ]]; then
  fail_if_not_interactive
  read -p "Fetch a big excludesFile to ignore secrets/junk? (Y/n): " \
    -r OCD_GITIGNORE
  [ -z "$OCD_GITIGNORE" ] && OCD_GITIGNORE='y'
fi
if [[ "$OCD_GITIGNORE" =~ ^[yY] ]]; then
  IGNORE_FILE="$OCD_HOME/.gitignore_ocd"
  ALL_LISTS=$(curl -sL https://www.toptal.com/developers/gitignore/api/list \
    | xargs | sed 's/ /,/g')
  curl -fsSL "https://www.toptal.com/developers/gitignore/api/$ALL_LISTS" \
    | sed 's/^ *[\*\\\/]*//g' | cat -s > "$IGNORE_FILE"
  $OCD config --local core.excludesFile "$IGNORE_FILE"
  ls -lh "$IGNORE_FILE"
  echo -e "\nTip: Use \"ocd check-ignore -v \$(basename \"$IGNORE_FILE\")\" " \
          "to troubleshoot matching rules."
fi

cat << END

[*] All done!

Add an alias in your shell rc:

  alias ocd='git --git-dir=\$HOME/.ocd --work-tree=\$HOME'

Then "ocd add", "ocd commit", etc.

One-liner for new machine setup:

curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \\
  | bash -s -- -r "$OCD_REMOTE" -c -h -g

END
