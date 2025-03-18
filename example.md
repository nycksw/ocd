# Example: `ocd-install.sh`

The following is console output from `ocd-install.sh` (run from the
[test script](./test.sh)) to demonstrate what running the
install script looks like:

```
# These env vars are for non-interactive mode.
$ export OCD_REMOTE='https://github.com/mathiasbynens/dotfiles.git'
$ export OCD_HOOK='y'
$ export OCD_GITIGNORE='y'
$ export OCD_CLOBBER='y'

$  ./ocd-install.sh

This will create a bare local repo for managing dotfiles using your
homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, this will
clobber your local versions. If you're not ready for that, you should
ctrl-c your way out of here.

URL (from env): https://github.com/mathiasbynens/dotfiles.git
OCD_CLOBBER='y': proceeding!

Cloning into bare repository '/tmp/tmp.E7X4u5VvqB/.ocd'...
HEAD is now at b7c7894 .gitconfig: exclude submodules

[*] Repo https://github.com/mathiasbynens/dotfiles.git cloned into /tmp/tmp.E7X4u5VvqB/.ocd @HEAD.

[*] Pre-commit hook installed: /tmp/tmp.E7X4u5VvqB/.ocd/hooks/pre-commit
-rw-r--r-- 1 e e 266K Mar 18 14:59 /tmp/tmp.E7X4u5VvqB/.gitignore_ocd

Tip: Use "ocd check-ignore -v .gitignore_ocd" to troubleshoot matching rules.

[*] ALL DONE!

[!] Don't forget this in your .bashrc/.zsh/etc.:

  # Use "ocd" to manage dotfiles in $HOME.
  alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

Then you can run "ocd add", "ocd commit", etc.

One-shot:

# [!] OCD_CLOBBER will overwrite files with versions from the repo.
export OCD_REMOTE="https://github.com/mathiasbynens/dotfiles.git" OCD_CLOBBER="y" OCD_HOOK='y' && \
  curl -sL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash

```

Running `ocd status` after modifying tracked file `.gitconfig`:

```
# [...modifying config here...]

$ ocd status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   .gitconfig

no changes added to commit (use "git add" and/or "git commit -a")
```

And here is `ocd add` and `ocd commit`:

```
$ ocd add $HOME/.gitconfig
$ ocd commit -m 'Testing OCD'
[main b7b3cbf] Testing OCD
 1 file changed, 4 insertions(+), 1 deletion(-)
```
