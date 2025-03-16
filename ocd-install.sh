#!/usr/bin/env bash
# ocd-install.sh - Setup script for minimalistic Git dotfile tracking.
# <https://github.com/nycksw/ocd>

set -e

usage() {
  echo "Usage: $0 [-r <REMOTE>] [-c] [-h] [-g]"
  echo
  echo "  -r <REMOTE>   Set remote repo URL (e.g., git@github.com:USER/REPO.git)."
  echo "  -c            Clobber local dotfiles with the remote version."
  echo "  -h            Install a pre-commit hook to prevent large commits."
  echo "  -g            Fetch a large excludesFile to ignore secrets/junk."
  echo
  echo "Examples:"
  echo "  $0 -r git@github.com:USER/REPO.git -c -h -g"
  exit 1
}

while getopts "r:chg" opt; do
  case $opt in
    r) OCD_REMOTE="$OPTARG";;
    c) OCD_CLOBBER='y';;
    h) OCD_HOOK='y';;
    g) OCD_GITIGNORE='y';;
    *) usage;;
  esac
done

fail_if_not_interactive() {
  if [ ! -t 0 ]; then
    echo "Non-interactive mode requires -r, -c, -h, and -g flags (no prompts)." >&2
    exit 1
  fi
}

if [ -d "$HOME/.ocd" ]; then
  if [[ $OCD_CLOBBER =~ ^[yY] ]]; then
    OCD_BACKUP="$HOME/.ocd_backup_$(date +%s)"
    mv "$HOME/.ocd" "$OCD_BACKUP"
    echo "[!] $HOME/.ocd -> $OCD_BACKUP"
  else
    echo "$HOME/.ocd already exists." >&2
    echo "Move or remove it before re-running, or use -c." >&2
    exit 1
  fi
fi

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

OCD="git --git-dir=$HOME/.ocd --work-tree=$HOME"

# Clone remote as a bare repo.
git clone --bare "$OCD_REMOTE" "$HOME/.ocd"
chmod 700 "$HOME/.ocd"

# Local untracked files remain hidden in Git status.
$OCD config --local status.showUntrackedFiles no

# Overwrite local files from remote HEAD.
$OCD reset --hard HEAD
$OCD checkout-index -f -a

echo -e "\n[*] $OCD_REMOTE cloned into $HOME/.ocd as a bare repo."

# Optional pre-commit hook.
if [[ -z "$OCD_HOOK" ]]; then
  fail_if_not_interactive
  read -p "Install pre-commit hook to prevent accidental commits? (Y/n): " \
    -r OCD_HOOK
  [ -z "$OCD_HOOK" ] && OCD_HOOK='y'
fi
if [[ "$OCD_HOOK" =~ ^[yY] ]]; then
  mkdir -p "$HOME/.ocd/hooks"
  HOOK="$HOME/.ocd/hooks/pre-commit"
  cat << 'END' > "$HOOK"
#!/usr/bin/env bash
exec < /dev/tty
exec > /dev/tty

MAX_ALLOWED=20
STAGED_COUNT=$(git diff --cached --name-only | wc -l)
if [[ "$STAGED_COUNT" -gt "$MAX_ALLOWED" ]]; then
  echo "[!] You are about to commit $STAGED_COUNT files. Continue? (y/N)"
  read ans
  [[ "$ans" =~ ^[yY] ]] || exit 1
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
  IGNORE_FILE="$HOME/.gitignore_ocd"
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
