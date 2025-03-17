#!/usr/bin/env bash
# ocd-install.sh - Minimal script for initializing a bare Git repo in $HOME.
# <https://github.com/nycksw/ocd>

set -e

# Optional environment variables:
#   OCD_REMOTE      = "git@github.com:USER/REPO.git"
#   OCD_CLOBBER   = "y" or "n"
#   OCD_HOOK        = "y" or "n"
#   OCD_GITIGNORE   = "y" or "n"
OCD_REMOTE=${OCD_REMOTE:-}
OCD_CLOBBER=${OCD_CLOBBER:-}
OCD_HOOK=${OCD_HOOK:-y}
OCD_GITIGNORE=${OCD_GITIGNORE:-y}

if [ -d "$HOME/.ocd" ]; then
  if [[ $OCD_CLOBBER =~ ^[yY] ]]; then
    OCD_BACKUP="$HOME/.ocd_backup_$(date +%s)"
    mv "$HOME/.ocd" "$OCD_BACKUP"
    echo "[!} $HOME/.ocd -> $OCD_BACKUP"
  else
    echo "$HOME/.ocd already exists."
    echo "Please move it out of the way first."
    exit 1
  fi
fi

cat << 'END'
This will create a bare local repo for managing dotfiles (well, ANY files)
using your homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, this will clobber
your local versions. If you're not ready for that, you should ctrl-c your
way out of here.

For the remote repo, you will need its SSH key set up already.

Enter the Git remote URL for your dotfiles (e.g., git@github.com:USER/REPO.git).
END

# Only prompt if OCD_REMOTE is not already set via the environment..
while [[ -z "$OCD_REMOTE" ]]; do
  read -p "URL: " -r OCD_REMOTE
done

# Only prompt if OCD_CLOBBER is not already set via the environment..
if [[ -z "$OCD_CLOBBER" ]]; then
  read -p "LAST WARNING: Anything in $OCD_REMOTE will clobber local versions. Are you sure? (y/N) " \
      -r OCD_CLOBBER
  [ -z "$OCD_CLOBBER" ] && OCD_CLOBBER='n'
fi

if [[ "$OCD_CLOBBER" =~ ^[nN] ]]; then
  echo "Exiting." && exit
fi

OCD="git --git-dir=$HOME/.ocd --work-tree=$HOME"

# Create local bare repo and set remote origin.
git clone --bare "$OCD_REMOTE" "$HOME/.ocd"

# Any new files in $HOME appear as unstaged unless you do this.
$OCD config --local status.showUntrackedFiles no

# Fetch existing files from remote, creating or OVERWRITING local ones.
$OCD reset --hard HEAD
$OCD checkout-index -f -a

# Optional pre-commit safety hook. Only prompt if OCD_HOOK not already set
# via the environment.
if [[ -z "$OCD_HOOK" ]]; then
  read -p "Install a pre-commit hook to prevent accidental large commits? (Y/n) " \
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
  echo -e "[!] You are about to commit $STAGED_COUNT files. Continue? (y/N) "
  read ans
  [[ "$ans" =~ ^[yY] ]] || exit 1
fi
END
  chmod +x "$HOOK"
  echo "[*] Pre-commit hook installed: $HOOK"
fi

# Offer to fetch excludesFile from <gitignore.io>/Toptal.
# Only prompt if OCD_GITIGNORE not already set.
if [[ -z "$OCD_GITIGNORE" ]]; then
  read -p "Fetch a big excludesFile to prevent tracking secrets/junk? (Y/n) " \
      -r OCD_GITIGNORE
  [ -z "$OCD_GITIGNORE" ] && OCD_GITIGNORE='y'
fi
if [[ "$OCD_GITIGNORE" =~ ^[yY] ]]; then
  IGNORE_FILE="$HOME/.gitignore_ocd"
  # Fetch every .gitignore list available and sed out the cpp-style comments
  # that shouldn't be in there.
  ALL_LISTS=$(curl -sL https://www.toptal.com/developers/gitignore/api/list | xargs | sed 's/ /,/g')
  curl -sL "https://www.toptal.com/developers/gitignore/api/$ALL_LISTS" \
      | sed 's/^ *[\*\\\/]*//g' | cat -s > "$IGNORE_FILE"
  $OCD config --local core.excludesFile "$IGNORE_FILE"
  ls -lh "$IGNORE_FILE"
  echo -e "\nTip: Use \"ocd check-ignore -v $IGNORE_FILE\" to troubleshoot matching rules."
fi

cat << END

[*] ALL DONE!

[!] Don't forget this in your .bashrc/.zsh/etc.:

  # Use "ocd" to manage dotfiles in \$HOME.
  alias ocd='git --git-dir=\$HOME/.ocd --work-tree=\$HOME'

After sourcing that you can just do "ocd add", "ocd commit", and so forth.

One-shot one-liner:

# [!] OCD_CLOBBER will overwrite files with versions from the repo.
export OCD_REMOTE="$OCD_REMOTE" OCD_CLOBBER="y" && \\
  curl -sL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \\
  | bash

END
