# OCD: Obsessively Curated Dotfiles

Manage dotfiles using a bare Git repository in `$HOME/.ocd` with `$HOME` as the work tree. No symlinks, wrappers, or extra dependencies. Just Git.

TL;DR:
- `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`
- `ocd init`
- `ocd config --local status.showUntrackedFiles no`
- `ocd add .bashrc  # Then ocd commit, push, pull, etc.`

See `ocd-install.sh` for a more comprehensive approach to do the same thing.

## Quick Start

**Warning**: This overwrites local files with your remote repository contents.

```bash
# Replace with your Git dotfile repository
curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r git@github.com:nycksw/dotfiles.git -c -h -g

# Add to ~/.bashrc or ~/.zshrc
alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

# Use like regular git
ocd status
ocd add ~/.bashrc
ocd commit -m 'Update bashrc'
ocd push
```

## Installation Options

### Automated Setup
```bash
./ocd-install.sh -r <YOUR_REPO> -c -h -g
```

### Interactive Setup
```bash
./ocd-install.sh
```

The installer can:
- Clone your remote dotfiles repository
- Install a pre-commit hook to prevent large commits
- Download a comprehensive `.gitignore_ocd` file

## Advanced Usage

### System-Specific Configs

Source different configs per machine in `.bashrc`:
```bash
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)"; do
  [[ -f "${FILE}" ]] && source "${FILE}"
done
```

### Helper Functions

See [helpers.sh](./helpers.sh) for utilities like:
- `ocd-deploy` - Push dotfiles to remote hosts
- `ocd-export` - Create tarball archives
- `ocd-yoink` - Pull changes from remote hosts

### Example Output

See [example.md](./example.md) for installation walkthrough.

## Why Not Stow/dotbot/chezmoi?

Those tools add dependencies and complexity. This approach uses only Git. It's simpler and more portable.

## Security

Always review scripts before running them. Consider forking/cloning this repository and using your own copy.

## Credits

Inspired by this very old [HN suggestion](https://news.ycombinator.com/item?id=11071754) for bare Git repository dotfile management.
