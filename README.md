# OCD: tracking dotfiles in git

It's common to have dotfiles out of sync across all the different hosts
you may use. The OCD script allows you to easily track them in GitHub,
or any git repository of your choice. It makes setting up a new system
very simple.

Using this script you may take a freshly installed operating system and
set it up quickly doing something like this:

    # Substitute your own git repository here.
    curl https://raw.githubusercontent.com/obeyeater/ocd/master/.ocd.sh \
      -o ~/.ocd.sh
    source ~/.ocd.sh

This does the following:

  * checks if your SSH identity is available, and if it's not, prompts you
    for a remote host to copy them from (this is necessary to clone a RW
    git repository)
  * installs git(1) if it's not already installed
  * runs `git clone` of your repository into your OCD directory (default is
    `~/.ocd`)
  * reminds you to run `ocd-restore`, which finishes the process by copying
    all the tracked files into your `$HOME`

Make sure `source $your_ocd_dir` (default: `~/.ocd`) is in your `.bashrc`
to use the other helpers provided by this script, such as adding or removing
dotfiles from your repository.

# Writing portable config files

This process requires you think a little differently about your dotfiles to
make sure they're portable across all the systems you use. For example, my
`.bashrc` is suitable for every system I use, and I put domain-centric 
customizations (for example, hosts I use at work) in a separate file. Consider
these lines, which I include at the end of my `.bashrc`:

    source $HOME/.bashrc_$(hostname -f)
    source $HOME/.bashrc_$(dnsdomainname)

This way, settings are only applied in the appropriate context.

# Managing changes to tracked files

When I log in to a system that I haven't worked on in a while, the first
thing I do is run `ocd-restore`. Any time I make a config change, I run
`ocd-backup`. 

*Note*: the actual dotfiles are hard-linked to their counterparts in the local
`~/.ocd` git branch, so there's no need to copy changes anywhere before
committing. Just edit in place and run `ocd-backup`.

There are also helper functions: `ocd-status` tells me if I'm behind the
master, and `ocd-missing-debs` and `ocd-extra-debs` tell me if my system's
packages differ from my basic preferences recorded in `~/.favdebs` (for
example, your openbox autostart may call programs that are not installed
by default on a new system; `ocd-missing-debs` is just a very simple way
to record these dependencies and make it easy to install them, e.g.:
`sudo apt-get install $(ocd-missing-debs)`)

Adding new files is just:
  * `ocd-add <filename>`
  * `ocd-backup`

### Example output

If I change something on any of my systems, I can easily push the change
back to my master git repository. For example:
```
  $ ocd-backup 
  git status in /home/e/.ocd:

  On branch master
  Your branch is up-to-date with 'origin/master'.

  Changes not staged for commit:
    (use "git add <file>..." to update what will be committed)
    (use "git checkout -- <file>..." to discard changes in working directory)

          modified:   .bashrc

  [...]
  
  Commit and push now? (yes/no): yes

  [... add a commit message here ...]

  [master 623d0be] testing
   1 file changed, 1 insertion(+)
  Counting objects: 5, done.
  Delta compression using up to 12 threads.
  Compressing objects: 100% (3/3), done.
  Writing objects: 100% (3/3), 295 bytes | 0 bytes/s, done.
  Total 3 (delta 2), reused 0 (delta 0)
  To git@github.com:obeyeater/ocd.git
     88bfe09..623d0be  master -> master
```

### Caveats

Occasionally I'll change something on more than one system without
running `ocd-backup`, and git will complain that it can't run `git pull`
without first committing local changes. This is easy to fix by `cd`ing to
`~/.ocd` and doing a typical merge, a simple `git push`, a `git checkout
-f $filename` to overwrite changes, or some other resolution.

# Installation and usage

  * Create an empty git repo for your dotfiles (e.g.: `git init --bare ~/.ocd`)
  * `curl https://raw.githubusercontent.com/obeyeater/ocd/master/.ocd.sh -o ~/.ocd.sh`
  * Review the `~/.ocd.sh` file to make sure I'm not malicious :-) Edit `OCD_REPO` with your own repo.
  * `source ~/.ocd.sh`
  * Add additional dotfiles with `ocd-add <filename>`
  * Make sure `.bashrc` includes something like `source ~/.ocd.sh`.
  * `ocd-backup` to push your changes to the repo.
  * `ocd-restore` to sync everything from your local branch to your home directory.
