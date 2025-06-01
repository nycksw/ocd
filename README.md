# OCD: Obsessively Curated Dotfiles

A simple workflow using a bare Git repository in `$HOME/.ocd` and `$HOME` itself as the Git work tree.

No symlinks, wrappers, or extra dependencies. Just Git.

- Dotfiles tracked directly in `$HOME` (no symlink farming)
- `ocd` alias is just `git --git-dir=$HOME/.ocd --work-tree=$HOME`
- Deploying all your dotfiles to a new machine is a one-liner.

Optionally, you can install:

- A comprehensive `.gitignore_ocd` file to filter secrets and junk files.
- A pre-commit hook warns about too many files being committed at once.

## Installation

**Caution**: This may overwrite local files with whatever's in your remote repository.

### TL;DR Example

```bash
# Set the repository that has your dotfiles.
$ export OCD_REMOTE=git@github.com:nycksw/dotfiles.git

# Verify access.
$ git ls-remote "$OCD_REMOTE"
d27b61295bd9ffe1f01c9a1004b800350846b98f        HEAD
d27b61295bd9ffe1f01c9a1004b800350846b98f        refs/heads/main

# Install everything.
$ curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r "$OCD_REMOTE" -c -h -g

# Set the ocd alias.
$ alias ocd='git --git-dir=\$HOME/.ocd --work-tree=\$HOME'

$ echo '# Be the change you want to see in the world' >> ~/.bashrc

$ ocd status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .bashrc

no changes added to commit (use "git add" and/or "git commit -a")

$ ocd commit -a -m 'Testing OCD for README.md'
[main b1d26eb] Testing OCD for README.md
 1 file changed, 1 insertion(+)

$ ocd push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 344 bytes | 344.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:nycksw/dotfiles.git
   4db3f5c..b1d26eb  main -> main
```

When you're comfortable with how this works, setting up a new machine is just a one-liner:

```bash
$ curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r git@github.com:nycksw/dotfiles.git -c -h -g
```

### Interactive Setup

Clone (or fork) this repo, **inspect the script**, and run:

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

### Helpful Aliases and Functions

The main alias you need: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

See [helpers.sh](./helpers.sh) for some handy utilities, including:
- A better `ocd` function to use instead of the alias above.
- Pushing all dotfiles to a remote host.
- Create a `.tar.gz` archive with all dotfiles.
- Yoink changes from a remote host for review/add/commit.
- Create a GitHub issue in your dotfiles repo for tracking TODOs.

### System-specific configs

To use one set of dotfiles for all my machines, I source configs based on hostname/domain within `.bashrc`:

```bash
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)"; do
  [[ -f "${FILE}" ]] && source "${FILE}"
done
```

This avoids the need for branching and templating.

### Using Branches

If preferred, you can still manage different systems using branches. Adjust the `ocd` alias or workflow as needed. It's just Git.

## Complexity vs. Other Tools

This method might seem unusual compared to [Stow](https://www.gnu.org/software/stow/), [dotbot](https://github.com/anishathalye/dotbot), or [chezmoi](https://www.chezmoi.io/). However, those tools add dependencies and code complexity. Once familiar, this Git-centric approach feels simpler and safer.

## Security Reminder

Always carefully review scripts fetched from the internet before executing them locally. You should probably fork this repo and use your version after you've reviewed it.

## Credits

Originally, "OCD" was my dotfile helper-script based on symlinks. Then I found this [elegant (and very old) suggestion](https://news.ycombinator.com/item?id=11071754), and so my workflow became simpler and cleaner—no more symlinks. I wish I had done this years ago!
