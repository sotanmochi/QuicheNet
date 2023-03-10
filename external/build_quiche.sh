#!/bin/sh

cd ./quiche

set -e

LIB="quiche"
OPT="--release --features ffi"
DST="../../lib"

UNAME=`uname`

[ $UNAME = Linux ] && `grep -i -q "microsoft" /proc/version` && IS_WSL="WSL"

[ -n "$1" ] && [ $1 = android ] && IS_ANDROID="Android"

if [ -n "$1" ] && [ $1 = ios ]; then
    IS_IOS="iOS"
    if ! `grep -i -q "staticlib" Cargo.toml`; then
        echo '** iOS build error: create-type should be staticlib.'
        echo 'Please modify Cargo.toml to change crate-type to "staticlib".'
        exit 1
    fi
fi

if [ $IS_IOS ]; then

    echo '------------------------------'
    echo 'Building quiche for iOS'
    echo '------------------------------'

    TARGET="aarch64-apple-ios"

    # set -x
    # cargo build $OPT --target=$TARGET
    # cp target/${TARGET}/release/lib${LIB}.a ${DST}/iOS/lib${LIB}.a

elif [ $IS_ANDROID ]; then

    echo '------------------------------'
    echo 'Building quiche for Android'
    echo '------------------------------'

    TARGET="aarch64-linux-android"

    if [ -z "$ANDROID_NDK" ]; then
        echo '** Android build error: $ANDROID_NDK is not defined.'
        exit 1
    fi

    # export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang"

    # set -x
    # cargo build $OPT --target=$TARGET
    # cp target/${TARGET}/release/lib${LIB}.so ${DST}/Android/lib${LIB}.so

elif [ $IS_WSL ]; then

    echo '------------------------------'
    echo 'Building quiche for Windows'
    echo '------------------------------'

    if ! command -v nasm > /dev/null; then
        echo 'The following packages will be installed.'
        echo '  nasm'
        read -p 'Do you want to continue? (y/n): ' REPLY
        if [ $REPLY = "y" ] ; then
            sudo apt install nasm
        else
            exit
        fi
    fi

    TARGET="x86_64-pc-windows-gnu"

    set -x
    cargo build $OPT --target=$TARGET
    cp target/${TARGET}/release/${LIB}.dll ${DST}/Windows/${LIB}.dll

elif [ $UNAME = Linux ]; then

    echo '------------------------------'
    echo 'Building quiche for Linux'
    echo '------------------------------'

    # set -x
    # cargo build $OPT
    # cp target/release/lib${LIB}.so ${DST}/Linux/lib${LIB}.so

elif [ $UNAME = Darwin ]; then

    echo '------------------------------'
    echo 'Building quiche for macOS'
    echo '------------------------------'

    TARGET_ARM="aarch64-apple-darwin"
    TARGET_X86="x86_64-apple-darwin"

    # set -x

    # cargo build $OPT --target=$TARGET_ARM
    # cargo build $OPT --target=$TARGET_X86

    # lipo -create -output ${LIB}.bundle \
    #   target/${TARGET_ARM}/release/lib${LIB}.dylib \
    #   target/${TARGET_X86}/release/lib${LIB}.dylib

    # DST_FILE="${DST}/macOS/${LIB}.bundle"
    # [ -e $DST_FILE ] && rm $DST_FILE
    # cp ${LIB}.bundle $DST_FILE

fi
