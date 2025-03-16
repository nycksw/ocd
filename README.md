# OCD: Obsessively Curated Dotfiles

A Git-backed dotfile management workflow with minimal complexity by using a bare local repository and `$HOME` as the [work tree](https://git-scm.com/docs/git-worktree). By setting `showUntrackedFiles no`, you only see purposefully staged files for commits. Managing changes is easy, and setting up a new shell only takes a few seconds. It avoids the usual tangle of symlinks. It requires no extra code.

Clone this repo and run,

```
./ocd-install.sh`
```

Or do it in one shot:

```
curl -sL https://raw.githubusercontent.com/luser/ocd/main/ocd-install.sh" | bash
```

### My Tale

For more than 20 years I maintained a little pet script that did the usual symlink-farm approach, because I felt like [every other option](https://dotfiles.github.io/utilities/) was too much extra code and complexity. Then I found this minimal and elegant suggestion in [an old comment](https://news.ycombinator.com/item?id=11071754) by [StreakyCobra](https://github.com/StreakyCobra). Atlassian did a nice [write-up](https://www.atlassian.com/git/tutorials/dotfiles) about it, too. So, I said goodbye to my trusty little 20 year old pet 💔.

Below, I'll explain a very slightly more detailed approach to make this work, and how to use the `ocd-install.sh` script I wrote.

## Philosophy

- Store dotfiles in `~/.ocd` (a bare repo).
- Work directly in `$HOME` with `ocd` as the Git command alias. (`git --git-dir=$HOME/.ocd --work-tree=$HOME`)
- Use an extensive `.gitignore_ocd` so you don’t accidentally commit secrets or random junk.
- Keep everything simple—no thousands of lines of code or complicated scripts.

## Basic Idea

If you want to do this by hand, it's something like this:

1. **Create or pick a GitHub repo** for your dotfiles. Make sure your SSH keys are set up for the remote side.

2. **Clone it as a bare repo** in your `$HOME`. Like:

```bash
git clone --bare git@github.com:USER/dotfiles.git $HOME/.ocd
git --git-dir=$HOME/.ocd --work-tree=$HOME config --local status.showUntrackedFiles no
```

3. **Add an alias** like `ocd` to your shell environment (e.g. `.bashrc`):

```bash
alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'
```

4. **Start versioning**:

```bash
ocd status
ocd add .bashrc
ocd commit -m "Add .bashrc"
ocd push origin main
```

## Automated First-Time Setup

The `ocd-install.sh` script will ask for your existing remote repo URL (GitHub or otherwise) that will have your dotfiles. If you already have one with dotfiles in it, that's OK as long as the files are at the root of the repo. If you already have files in it, **this setup will overwrite your local versions**!

The script will also offer a pre-commit hook to make sure you don't accidentally add your entire home directory by flagging commits with more than 20 files.

Finally, it will also offer to download a massive `excludesFile` ("`.gitignore_ocd`") file to keep you from accidentally checking in secrets and other junk files. At the time of this writing it has 8421 rules in it. You can always overide a bad match with `-f`.

### Example

Running the script looks something like this:

```console
$ ./ocd-install.sh
This will create a bare local repo for managing dotfiles (well, ANY files)
using your homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, this will clobber
your local versions. If you're not ready for that, you should ctrl-c your
way out of here.

For the remote repo, you will need its SSH key set up already.

Enter the Git remote URL for your dotfiles (e.g., git@github.com:USER/REPO.git).
URL: git@github.com:luser/dotfiles.git
LAST WARNING: Anything in git@github.com:luser/dotfiles.git will clobber local versions. Are you sure? (y/N) y
Cloning into bare repository '/home/luser/.ocd'...
...
HEAD is now at 98a3d17 Comment update.
[*] Pre-commit hook installed: /home/luser/.ocd/hooks/pre-commit
-rw-r--r-- 1 e e 200 Mar 15 22:25 /home/luser/.gitignore_ocd

Tip: Use "ocd check-ignore -v /home/luser/.gitignore_ocd" to troubleshoot matching rules.

[*] ALL DONE!

[!] Don't forget this in your .bashrc/.zsh/etc.:

  # Use "ocd" to manage dotfiles in $HOME.
  alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

  # Update .gitignore_ocd file.
  alias ocd-update-ignore='curl -sL "https://www.toptal.com/developers/gitignore/api/$(curl -sL https://www.toptal.com/developers/gitignore/api/list | xargs | sed '\''s/ /,/g'\'')" > $HOME/.gitignore_ocd'

After sourcing that you can just do "ocd add", "ocd commit", and so forth.

Save a one-liner like this to set everything up on other machines, AFTER
your SSH key is available on them, forwarded or otherwise. Then it's a
one-shot config:

# [!] OCD_CLOBBER="y" will overwrite files with versions from the repo.
export OCD_REMOTE="git@github.com:luser/dotfiles.git" OCD_CLOBBER="y" && \\
  curl -sL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \\
  | bash

$ alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

$ ocd status
On branch main
nothing to commit (use -u to show untracked files)

$ vi .bashrc

[add the "ocd" alias and such to your .bashrc]

$ ocd status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .bashrc

no changes added to commit (use "git add" and/or "git commit -a")

$ ocd commit -a
[main ac0275e] Adding ocd aliases and stuff.
 1 file changed, 1 deletion(-)

$ ocd push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 22 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 294 bytes | 294.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:luser/dotfiles.git
   febe867..ac0275e  main -> main
```
