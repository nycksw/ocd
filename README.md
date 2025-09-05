# OCD: Obsessively Curated Dotfiles

Manage dotfiles using a bare Git repository in `$HOME/.ocd` with `$HOME` as the work tree. No symlinks, wrappers, or extra dependencies. Just Git.

Here's the basic idea, it's very simple:
```shell
alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'
ocd init
ocd config --local status.showUntrackedFiles no
ocd add .bashrc  # Then ocd commit, push, pull, etc.
```

Use [`ocd-install.sh`](ocd-install.sh) to do the same kind of setup but with a comprehensive [gitignore](generate-gitignore.sh) file and a pre-commit hook to make sure you don't do anything dumb, like check in your private keys or accidentally `commit` your entire homedir.

## Installation

This assumes you already have a dotfiles repository URL to pass as an argument.

**Warning**: This overwrites local files with your remote repository contents.

Review [`ocd-install.sh`](ocd-install.sh) (it's very short) and then use it like this:
```shell
curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r git@github.com:YOUR_USERNAME/YOUR_REPO.git -c -h -g
```

You'll need an alias in your `.bashrc` (or `.zshrc`, etc.), something like this:
```shell
alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'
```

Then just use it like you would Git, but from any directory:
```shell
ocd status
ocd add ~/.bashrc
ocd commit -m 'Update bashrc'
ocd push
```

## Installation Options

### Automated Setup
```shell
./ocd-install.sh -r <YOUR_REPO> -c -h -g
```

### Interactive Setup
```shell
./ocd-install.sh
```

The installer can:
- Clone your remote dotfiles repository
- Install a pre-commit hook to prevent large commits
- Download a comprehensive `.gitignore_ocd` file

## Advanced Usage

### System-Specific Configs

I keep it simple and just source different configs per machine/domain/lsb-release/whatever in `.bashrc`, something like this:
```shell
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)"; do
  [[ -f "${FILE}" ]] && source "${FILE}"
done
```

That way you can put your generic shell config in `.bashrc` and separate your environment-specific tweaks into files that only get sourced under the correct circumstances.

Or, you can keep customized branches and `rebase`/`merge` them onto/into `main` when needed. It's just Git with your own personal reposistory, so you can `push --force-with-lease` and live on the edge if you want. Or, whatever, use it however you like to use Git.

### Helper Functions

See [helpers.sh](./helpers.sh) for random stuff like:
- `ocd-deploy` - Push dotfiles to remote hosts
- `ocd-export` - Create tarball archives
- `ocd-yoink` - Pull changes from remote hosts

### Example Output

See [example.md](./example.md) for installation walkthrough.

## Why Not Stow/dotbot/chezmoi?

Those tools add dependencies and complexity. This approach uses only Git. It's simpler, more portable, and you already know how to use it.

Critics of this approach usually say something like, "But you might accidentally commit secrets or even YoUr wHoLe hOmE dIreCtoRy!" Well, that's why I added the world's biggest gitignore file to flag secrets and the pre-commit hook to flag humongous commits. In practice I found those scenarios to be pretty rare, anyway. Occasionally I get a false-positive from the ignore file and have to `-f` it, but that's really it.

If you are familiar with Git it all feels very natural and those safeguards make it pretty hard to screw things up.

## Security

Always review [scripts](ocd-install.sh) before running them. Consider forking/cloning this repository and using your own copy.

## Credits

Inspired by this very old [HN suggestion](https://news.ycombinator.com/item?id=11071754) for bare Git repository dotfile management.
