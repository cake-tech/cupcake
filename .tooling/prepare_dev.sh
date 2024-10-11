#!/bin/bash
set -x -e
cd "$(dirname "$0")"
./format.sh
cd ..
cat > android/key.properties <<EOF
storePassword=hunter1
keyPassword=hunter1
keyAlias=upload
storeFile=../../.tooling/debug-keystore.jks
EOF
