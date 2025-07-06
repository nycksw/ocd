#!/usr/bin/env bash
# A basic non-hermetic test to validate changes and demonstrate output.

set -e  # Exit on error.

test -f ./ocd-install.sh || \
  (echo 'Run this in the same dir as ocd-install.sh' && exit 1)

# Use a tmpdir as the homedir for testing.
FAKE_HOME="$(mktemp -d)"
OCD_HOME="$FAKE_HOME"  # For safety because I rm -rf $FAKE_HOME below.
OCD_BARE="${OCD_HOME}/.ocd"

cleanup() { rm -rf "$FAKE_HOME"; }
trap cleanup EXIT SIGINT SIGTERM

OCD="git --git-dir=$OCD_BARE --work-tree=$FAKE_HOME"
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
  ./ocd-install.sh -r "https://github.com/mathiasbynens/dotfiles.git" \
    -c -h -g -B "$OCD_BARE" -H "$OCD_HOME"
  echo '```';
} &>> "$EXAMPLE_FILE"

cat >> "$EXAMPLE_FILE" << 'END'

Running `ocd status` after modifying tracked file `.gitconfig`:

```
# [...modifying config here...]

$ ocd status
END

echo "# Hello from $0" >> $OCD_HOME/.gitconfig

{
  $OCD status;
  cat << END
\`\`\`

And then \`ocd add\` and \`ocd commit\`:

\`\`\`
$ ocd add $OCD_HOME/.gitconfig
$ ocd commit -m 'Testing OCD'
END

  $OCD add "$OCD_HOME/.gitconfig";
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
if [ ! -f "$OCD_BARE/hooks/pre-commit" ]; then
  echo "[!] Missing pre-commit hook at $OCD_BARE/hooks/pre-commit" && exit 1
else
  echo "OK: $OCD_BARE/hooks/pre-commit"
fi

# Test the pre-commit hook.
for i in $(seq 1 22); do
  touch "$FAKE_HOME/testfile$i"
done
$OCD add $FAKE_HOME/testfile*
if $OCD commit -m 'big commit' >/dev/null 2>&1; then
  echo "[!] Pre-commit hook did not block a large commit." && exit 1
else
  echo "OK: pre-commit hook blocked large commit."
fi

# Clean up staged files and temp files.
$OCD reset --quiet HEAD
rm $FAKE_HOME/testfile*

echo -e "\n[*] Don't forget to add example.md to your commit!"
