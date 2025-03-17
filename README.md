# OCD: Obsessively Curated Dotfiles

A minimalistic dotfile-management workflow using a bare repository and `$HOME` as the [work tree](https://git-scm.com/docs/git-worktree). By setting `showUntrackedFiles no`, the `status` command only shows intentionally staged files for commits. The `excludesFile` and pre-commit hook prevent accidentally adding secrets/junk. A shell alias makes everything seamless. (`ocd status`, `ocd add`, `ocd commit`, ...)

Deploying everything to a new machine is a one-liner. No tangle of symlinks, no wrappers, no dedendencies. Just Git.

**Important**: Using a remote repo containing existing dotfiles will overwrite your local files. Back up anything important first.

One-shot install:

```
curl -fsSL https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh | sh
```

Or clone this repo and run,

```
./ocd-install.sh
```

### Credits

Previously, "OCD" was my little pet script doing a minimal symlink-farm-to-Git-repo approach. I favored that because [every other option](https://dotfiles.github.io/utilities/) involved too much extra code and complexity, especially for setting up new machines with varying environments. Then I found this  [minimal and elegant suggestion](https://news.ycombinator.com/item?id=11071754) by [StreakyCobra](https://github.com/StreakyCobra) (from 2016!). Atlassian provided a [helpful write-up](https://www.atlassian.com/git/tutorials/dotfiles) based on that comment. 

Below, I'll explain how it works and how to use the `ocd-install.sh` script which implements this idea with some extra safety checks.

## Philosophy

The basic idea:

- Store dotfiles in `~/.ocd` (a bare repo).
- Work directly in `$HOME` with `ocd` as the Git command alias: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

Accidentally committing sensitive things from your home directory (e.g., ~~`ocd add .`~~) is a concern, so:

- An extensive `.gitignore_ocd` warns about potential secrets/junk.
- A pre-commit hook will warn when adding lots of files at once.

## One-Shot Setup

The `ocd-install.sh` script will ask for your existing remote repo URL (GitHub, GitLab, etc.) for your dotfiles. If you already have one with dotfiles in it, that's fine if the files are at the root of the repo. If you already have files in it, **this setup will overwrite your local versions in your home directory**! You may also pass arguments non-interactively, which you'll probably want to do for new machines once you get used to this way of working.

The script will also offer a pre-commit hook to make sure you don't accidentally add your entire home directory by flagging commits with more than 20 files.

Finally, it also offers to download a massive `excludesFile` (`$HOME/.gitignore_ocd`) to prevent accidentally checking in secrets and other junk files. At the time of this writing it has 8421 rules in it. You may override a bad match with `-f`.

### Example

Running the script looks like this:

```console
$ ./ocd-install.sh
This will create a bare local repo for managing dotfiles.
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

One-shot one-liner:

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

## But...

### Alternatives

For people who live in a terminal, this whole topic is deeply personal. There are [many ways to do this](https://dotfiles.github.io/utilities/).

### System Agnosticism

This workflow only uses Git. `ocd-install.sh` is Bash but this workflow works anywhere.

If you want to use this workflow across heterogeneous systems, you'll need to write your dotfiles in a suitable way. I do something like this in my `.bashrc`:

```
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)" \
  # ...
  do if [[ -f "${FILE}" ]]; then source "${FILE}"; fi
done
```

For example, to source a specific config on a machine whose short hostname is `lurkstation`, I put it in a file called `$HOME/.bashrc_lurkstation`. This eliminates the need for a more complicated templating system to accommodate different machines. One repo, one branch, one set of dotfiles.

### Branches for Dotfiles

If you don't like the system-agnosticism suggestion above and you _really_ need to keep different branches for your dotfiles, you can. The `ocd` alias is just Git. Adjust the alias or the workflow to suit your needs

### "This is More Complicated Than..."

Using Git in this way may feel more complicated (or just "weird") vs. using [Stow](https://www.gnu.org/software/stow/), or [dotbot](https://github.com/anishathalye/dotbot), or [chezmoi](https://www.chezmoi.io/), but it's hard to argue that those tools don't add _code complexity_ and extra dependencies. Once you understand the relationship between the bare repo and the work tree, this feels cleaner, _more_ intuitive, and safer.

### Security

Hopefully this is obvious, but any time you fetch files from the Internet and write them to your home directory you need to be careful.
