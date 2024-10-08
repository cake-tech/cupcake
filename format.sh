#!/bin/bash
set -x -e
cd lib

for dir in coins themes utils view_model views widgets;
do
  pushd $dir
    dart fix --apply
    dart format .
  popd
  dart format main.dart
done

flutter gen-l10n