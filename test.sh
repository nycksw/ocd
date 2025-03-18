#!/usr/bin/env bash

# A basic non-hermetic test to validate changes and demonstrate output.

test -f ./ocd-install.sh || \
  (echo 'Run this in the same dir as ocd-install.sh' && exit 1)

# Use a tmpdir as the homedir for testing.
HOME_SAVE=$HOME
FAKE_HOME=$(mktemp -d)
export HOME=$FAKE_HOME
cleanup() { export HOME="$HOME_SAVE"; rm -rf "$FAKE_HOME"; }
trap cleanup EXIT SIGINT SIGTERM

OCD="git --git-dir=$FAKE_HOME/.ocd --work-tree=$FAKE_HOME"

EXAMPLE_FILE='example.md'

export OCD_REMOTE='https://github.com/mathiasbynens/dotfiles.git'
export OCD_HOOK='y'
export OCD_GITIGNORE='y'
export OCD_CLOBBER='y'

cat > $EXAMPLE_FILE << 'END'
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

END

./ocd-install.sh &>> $EXAMPLE_FILE

echo '```' >> $EXAMPLE_FILE

cat >> $EXAMPLE_FILE << 'END'

Running `ocd status` after modifying tracked file `.gitconfig`:

```
# [...modifying config here...]

$ ocd status
END

#echo '#' >> $HOME/.gitconfig
$OCD config --global user.email "you@example.com"
$OCD config --global user.name "Your Name"
$OCD config --global commit.gpgsign false

$OCD status >> $EXAMPLE_FILE
echo '```' >> $EXAMPLE_FILE

cat >> $EXAMPLE_FILE << 'END'

And here is `ocd add` and `ocd commit`:

```
$ ocd add $HOME/.gitconfig
$ ocd commit -m 'Testing OCD'
END

$OCD add "$HOME"/.gitconfig >> $EXAMPLE_FILE
$OCD commit -m 'Testing OCD' >> $EXAMPLE_FILE
echo '```' >> $EXAMPLE_FILE

echo "OK: ocd-install.sh"

# Spot-check the excludesFile.
if ! grep -q '^.ssh/id_' "$FAKE_HOME"/.gitignore_ocd; then
  echo "[!] .gitignore_ocd is missing rules." && exit 1
else
  echo "OK: .gitignore_ocd"
fi

# Check that the hook got installed.
if [ ! -f "$HOME/.ocd/hooks/pre-commit" ]; then
  echo "[!] Missing: $HOME/.ocd/hooks/pre-commit" && exit 1
else
  echo "OK: $HOME/.ocd/hooks/pre-commit"
fi

echo -e "\n[*] Don't forget to add example.md to the commit."
