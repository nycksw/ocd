#!/usr/bin/env bash
# ocd-install.sh - Minimal script for initializing a bare Git repo in $HOME.
# <https://github.com/nycksw/ocd>

set -e

cat << 'END'
This will create a bare local repo for managing dotfiles (well, ANY files)
using your homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, this will clobber
your local versions. If you're not ready for that, you should ctrl-c your
way out of here.

For the remote repo, you will need its SSH key set up already.

Enter the Git remote URL for your dotfiles (e.g., git@github.com:USER/REPO.git).
END

while [[ -z "$OCD_REMOTE" ]]; do
  read -p "URL: " -r OCD_REMOTE
done

read -p "LAST WARNING: Anything in $OCD_REMOTE will clobber local versions. Are you sure? (y/N) " \
    -r CLOBBER_LOCAL && [ -z "$CLOBBER_LOCAL" ] && CLOBBER_LOCAL='n'

if [[ "$CLOBBER_LOCAL" =~ ^[nN] ]]; then
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

# Optional pre-commit safety hook.
read -p "Install a pre-commit hook to prevent accidental large commits? (Y/n) " \
    -r ADD_HOOK && [ -z "$ADD_HOOK" ] && ADD_HOOK='y'
if [[ "$ADD_HOOK" =~ ^[yY] ]]; then
  mkdir -p "$HOME/.ocd/hooks"
  HOOK="$HOME/.ocd/hooks/pre-commit"
  cat << 'END' > "$HOOK"
#!/usr/bin/env bash
MAX_ALLOWED=20
STAGED_COUNT=$(git diff --cached --name-only | wc -l)
if [[ "$STAGED_COUNT" -gt "$MAX_ALLOWED" ]]; then
  read -p "[!] You are about to commit $STAGED_COUNT files. Continue? (y/N) " ans
  [[ $ans =~ ^[yY] ]] || exit 1
fi
END
  chmod +x "$HOOK"
  echo "[*] Pre-commit hook installed: $HOOK"
fi

# Offer to fetch excludesFile from <gitignore.io>/Toptal.
read -p "Fetch a big excludesFile to prevent tracking secrets/junk? (Y/n) " \
    -r ADD_GITIGNORE && [ -z "$ADD_GITIGNORE" ] && ADD_GITIGNORE='y'
if [[ "$ADD_GITIGNORE" =~ ^[yY] ]]; then
  ALL_LISTS=$(curl -sL https://www.toptal.com/developers/gitignore/api/list | xargs | sed 's/ /,/g')
  IGNORE_FILE="$HOME/.gitignore_ocd"
  curl -sL "https://www.toptal.com/developers/gitignore/api/$ALL_LISTS" > "$IGNORE_FILE"
  $OCD config --local core.excludesFile "$IGNORE_FILE"
  ls -lh "$IGNORE_FILE"
  echo -e "\nTip: Use \"ocd check-ignore -v $IGNORE_FILE\" to troubleshoot matching rules."
fi

cat << END

[*] ALL DONE!

[!] Don't forget this in your .bashrc/.zsh/etc.:

  # Use "ocd" to manage dotfiles in \$HOME.
  alias ocd='git --git-dir=\$HOME/.ocd --work-tree=\$HOME'

  # Update .gitignore_ocd file.
  alias ocd-update-ignore='curl -sL "https://www.toptal.com/developers/gitignore/api/\$(curl -sL https://www.toptal.com/developers/gitignore/api/list | xargs | sed '\''s/ /,/g'\'')" > \$HOME/.gitignore_ocd'

After sourcing that you can just do "ocd add", "ocd commit", and so forth.

Save a one-liner like this to set everything up on other machines, AFTER
your SSH key is available on them; it's pretty close to a one-shot config:

  git clone --bare $OCD_REMOTE "\$HOME/.ocd" && \\
      alias ocd="git --git-dir="\$HOME/.ocd" --work-tree=\$HOME" && \\
      ocd config --local status.showUntrackedFiles no && \\
      ocd config --local core.excludesFile "\$HOME/.gitignore_ocd" && \\
      ocd pull && \\
      source "\$HOME/.bashrc"

END
