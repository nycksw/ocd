# OCD Helpers. Source from .bashrc or similar.
# <https://github.com/nycksw/ocd>

export OCD_REMOTE="git@github.com:USER/dotfiles.git"
export OCD_HOME="$HOME"

# Main command for interacting with the local dotfile repo.
ocd () {
  # Remove leftover alias.
  unalias ocd 2&>/dev/null
  # Don't allow ocd commands inside another Git repo.
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Can't use 'ocd' while inside another Git repo." >&2
    return 1
  fi
  git --git-dir="$OCD_HOME/.ocd" --work-tree="$OCD_HOME" "$@"
}

# (Destructive!) Re-run OCD setup and fetch latest dotfiles from OCD_REMOTE.
alias ocd-install="curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" | bash -s -- -r "$OCD_REMOTE" -c -h -g"

# Create a tarball with tracked dotfiles only (no .git dir).
alias ocd-export='(f="$OCD_HOME/ocd-$(date +%Y%m%d).tar.gz" && \
                   cd "$OCD_HOME" && ocd ls-files -z | \
                   tar --null -T - -czvf $f; ls -lh $f)'

# (Destructive!) Write files from OCD to remote host.
# Usage: ocd-deploy user@hostname
ocd-deploy () {
  (cd ~ && ocd ls-files -z | tar --null -T - -cf - | ssh $1 'tar xvf - -C ~')
}

# Grab OCD dotfiles from a remote host to local work-tree and show changes.
# This won't run if there are local changes.
# Usage: ocd-yoink user@hostname
ocd-yoink () {
  if [[ -n "$(ocd status --porcelain)" ]]; then
    echo "[!] You have uncommitted changes. Stash or commit them first."
    return 1
  fi

  echo "[*] Pulling dotfiles from $1 into $OCD_HOME"
  echo

  ocd ls-files -z \
    | ssh "$1" 'cd ~ && xargs -0 tar -cf -' \
    | tar -xf - -C "$OCD_HOME"

  if [[ -z "$(ocd status --porcelain)" ]]; then
    echo "[*] No changes from $1."
    return 0
  fi

  ocd status
  echo
  echo "[!] CAREFULLY REVIEW ALL CHANGES."
  echo
  echo "[*] You can add/commit changes or use: ocd restore $OCD_HOME"
}

# Create a new Issue for OCD/dotfiles repo. Requires GitHub CLI.
alias ocd-issue='(cd ~/.ocd ; gh issue create --assignee @me)'

# vim: set ft=bash :
