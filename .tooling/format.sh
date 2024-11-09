#!/bin/bash
set -x -e
cd "$(dirname "$0")"
cd ..
dart run build_runner build
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
