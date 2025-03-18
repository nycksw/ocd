# OCD: Obsessively Curated Dotfiles

A minimalistic dotfile-management workflow using a bare repository and
`$HOME` as the [work tree](https://git-scm.com/docs/git-worktree). By setting
`showUntrackedFiles no`, the `status` command only shows intentionally
staged files. The `excludesFile` and pre-commit hook prevent accidentally
adding secrets/junk. A shell alias makes everything seamless. (`ocd status`,
`ocd add`, `ocd commit`, ...)

Deploying to a new machine is a one-liner. No tangle of symlinks, no wrappers,
no dependencies. Just Git.

## Philosophy

The basic idea:

- Store dotfiles in `$HOME/.ocd` (a bare repo).
- Work directly in `$HOME` with `ocd` as the Git command alias: `alias ocd='git --git-dir=$HOME/.ocd --work-tree=$HOME'`

Accidentally committing sensitive things from your home directory (e.g.,
~~`ocd add .`~~) is a concern, so:

- An extensive `.gitignore_ocd` warns about potential secrets/junk.
- A pre-commit hook warns when adding many files at once.


## Running the Installation Script

**Important**: Using a remote repo containing existing dotfiles will overwrite
your local files. Back up anything important first.

Clone this repo, review the code, and run: `./ocd-install.sh`

The `ocd-install.sh` script will ask for your existing remote repo URL
(GitHub, GitLab, etc.) for tracking your dotfiles. If you already have one with
dotfiles already in it, that's fine if the files are at the root of the repo,
but remember that **this setup will overwrite your local versions in your
home directory**! You may also pass arguments non-interactively, which you'll
probably want to do for new machines once you get used to this way of working.

The script offers a pre-commit hook to make sure you don't accidentally add
your entire home directory by flagging commits with more than 20 files.

Finally, it also offers to download a massive `excludesFile`
(`$HOME/.gitignore_ocd`) to prevent accidentally checking in secrets and
other junk files. At the time of this writing it has 5059 rules in it. You
may override a bad match with `-f`.

### Credits

"OCD" was my little pet script implementing a minimal
symlink-farm-to-Git-repo approach. I favored that because [other
options](https://dotfiles.github.io/utilities/) involved too
much extra code and complexity, especially when setting up new
machines with varying environments. Then I found this  [minimal and
elegant suggestion](https://news.ycombinator.com/item?id=11071754) by
[StreakyCobra](https://github.com/StreakyCobra) (from 2016!). Atlassian
provided a [helpful write-up](https://www.atlassian.com/git/tutorials/dotfiles)
based on that comment.

## Example

`ocd-install.sh` looks something like [this](./example.md).

## But...

### Alternatives

For people who live in a terminal, this whole topic is deeply personal. There
are [many ways to do this](https://dotfiles.github.io/utilities/).

### System Agnosticism

This workflow only uses Git. `ocd-install.sh` is Bash but this workflow
works anywhere Git works.

However, if you want to use this workflow across heterogeneous systems,
you'll need to write your dotfiles in a suitable way. I do something like
this in my `.bashrc`:

```
for FILE in \
  "${HOME}/.bashrc_$(dnsdomainname -s)" \
  "${HOME}/.bashrc_$(hostname -s)" \
  # ...
  do if [[ -f "${FILE}" ]]; then source "${FILE}"; fi
done
```

For example, to source a specific config on a machine whose short hostname is
`lurkstation`, I put it in a file called `$HOME/.bashrc_lurkstation`. This
removes the need for a more complex templating. One repo, one branch, one
set of files.

### Branches for Dotfiles

If you don't like the system-agnosticism suggestion above and you _really_
need to keep different branches for your dotfiles, you can. The `ocd` alias
is just Git. Adjust the alias or the workflow to suit your needs

### "This is More Complicated Than..."

Using Git in this way may feel more complicated (or just
"weird") vs. using [Stow](https://www.gnu.org/software/stow/),
or [dotbot](https://github.com/anishathalye/dotbot), or
[chezmoi](https://www.chezmoi.io/), but it's hard to argue that those tools
don't add _code complexity_ and extra dependencies. Once you understand the
relationship between the bare repo and the work tree, this feels cleaner,
_more_ intuitive, and safer.

### Security

Hopefully this is obvious, but any time you fetch files from the internet
and write them to your home directory, you need to be careful.
