#!/usr/bin/env bash

set -e

runmaude()  {
  maude -no-banner -no-wrap <(echo 'set show stats off . set show timing off .') "$@"
}

dodiff() {
  git --no-pager diff --no-index --word-diff "$@"
}

test_main() {
  for t in t/*.maude; do
    test_actual=$(mktemp -t maude-run-XXXXXX)
    runmaude "$t" </dev/null &> "$test_actual"
    dodiff "$test_actual" "$t.expected"
  done
  echo 'Passed.'
}

update_expected() {
    for t in "$@"; do
        runmaude "$t" > "$t.expected"
    done
}

print_usage() {
    echo """
    Usage:

        $0
            run tests

        $0 update test_file1 [test_file2...]
            update expected output
    """
}


  if [[ "$#" = 0        ]] ; then test_main;
elif [[ "$1" = "update" ]] ; then shift; update_expected "$@" ;
elif [[ "$1" = "help"   ]] ; then shift; print_usage     "$@" ;
else print_usage "$@" ; echo >&2 "Unknown argument: $1"; exit 1;
fi
