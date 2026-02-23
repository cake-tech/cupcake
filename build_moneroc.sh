#!/bin/bash

# Script designed to build (or download) monero_c
# usage:
# ./build_moneroc.sh
# --prebuild - allow downloads of prebuilds
# --coin - monero/wownero
# --tag v0.18.3.3-RC45 - tag, branch, or commit to check out
# --prebuild-tag v0.18.4.6-RC2 - GitHub release to download libs from (defaults to --tag)
# --triplet x86_64-linux-android - which triplet to build / download
# --location android/app/src/main/jniLibs/x86_64 - where to but the libraries
# source: github.com/mrcyjanek/unnamed_monero_wallet
set -e

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

POSITIONAL_ARGS=()

ARG_PREBUILD=""
ARG_COIN=""
ARG_TAG=""
ARG_PREBUILD_TAG=""
ARG_TRIPLET=""
ARG_LOCATION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --prebuild)
      ARG_PREBUILD="ON"
      shift
      ;;
    --tag)
      ARG_TAG="$2"
      shift
      shift
      ;;
    --prebuild-tag)
      ARG_PREBUILD_TAG="$2"
      shift
      shift
      ;;
    --triplet)
      ARG_TRIPLET="$2"
      shift
      shift
      ;;
    --location)
      ARG_LOCATION="$2"
      shift
      shift
      ;;
    --coin)
      ARG_COIN="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ "x$ARG_TAG" == "x" || "x$ARG_TRIPLET" == "x" || "x$ARG_LOCATION" == "x" || "x$ARG_COIN" == "x" ]];
then
    head -12 "$0" | tail -10
    exit 1
fi

# --branch only accepts tags/branches. Fetch the ref so commit SHAs work too.
function checkout_moneroc() {
    local dest="$1"
    rm -rf "${dest}"
    mkdir -p "${dest}"
    git -C "${dest}" init
    git -C "${dest}" remote add origin https://github.com/mrcyjanek/monero_c
    git -C "${dest}" fetch --depth=1 origin "${ARG_TAG}"
    git -C "${dest}" checkout --force FETCH_HEAD
}

if [[ "${ARG_TRIPLET}" == *android* ]];
then
    lib_name_prefix=lib
fi

if ! command -v jq;
then
    pushd $(mktemp -d)
        git clone --recursive https://github.com/jqlang/jq.git --depth=1
        cd jq
        autoreconf -i
        ./configure
        make -j$(nproc)
        make install
    popd
fi

