#!/bin/bash
set -x -e
pushd lib
  for dir in coins themes utils view_model views widgets;
  do
    pushd $dir
      dart fix --apply
      dart format .
    popd
    dart format main.dart
  done
popd
flutter gen-l10n