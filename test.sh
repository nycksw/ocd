#!/usr/bin/env bash
# A hermetic test to validate changes and demonstrate output.

set -e  # Exit on error.

test -f ./ocd-install.sh || \
  (echo 'Run this in the same dir as ocd-install.sh' && exit 1)

# Use tmpdirs for testing.
FAKE_HOME="$(mktemp -d)"
TEST_REPO_DIR="$(mktemp -d)"
OCD_HOME="$FAKE_HOME"  # For safety because I rm -rf $FAKE_HOME below.
OCD_BARE="${OCD_HOME}/.ocd"

# Create a friendly symlink for clearer example output.
SAMPLE_DOTFILES="/tmp/sample-dotfiles"
rm -f "$SAMPLE_DOTFILES"  # Remove any existing symlink.
ln -s "$TEST_REPO_DIR" "$SAMPLE_DOTFILES"
TEST_REMOTE="${SAMPLE_DOTFILES}/dotfiles.git"

cleanup() { 
  rm -rf "$FAKE_HOME" "$TEST_REPO_DIR"
  rm -f "$SAMPLE_DOTFILES"
}
trap cleanup EXIT SIGINT SIGTERM

# Create a minimal test repository.
echo "[*] Creating test repository..."
(
  cd "$TEST_REPO_DIR"
  mkdir source && cd source
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test User"
  
  # Create a single example dotfile.
  cat > .bashrc_example << 'EOF'
# Example bashrc for OCD testing
# This file demonstrates dotfile management with OCD
export OCD_TEST="Hello from OCD!"
alias ocd-test='echo "OCD is working!"'
EOF
  
  git add .bashrc_example
  git commit -q -m "Add example bashrc for OCD testing"
  cd ..
  git clone -q --bare source dotfiles.git
)

OCD="git --git-dir=$OCD_BARE --work-tree=$FAKE_HOME"
EXAMPLE_FILE="example.md"

# Write the initial part of example.md to show how the script is invoked.
cat > "$EXAMPLE_FILE" << 'END'
# Example: `ocd-install.sh`

The following shows console output from `ocd-install.sh` (via
the [test script](./test.sh)) to demonstrate what the setup looks like.

Note: This example uses a local test repository. In practice, you would use
your own dotfiles repository (e.g., `git@github.com:USER/dotfiles.git`).

```
$ ./ocd-install.sh -r <YOUR_DOTFILES_REPO> -c -h -g
END

# Run ocd-install.sh with flags, capturing output in example.md.
{
  ./ocd-install.sh -r "file://${TEST_REMOTE}" \
    -c -h -g -B "$OCD_BARE" -H "$OCD_HOME"
  echo '```';
} &>> "$EXAMPLE_FILE"

cat >> "$EXAMPLE_FILE" << 'END'

Running `ocd status` after modifying tracked file `.bashrc_example`:

```
$ ocd status
END

echo "# Modified by test" >> $OCD_HOME/.bashrc_example

{
  $OCD status;
  cat << END
\`\`\`

And then \`ocd add\` and \`ocd commit\`:

\`\`\`
$ ocd add $OCD_HOME/.bashrc_example
$ ocd commit -m 'Testing OCD'
END

  $OCD add "$OCD_HOME/.bashrc_example";
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