if [[ ! "x$ARG_PREBUILD" == "x" ]];
then
    BUILD_DIR="$PWD/.cache/monero_c/${ARG_TAG}"
    if [[ ! -d "${BUILD_DIR}/impls" ]];
    then
        checkout_moneroc "${BUILD_DIR}"
    fi

    RELEASE_TAG="${ARG_PREBUILD_TAG:-$ARG_TAG}"
    # download prebuild
    GH_JSON="$(curl --retry 12 --retry-all-errors -L -o- 'https://api.github.com/repos/MrCyjaneK/monero_c/releases/tags/'"${RELEASE_TAG}" | tr -d '\r')"
    ASSET_URLS="$(echo "$GH_JSON" | jq -r '.assets[]?.browser_download_url' | tr -d '\r' | xargs)"
    if [[ "x$ASSET_URLS" == "x" ]];
    then
        echo "No release assets for tag '${RELEASE_TAG}'; --prebuild needs a GitHub release (set --prebuild-tag if --tag is a commit)"
        exit 1
    fi

    BUNDLE_URL=""
    for release_url in $ASSET_URLS
    do
        if [[ "$(basename $release_url)" == "release-bundle.zip" ]];
        then
            BUNDLE_URL="$release_url"
        fi
    done

    if [[ ! "x$BUNDLE_URL" == "x" ]];
    then
        BUNDLE_DIR="$PWD/.cache/monero_c/prebuild/${RELEASE_TAG}"
        mkdir -p "$BUNDLE_DIR"
        if [[ ! -f "$BUNDLE_DIR/release-bundle.zip" ]];
        then
            curl --retry 12 --retry-all-errors -L "$BUNDLE_URL" -o "$BUNDLE_DIR/release-bundle.zip.part"
            mv "$BUNDLE_DIR/release-bundle.zip.part" "$BUNDLE_DIR/release-bundle.zip"
        fi

        rm -rf "$BUNDLE_DIR/${ARG_TRIPLET}"
        unzip -q -o "$BUNDLE_DIR/release-bundle.zip" \
            "*/${ARG_TRIPLET}/lib${ARG_COIN}_wallet2_api_c.*" \
            -d "$BUNDLE_DIR/${ARG_TRIPLET}" || true

        FOUND=""
        for release in "$BUNDLE_DIR/${ARG_TRIPLET}"/*/"${ARG_TRIPLET}"/lib${ARG_COIN}_wallet2_api_c.*
        do
            [[ -f "$release" ]] || continue
            FOUND="ON"
            asset_basename="$(basename $release)"
            if [[ "${ARG_TRIPLET}" == *-apple-ios* ]];
            then
                cp "$release" "$ARG_LOCATION/${ARG_COIN}_libwallet2_api_c.${asset_basename##*.}"
            else
                cp "$release" "$ARG_LOCATION/$asset_basename"
            fi
        done
        if [[ "x$FOUND" == "x" ]];
        then
            echo "release-bundle.zip of '${RELEASE_TAG}' has no ${ARG_COIN} library for ${ARG_TRIPLET}"
            exit 1
        fi
    else
        for release_url in $ASSET_URLS
        do
            asset_basename=$(urldecode $(basename $release_url) | tr -d '\r' | xargs)
            if [[ "$asset_basename" == ${ARG_COIN}_${ARG_TRIPLET}* ]];
            then
                if [[ "$asset_basename" == *libwallet2_api_c* ]];
                then
                    curl -L "$release_url" > "$ARG_LOCATION/$lib_name_prefix${asset_basename/${ARG_TRIPLET}_/}"
                    unxz -f "$ARG_LOCATION/$lib_name_prefix${asset_basename/${ARG_TRIPLET}_/}" || true
                else
                    curl -L "$release_url" > "$ARG_LOCATION/${asset_basename/${ARG_COIN}_${ARG_TRIPLET}_/}"
                    unxz -f "$ARG_LOCATION/${asset_basename/${ARG_COIN}_${ARG_TRIPLET}_/}" || true
                fi
            fi
        done
    fi
else
    # build from source
    BUILD_DIR="$PWD/.cache/monero_c/${ARG_TAG}"
    if [[ -d "${BUILD_DIR}" ]];
    then
        echo "Cache directory exists at '${BUILD_DIR}'. In case of build issues try removing the directory"
    else
        mkdir -p "$BUILD_DIR"
        git clone https://github.com/mrcyjanek/monero_c "$BUILD_DIR"
        pushd "$BUILD_DIR"
            git checkout "$ARG_TAG"
            git submodule update --init --force --recursive
            ./apply_patches.sh monero
            ./apply_patches.sh wownero
        popd
    fi
    COPIED=""

    if ! ls ${BUILD_DIR}/release/${ARG_COIN}/${ARG_TRIPLET}_libwallet2_api_c*
    then
        pushd "$BUILD_DIR"
            env -i PATH="$PATH" HOME="$HOME" ./build_single.sh ${ARG_COIN} ${ARG_TRIPLET} -j$(nproc)
        popd
    fi

    for release in ${BUILD_DIR}/release/${ARG_COIN}/${ARG_TRIPLET}_*;
    do
        asset_basename="$(basename $release)"
        if [[ "$asset_basename" == *libwallet2_api_c* ]];
        then
            cp "$release" "$ARG_LOCATION/$lib_name_prefix${ARG_COIN}_${asset_basename/${ARG_TRIPLET}_/}"
            unxz -f "$ARG_LOCATION/$lib_name_prefix${ARG_COIN}_${asset_basename/${ARG_TRIPLET}_/}" || true
        else
            cp "$release" "$ARG_LOCATION/${asset_basename/${ARG_TRIPLET}_/}"
            unxz -f "$ARG_LOCATION/${asset_basename/${ARG_TRIPLET}_/}" || true
        fi
    done
fi
