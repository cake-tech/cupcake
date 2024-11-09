#!/bin/bash

# Script designed to build (or download) monero_c
# usage: 
# ./build_moneroc.sh 
# --prebuild - allow downloads of prebuilds
# --coin - monero/wownero
# --tag v0.18.3.3-RC45 - which tag to build / download
# --triplet x86_64-linux-android - which triplet to build / download
# --location android/app/src/main/jniLibs/x86_64 - where to but the libraries
# source: github.com/mrcyjanek/unnamed_monero_wallet
set -e

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

POSITIONAL_ARGS=()

ARG_PREBUILD=""
ARG_COIN=""
ARG_TAG=""
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
    head -11 "$0" | tail -9
    exit 1
fi

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
    # download prebuild
    GH_JSON="$(curl --retry 12 --retry-all-errors -L -o- 'https://api.github.com/repos/MrCyjaneK/monero_c/releases/tags/'"${ARG_TAG}" | tr -d '\r')"
    for release_url in $(echo "$GH_JSON" | jq -r '.assets[].browser_download_url' | tr -d '\r' | xargs)
    do
        asset_basename=$(urldecode $(basename $release_url) | tr -d '\r' | xargs)
        if [[ "$asset_basename" == ${ARG_COIN}_${ARG_TRIPLET}* ]];
        then            
            if [[ "$asset_basename" == *libwallet2_api_c* ]];
            then
                curl -L "$release_url" > "$ARG_LOCATION/$lib_name_prefix${asset_basename/${ARG_TRIPLET}_/}"
                unxz -f "$ARG_LOCATION/$lib_name_prefix${asset_basename/${ARG_TRIPLET}_/}"
            else
                curl -L "$release_url" > "$ARG_LOCATION/${asset_basename/${ARG_COIN}_${ARG_TRIPLET}_/}"
                unxz -f "$ARG_LOCATION/${asset_basename/${ARG_COIN}_${ARG_TRIPLET}_/}"
            fi
        fi
    done
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

    if ! ls ${BUILD_DIR}/release/${ARG_COIN}/${ARG_TRIPLET}_libwallet2_api_c*.xz
    then
        pushd "$BUILD_DIR"
            ./build_single.sh ${ARG_COIN} ${ARG_TRIPLET} -j$(nproc)
        popd
    fi

    for release in ${BUILD_DIR}/release/${ARG_COIN}/${ARG_TRIPLET}_*.xz;
    do
        asset_basename="$(basename $release)"
        if [[ "$asset_basename" == *libwallet2_api_c* ]];
        then
            cp "$release" "$ARG_LOCATION/$lib_name_prefix${ARG_COIN}_${asset_basename/${ARG_TRIPLET}_/}"
            unxz -f "$ARG_LOCATION/$lib_name_prefix${ARG_COIN}_${asset_basename/${ARG_TRIPLET}_/}"
        else
            cp "$release" "$ARG_LOCATION/${asset_basename/${ARG_TRIPLET}_/}"
            unxz -f "$ARG_LOCATION/${asset_basename/${ARG_TRIPLET}_/}"
        fi
    done
fi