#!/usr/bin/env bash

set -e

run_maude()  {
  maude </dev/null -no-banner -no-wrap <(echo 'set show stats off . set show timing off .') "$@"
}

do_diff() {
  git --no-pager diff --no-index --word-diff "$@"
}

run_test() {
  for t in "$@"; do
    test_actual=$(mktemp -t maude-run-XXXXXX)
    echo -n "$t ... "
    run_maude "$t" &> "$test_actual"
    echo "passed."
    do_diff "$test_actual" "$t.expected"
  done
  echo 'Passed.'
}

update_expected() {
  for t in "$@"; do
    run_maude "$t" &> "$t.expected"
  done
}

print_usage() {
    echo """
    Usage:

      run all tests:

        $0

      run a list of tests:

        $0 test <test1> [... <testn>]

      run test, but do not check output:

        $0 run <test1> [... <testn>]

      update expected output:

        $0 update <test1> [... <testn>]
    """
}

  if [[ "$#" = 0        ]] ; then run_test t/*.maude ;
elif [[ "$1" = "run"    ]] ; then shift; run_maude "$@" ;
elif [[ "$1" = "test"   ]] ; then shift; run_test "$@" ;
elif [[ "$1" = "update" ]] ; then shift; update_expected "$@" ;
elif [[ "$1" = "help"   ]] ; then shift; print_usage     "$@" ;
else print_usage "$@" ; echo >&2 "Unknown argument: $1"; exit 1;
fi
