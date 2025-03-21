# Example: `ocd-install.sh`

The following shows console output from `ocd-install.sh` (via
the [test script](./test.sh)) to demonstrate what the setup looks like:

```
$ ./ocd-install.sh -r https://github.com/mathiasbynens/dotfiles.git -c -h -g
This will create a bare local repo for managing dotfiles using your
homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, local versions
will be overwritten.

OCD_CLOBBER='y' => local files may be overwritten.

Cloning into bare repository '/tmp/tmp.0UKQAFwqrR/.ocd'...
HEAD is now at b7c7894 .gitconfig: exclude submodules

[*] https://github.com/mathiasbynens/dotfiles.git cloned into /tmp/tmp.0UKQAFwqrR/.ocd as a bare repo.
[*] Pre-commit hook installed at: /tmp/tmp.0UKQAFwqrR/.ocd/hooks/pre-commit
-rw-r--r-- 1 e e 266K Mar 21 14:40 /tmp/tmp.0UKQAFwqrR/.gitignore_ocd

Tip: Use "ocd check-ignore -v $(basename "/tmp/tmp.0UKQAFwqrR/.gitignore_ocd")"  to troubleshoot matching rules.

[*] All done!

Add an alias in your shell rc:

  alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

Then "ocd add", "ocd commit", etc.

One-liner for new machine setup:

curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r "https://github.com/mathiasbynens/dotfiles.git" -c -h -g

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

And then `ocd add` and `ocd commit`:

```
$ ocd add /tmp/tmp.0UKQAFwqrR/.gitconfig
$ ocd commit -m 'Testing OCD'
[main 58f0162] Testing OCD
 1 file changed, 1 insertion(+)
```
