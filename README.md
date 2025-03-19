# OCD: Obsessively Curated Dotfiles

A simple dotfile management workflow using a bare Git repository stored in `$HOME/.ocd`, with `$HOME` itself as the Git work tree. No symlinks, wrappers, or extra dependencies—just Git.

The setup:

- Bare repository at `$HOME/.ocd`
- Alias `ocd` simplifies commands: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

Setting `showUntrackedFiles no` hides untracked files to avoid clutter. A custom `.gitignore_ocd` and a pre-commit hook protect against accidentally committing sensitive or unwanted files.

Deploying all your dotfiles to a new machine is a one-liner.

## Basic Idea

- Dotfiles tracked directly in `$HOME`
- Git command simplified by `ocd` alias: `git --git-dir=$HOME/.ocd --work-tree=$HOME`

To prevent accidental commits (e.g., ~~`ocd add .`~~):

- Comprehensive `.gitignore_ocd`
- Pre-commit hook warns if adding many files at once

## Installation

**Caution**: Using this with existing remote dotfiles will overwrite local files. Backup important files first.

To install, clone this repo, **inspect the script**, and run:

```bash
./ocd-install.sh
```

The install script:

- Prompts for your dotfile remote URL (GitHub, GitLab, etc.)
- Overwrites existing dotfiles in your home directory from your remote
- Accepts command-line arguments for automated deployment
- Installs a pre-commit hook to warn against committing many files
- Downloads an extensive `.gitignore_ocd` file (thousands of rules) to avoid accidental commits. Override with `-f` if needed.

### Example

See [`example.md`](./example.md) for how `ocd-install.sh` looks in action.

### OCD Aliases

The main alias you need: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

Here are a few others you might find handy:

```
# Set Git remote repo for dotfiles.
export OCD_REMOTE="git@github.com:USER/dotfiles.git"

# Main command for interacting with the local dotfile repo.
alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

# Create a tarball with tracked dotfiles only (no .git dir).
alias ocd-export='( f="$HOME/ocd-$(date +%Y%m%d).tar.gz" && cd "$HOME" && ocd ls-files -z | tar --null -T - -czvf $f; ls -l $f )'

# (Destructive) Re-run OCD setup and fetch latest dotfiles from OCD_REMOTE.
alias ocd-install="curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" | bash -s -- -r "$OCD_REMOTE" -c -h -g"

# Create a new Issue for OCD/dotfiles repo. Requires GitHub CLI.
alias ocd-issue='(cd ~/.ocd ; gh issue create --assignee @me)'
```

### System-specific configs

To use one set of dotfiles for all my machines, I source configs based on hostname/domain within `.bashrc`:

```bash
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)"; do
  [[ -f "${FILE}" ]] && source "${FILE}"
done
```

This avoids branching and templating complexity.

### Using Branches

If preferred, you can still manage different systems using branches. Adjust the `ocd` alias or workflow as needed.

## Complexity vs. Other Tools

This method might seem unusual compared to [Stow](https://www.gnu.org/software/stow/), [dotbot](https://github.com/anishathalye/dotbot), or [chezmoi](https://www.chezmoi.io/). However, those tools add dependencies and code complexity. Once familiar, this Git-centric approach feels simpler and safer.

## Security Reminder

Always carefully review scripts fetched from the internet before executing them locally. You should probably fork this repo and use your version after you've reviewed it.

## Credits

Originally, "OCD" was my own minimal dotfile helper-script based on symlinks. More recently, I found this [elegant (and very old) suggestion](https://news.ycombinator.com/item?id=11071754), and so my workflow became simpler and cleaner—no more symlinks. I wish I had done this years ago!
