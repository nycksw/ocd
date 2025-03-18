# OCD: Obsessively Curated Dotfiles

A simple dotfile management workflow using a bare Git repository stored in `$HOME/.ocd`, with `$HOME` itself as the Git work tree. No symlinks, wrappers, or extra dependencies—just Git.

The setup:

- Bare repository at `$HOME/.ocd`
- Alias `ocd` simplifies commands: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

Setting `showUntrackedFiles no` hides untracked files to avoid clutter. A custom `.gitignore_ocd` and a pre-commit hook protect against accidentally committing sensitive or unwanted files.

Deploying all your dotfiles to a new machine is a one-liner.

## Philosophy

- Dotfiles tracked directly in `$HOME`
- Git command simplified by `ocd` alias

To prevent accidental commits (e.g., ~~`ocd add .`~~):

- Comprehensive `.gitignore_ocd`
- Pre-commit hook warns if adding many files at once

## Installation

**Caution**: Using this with existing remote dotfiles will overwrite local files. Backup important files first.

To install, clone this repo, inspect the script, and run:

```bash
./ocd-install.sh
```

The install script:

- Prompts for your dotfile remote URL (GitHub, GitLab, etc.)
- Overwrites existing dotfiles in your home directory from your remote
- Accepts command-line arguments for automated deployment
- Installs a pre-commit hook to warn against committing many files
- Downloads an extensive `.gitignore_ocd` file (5059 rules) to avoid accidental commits. Override with `-f` if needed.

### Credits

Originally, "OCD" was my own minimal dotfile helper-script based on symlinks. Later, inspired by [StreakyCobra’s elegant suggestion](https://news.ycombinator.com/item?id=11071754) (2016!) and an [Atlassian write-up](https://www.atlassian.com/git/tutorials/dotfiles), it became simpler and cleaner—no more symlinks.

## Example

See [`example.md`](./example.md) for how `ocd-install.sh` looks in action.

## Notes and Alternatives

### System-specific configs

For machine-specific files, I source configs based on hostname/domain within `.bashrc`:

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

### Complexity vs. Other Tools

This method might seem unusual compared to [Stow](https://www.gnu.org/software/stow/), [dotbot](https://github.com/anishathalye/dotbot), or [chezmoi](https://www.chezmoi.io/). However, those tools add dependencies and code complexity. Once familiar, this Git-centric approach feels simpler and safer.

### Security Reminder

Always carefully review scripts fetched from the internet before executing them locally.
