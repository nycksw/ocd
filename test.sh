#!/usr/bin/env bash
# A basic non-hermetic test to validate changes and demonstrate output.

test -f ./ocd-install.sh || \
  (echo 'Run this in the same dir as ocd-install.sh' && exit 1)

# Use a tmpdir as the homedir for testing.
HOME_SAVE=$HOME
FAKE_HOME=$(mktemp -d)
export HOME=$FAKE_HOME
cleanup() {
  export HOME="$HOME_SAVE"
  rm -rf "$FAKE_HOME"
}
trap cleanup EXIT SIGINT SIGTERM

OCD="git --git-dir=$FAKE_HOME/.ocd --work-tree=$FAKE_HOME"
EXAMPLE_FILE="example.md"

# Write the initial part of example.md to show how the script is invoked.
cat > "$EXAMPLE_FILE" << 'END'
# Example: `ocd-install.sh`

The following shows console output from `ocd-install.sh` (via
the [test script](./test.sh)) to demonstrate what the setup looks like:

```
$ ./ocd-install.sh -r https://github.com/mathiasbynens/dotfiles.git -c -h -g
END

# Run ocd-install.sh with flags, capturing output in example.md.
{
  ./ocd-install.sh -r "https://github.com/mathiasbynens/dotfiles.git" -c -h -g;
  echo '```';
} &>> "$EXAMPLE_FILE"


cat >> "$EXAMPLE_FILE" << 'END'

Running `ocd status` after modifying tracked file `.gitconfig`:

```
# [...modifying config here...]

$ ocd status
END

# Make a few .gitconfig changes so there's something to see in ocd status.
$OCD config --global user.email "you@example.com"
$OCD config --global user.name "Your Name"
$OCD config --global commit.gpgsign false

{
  $OCD status;
  cat << 'END'
```

And then `ocd add` and `ocd commit`:

```
$ ocd add $HOME/.gitconfig
$ ocd commit -m 'Testing OCD'
END

  $OCD add "$HOME/.gitconfig";
  $OCD commit -m 'Testing OCD';
  echo '```';
} >> "$EXAMPLE_FILE"

echo "OK: ocd-install.sh"

# Spot-check .gitignore_ocd for a known SSH rule.
if ! grep -q '^.ssh/id_' "$FAKE_HOME/.gitignore_ocd"; then
  echo "[!] .gitignore_ocd is missing some rules." && exit 1
else
  echo "OK: .gitignore_ocd"
fi

# Confirm the pre-commit hook is in place.
if [ ! -f "$FAKE_HOME/.ocd/hooks/pre-commit" ]; then
  echo "[!] Missing pre-commit hook at $FAKE_HOME/.ocd/hooks/pre-commit" && exit 1
else
  echo "OK: $FAKE_HOME/.ocd/hooks/pre-commit"
fi

echo -e "\n[*] Don't forget to add example.md to your commit!"
