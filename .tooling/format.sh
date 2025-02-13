#!/bin/bash
set -x -e
cd "$(dirname "$0")"
cd ..

pushd lib/l10n
    for file in *.arb;
    do
        jq 'to_entries 
            | group_by(.key | sub("^@"; ""))
            | map( sort_by(.key | startswith("@")) | map({ (.key): .value }) | add )
            | add' $file > $file.tmp || rm $file.tmp
        mv $file.tmp $file
    done
popd

dart run build_runner build --delete-conflicting-outputs
dart fix --apply .
dart format .

flutter gen-l10n
