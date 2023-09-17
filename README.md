# OCD: tracking dotfiles in git

Do you have dotfiles skewed across lots of different machines? This script allows 
you to easily track and synchronize them using Git as a backend. It makes
setting up a new system very fast and simple.

Move into a new shell like so:

```
    curl https://raw.githubusercontent.com/nycksw/ocd/master/ocd.sh -o ~/bin/ocd
    curl https://raw.githubusercontent.com/nycksw/shlib/main/shlib -o ~/bin/shlib
    chmod +x ~/bin/{ocd,shlib}
    vim ~/bin/ocd  # Change OCD_REPO to your own repository.
    ocd install
```

See "Installation and usage" (below) for more information on how to set up your own repository.

When you run `ocd install` it does the following:

  * Checks if your SSH identity is available (this is necessary to clone a RW git repository).
  * Installs `git(1)` if it's not already installed
  * Runs `git clone` of your repository into your OCD directory (default is `~/.ocd`)

# Installation and usage

  * [Create an empty GitHub repo](https://help.github.com/articles/create-a-repo/) for your dotfiles.
    * You'll need the repo identifier in a moment, something like: `git@github.com:username/dotfiles.git`
    * If you're not forwarding the appropriate SSH identity for the repo you'll be using, you'll 
      still need to set that up manually, either via forwarding or by manually copying your key to the
      host and running an ssh-agent locally.
  * `curl https://raw.githubusercontent.com/nycksw/ocd/master/ocd.sh -o ~/bin/ocd`
  * `curl https://raw.githubusercontent.com/nycksw/shlib/main/shlib -o ~/bin/shlib`
  * `vim ~/bin/ocd` and change `OCD_REPO` to point to your own repository.
  * `ocd install` to install the system and create all the links.
  * Add all the additional dotfiles you want to track by doing `ocd add <filename>`
  * Use `ocd backup` to push your changes to the repo.
  * Use `ocd restore` to sync everything from your repository to your home directory.
  * Optional: create a `~/.favpkgs` file containing packages you routinely install on a new system.
    * `ocd missing-pkgs` will use this to show you which packages are currently missing.
    * Then you can do something like this: `sudo apt-get install $(ocd missing-pkgs)`

# Writing portable config files

This process may require you think a little differently about your dotfiles to
make sure they're portable across all the systems you use. For example, my
`.bashrc` is suitable for *every* system I use, and I put domain-centric or
host-centric customizations (for example, hosts I use at work) in a separate file.
Consider these lines, which I include at the end of my `.bashrc`:

    source $HOME/.bashrc_$(hostname -f)
    source $HOME/.bashrc_$(dnsdomainname)

This way, settings are only applied in the appropriate context.

# Managing changes to tracked files

When I log in to a system that I haven't worked on in a while, the first thing
I do is run `ocd restore`. Any time I make a config change, I run `ocd backup`.

*Note*: the actual dotfiles are linked to their counterparts in the
local `~/.ocd` git branch, so there's no need to copy changes anywhere before
committing. Just edit in place and run `ocd backup`.

There are also helper functions: `ocd status` tells me if I'm behind the
master, and `ocd missing-pkgs` tells me if my installed
packages differ from my basic preferences recorded in `~/.favpkgs` (for
example, your `openbox` autostart may call programs that are not installed
by default on a new system; `ocd missing-pkgs` is just a very simple way
to record these dependencies and make it easy to install them, e.g.: `sudo
apt-get install $(ocd missing-pkgs)`)

Adding new files is just:
  * `ocd add <filename>`
  * `ocd backup`

Finally, you may also use `ocd export filename.tar.gz` to create an archive
with all your files. This is useful if you'd like to copy your files to
another host where you don't want to use OCD.

### Example output

If I change something on any of my systems, I can easily push the change
back to my master git repository. For example:

```
  $ ocd backup

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
  To git@github.com:nycksw/dotfiles.git
     88bfe09..623d0be  master -> master
```

### Caveats

*Merging git conflicts*: Occasionally I'll change something on more than one system without
running `ocd backup`, and git will complain that it can't run `git pull` without
first committing local changes. This is easy to fix by `cd`ing to `~/.ocd`
and doing a typical merge, a simple `git push`, a `git checkout -f $filename`
to overwrite changes, or some other resolution.

*Portability*: I've run OCD on a few different distributions, but if you use something besides
Debian, NixOS, or Ubuntu it may not work. I'd love any pull requests to make this script work
on other distributions. 

### Alternatives

There are other dotfile managers! You may want to consider [dotbot](https://github.com/anishathalye/dotbot),
[chezmoi](https://www.chezmoi.io/why-use-chezmoi/),
[yadm](https://yadm.io/), or [GNU Stow](https://www.gnu.org/software/stow/). I wrote OCD before any of these
existed, and I've never tried them because they seem too heavyweight for my taste, but I'm sure they offer
advantages over this little pet script of mine.
