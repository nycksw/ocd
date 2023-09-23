# Optimally Configured Dotfiles

Do you have dotfiles skewed across lots of different machines? This script allows 
you to easily track and synchronize them using Git as a backend. It makes
setting up a new system very fast and simple.

Move into a new shell like so:

```
    curl https://raw.githubusercontent.com/nycksw/ocd/master/ocd.sh -o ~/bin/ocd
    chmod +x ~/bin/ocd
```

Create a new SSH keypair for the system:

```
   ssh-keygen -t ed25519 -f ~/.ssh/your_deploy_key
```

Add your new private key to your repository. Here are the
[GitHub instructions for managing deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys).

```
    echo 'OCD_REPO=git@github.com:username/your-dotfiles.git' >> ~/.ocd.conf
    echo 'OCD_IDENT=~/.ssh/your_deploy_key'
```

Finally, install your dotfiles into your home directory:

```
    ocd install
```

When you run `ocd install` it does the following:

  * Checks if your SSH identity is available (this is necessary to clone a RW git repository).
  * Installs `git(1)` if it's not already installed
  * Runs `git clone` of your repository into your OCD directory (default is `~/.ocd`)

# Installation and usage

Usage:
```
  ocd install:        install files from git@github.com:nycksw/dotfiles.git
  ocd add FILE:       track a new file in the repository
  ocd rm FILE:        stop tracking a file in the repository
  ocd restore:        pull from git master and copy files to homedir
  ocd backup:         push all local changes to master
  ocd status [FILE]:  check if a file is tracked, or if there are uncommited changes
  ocd export FILE:    create a tar.gz archive with everything in /home/e/.ocd
  ocd missing-pkgs:   compare system against /home/e/.favpkgs and report missing
```

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

There are other dotfile managers! You should almost certainly use one of them instead of
this one:

* [dotbot](https://github.com/anishathalye/dotbot),
* [chezmoi](https://www.chezmoi.io/why-use-chezmoi/),
* [yadm](https://yadm.io/)
* [GNU Stow](https://www.gnu.org/software/stow/).

 I wrote OCD before any of these existed, and I've never tried them because they seem too
 heavyweight for my taste, but I'm sure they offer advantages over this little pet script
 of mine.
