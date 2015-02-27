## OCD: tracking dotfiles in git

I got tired of having my common dotfiles (`.bashrc`, `.pythonrc`,
`.vimrc`, etc.) out of sync across all the different workstations
and shells I use on a regular basis. So, I rewrote them in a
way to be generic, allowing host-specific and domain-specific
files to be sourced as appropriate. I also included window-manager
specifics, like my Openbox configuration. This was inspired by a [similar
approach](http://books.google.com/books?id=mKgomQz5KH0C&pg=PA149&lpg=PA149&dq=flickenger+movein&oi=book_result&resnum=1&ct=result#v=onepage&q&f=false)
I read a very long time ago.

Now I can take a freshly installed operating system and make it cozy and
customized without any tedious repetition. I also get the added benefit
of source control to view previous versions of files, and it's really
easy to share dotfiles with other people just by pointing them at my repo.

When I set up a freshly installed system, I first install my private SSH key:

    mkdir -p ~/.ssh && scp user@someotherhost:.ssh/id\.\* ~/.ssh

Once the appropriate github SSH identity is in `~/.ssh`, then I can run this:

    curl https://raw.githubusercontent.com/obeyeater/ocd/master/.ocd_functions \
      -o ~/.ocd_functions
    source ~/.ocd_functions

That clones my entire dotfile repo and allows me to copy the entire
environment into my home directory. It also includes helper functions to
easily identify system packages that should also be installed (or removed)
based on a list also tracked in git as a dotfile: ".favdebs".

Those simple steps eliminate 98% of the fiddling I used to do when
moving into a freshly installed system. The only remaining tweaks deal
with differences between distributions or domain-specific configurations,
and I write my dotfiles in such a way to accommodate those scenarios. For
example, my .bashrc only contains things I'm reasonably sure are portable
across all of the systems I use (it helps that I usually use only Debian
or Ubuntu systems.) To handle host- or domain-specific configs, I do
something like the following at the end of my main `.bashrc`:

    source $HOME/.bashrc_$(hostname -f)
    source $HOME/.bashrc_$(dnsdomainname)

This way, settings are only applied in the appropriate context.

## Managing changes

### Workflow

When I log in to a system that I haven't worked on in a while, the first
thing I do is run `ocd-restore`. Any time I make a config change, I run
`ocd-backup`. I also have helpers: `ocd-status` tells me if I'm behind the
master, and `ocd-missing-debs` and `ocd-extra-debs` tell me if my system's
packages differ from my basic preferences recorded in `~/.favdebs`.

### Example output

If I change something on any of my systems, I can easily push the change
back to my master git repository. For example:

    $ echo "# Just testing OCD." >> ~/.bashrc
    $ ocd-backup
    ..................... done!

    git status in /home/eater/.ocd:

    # On branch master
    # Changes not staged for commit:
    # (use "git add <file>..." to update what will be committed)
    # (use "git checkout -- <file>..." to discard changes in working directory)
    #
    # modified: .bashrc
    #
    no changes added to commit (use "git add" and/or "git commit -a")

    git diff in /home/eater/.ocd:

    diff --git a/.bashrc b/.bashrc
    index 4e127f4..11d24ff 100644
    --- a/.bashrc
    +++ b/.bashrc
    @@ -57,3 +57,4 @@ for file in $SOURCE_FILES;do test -f $file && . $file;done
    # test -f ~/bin/ocd-status && ~/bin/ocd-status
    # touch ~/.bashrc
    #fi

    +# Just testing OCD.

    Commit and push now? (yes/no): yes
    [Editor launches so you may describe the change here.]

    ".git/COMMIT_EDITMSG" 10L, 270C [w]
    [master da7e536] Just testing.
    1 file changed, 1 insertion(+)
    Counting objects: 5, done.
    Delta compression using up to 12 threads.
    Compressing objects: 100% (3/3), done.
    Writing objects: 100% (3/3), 308 bytes | 0 bytes/s, done.
    Total 3 (delta 2), reused 0 (delta 0)
    To git@github.com:obeyeater/ocd.git
    3599b0b..da7e536 master -> master

### Caveats

Occasionally I'll change something on more than one system without
running `ocd-backup`, and git will complain that it can't run `git pull`
without first committing local changes. This is easy to fix my `cd`ing to
`~/.ocd` and doing a typical merge, a simple `git push`, a `git checkout
-f $filename` to overwrite changes, or some other resolution.

## Steal this technique

If you want to use my configuration as a starting point, you can just
branch my git repo and make your own modifications following the workflow
described above. Be sure to change `INSTALL_FROM` in `~/.ocd_functions`
so it installs from the right repo. You'll want to do something like this:

  * Fork [my repository](https://github.com/obeyeater/ocd) (if you're using GitHub, look for "Fork" in the upper right)
  * Review the `~/.ocd_functions` file to make sure I'm not malicious :-) Then:
    * `curl https://raw.githubusercontent.com/obeyeater/ocd/master/.ocd_functions -o ~/.ocd_functions`
    * `source ~/.ocd_functions`
  * Edit `~/.ocd_functions` and update `INSTALL_FROM` with your own repo.
  * `source ~/.ocd_functions`
