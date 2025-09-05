# Example: `ocd-install.sh`

The following shows console output from `ocd-install.sh` (via
the [test script](./test.sh)) to demonstrate what the setup looks like.

Note: This example uses a local test repository. In practice, you would use
your own dotfiles repository (e.g., `git@github.com:USER/dotfiles.git`).

```
$ ./ocd-install.sh -r <YOUR_DOTFILES_REPO> -c -h -g
This will create a bare local repo for managing dotfiles using your
homedir as the work tree and a remote repo for backup/sync.

WARNING! If you use a remote repo with existing dotfiles, local versions
will be overwritten.

OCD_CLOBBER='y' => local files may be overwritten.

Cloning into bare repository '/tmp/tmp.Mrme2lMzOz/.ocd'...
HEAD is now at cea977e Add example bashrc for OCD testing

[*] file:///tmp/sample-dotfiles/dotfiles.git cloned into /tmp/tmp.Mrme2lMzOz/.ocd as a bare repo.
[*] Pre-commit hook installed at: /tmp/tmp.Mrme2lMzOz/.ocd/hooks/pre-commit
-rw-r--r-- 1 e e 266K Sep  5 09:17 /tmp/tmp.Mrme2lMzOz/.gitignore_ocd

Tip: Use "ocd check-ignore -v $(basename "/tmp/tmp.Mrme2lMzOz/.gitignore_ocd")"  to troubleshoot matching rules.

[*] All done!

Add an alias in your shell rc:

  alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'

Then "ocd add", "ocd commit", etc.

One-liner for new machine setup:

curl -fsSL "https://raw.githubusercontent.com/nycksw/ocd/main/ocd-install.sh" \
  | bash -s -- -r "file:///tmp/sample-dotfiles/dotfiles.git" -c -h -g

```

Running `ocd status` after modifying tracked file `.bashrc_example`:

```
$ ocd status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   .bashrc_example

no changes added to commit (use "git add" and/or "git commit -a")
```

And then `ocd add` and `ocd commit`:

```
$ ocd add /tmp/tmp.Mrme2lMzOz/.bashrc_example
$ ocd commit -m 'Testing OCD'
[main 9af26ba] Testing OCD
 1 file changed, 1 insertion(+)
```
