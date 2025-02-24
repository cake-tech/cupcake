#!/bin/bash
set -x -e
cd "$(dirname "$0")"
cd ..
dart run build_runner build --delete-conflicting-outputs
dart fix --apply .
dart format .
flutter gen-l10n
