#!/usr/bin/env bash
#shellcheck disable=SC1091,SC2086,SC2164
#
# Unit tests for OCD <https://github.com/nycksw/ocd>.
#
# TODO: Test 'ocd-backup' and 'ocd-status'.


test_header() {
  echo -e "\nRUNNING: ${FUNCNAME[1]}\n"
}

test_fail() {
  echo -e "\nFAILED: ${FUNCNAME[1]}\n"
}

setup() {
  test_header

  OCD_DIR=$(mktemp -d --suffix='_OCD_DIR')
  OCD_HOME=$(mktemp -d --suffix='_OCD_HOME')
  OCD_REPO=$(mktemp -d --suffix='_OCD_REPO')

  export OCD_ASSUME_YES="true"  # Non-interactive mode.

  # Create test git repo.
  touch "${OCD_REPO}"/{foo,bar,baz}
  mkdir -p ${OCD_REPO}/a/b/c
  touch "${OCD_REPO}"/a/b/c/qux

  git init ${OCD_REPO}
  if pushd "${OCD_REPO}"; then
    git add .
    git commit -a -m 'testing'
	popd; fi

  # Add an untracked file to the homedir.
  touch "${OCD_HOME}/fred"
}

test_install() {
  test_header
  . ocd.sh
}

test_file_tracking() {
  # TODO: test multiple args
  test_header

	# Add file from homedir to the repo.
  ocd-add "${OCD_HOME}"/fred
	test -f "${OCD_DIR}"/fred || test_fail
 
	# Stop tracking a file.
  ocd-rm "${OCD_HOME}"/fred
	test ! -f "${OCD_DIR}"/fred || test_fail
  ocd-rm "${OCD_HOME}"/a/b/c/qux
	test ! -f "${OCD_DIR}"/a/b/c/qux || test_fail
}

test_export() {
  # TODO: verify archive has expected contents.
  test_header

  ocd-export "${OCD_HOME}"/export.tar.gz
  test -f "${OCD_HOME}"/export.tar.gz || test_fail
}

teardown() {
  test_header
  rm -rf "${OCD_DIR}"
  rm -rf "${OCD_HOME}"
  rm -rf "${OCD_REPO}"
}

setup
test_install
test_file_tracking
test_export
teardown