#!/bin/sh
set -x
# Assume we are in scripts/ios
cd "$(dirname "$0")"
IOS_DIR="$(pwd)"
TARGET_DYLIB_NAME="libwallet2_api_c.dylib"
DYLIB_NAME="monero_libwallet2_api_c.dylib"
TEMP_DIR="$(mktemp -d)"
cp -a "${IOS_DIR}/${DYLIB_NAME}" "${TEMP_DIR}/${TARGET_DYLIB_NAME}"
DYLIB_LINK_PATH="$(realpath "${TEMP_DIR}/${TARGET_DYLIB_NAME}")"
FRWK_DIR="$(realpath "${IOS_DIR}/MoneroWallet.framework")"

if [ ! -f $DYLIB_LINK_PATH ]; then
    echo "Dylib is not found by the link: ${DYLIB_LINK_PATH}"
    exit 0
fi

cd "$FRWK_DIR" # go to iOS framework dir
lipo -create "$DYLIB_LINK_PATH" -output MoneroWallet
rm -rf "$TEMP_DIR"