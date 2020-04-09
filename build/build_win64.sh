#!/bin/bash

#
# Build EVERT and EVERTims for Windows using MXE cross-compiler on Linux.
# 

set -e

BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Build EVERT and EVERTims
$BUILD_DIR/../evert/build/build_win64.sh
$BUILD_DIR/../evertims/build/build_win64.sh

# Copy the required files to the project's build directory.
cd $BUILD_DIR

if [ -d "win64" ]
then
  rm -rf "win64"
fi

mkdir win64

cp $BUILD_DIR/../evert/build/win64/libevert.dll win64/
cp $BUILD_DIR/../evertims/build/win64/evertims.exe win64/
cp $BUILD_DIR/../evertims/build/win64/libgcc_s_seh-1.dll win64/
cp $BUILD_DIR/../evertims/build/win64/libstdc++-6.dll win64/
cp $BUILD_DIR/../evertims/build/win64/libwinpthread-1.dll win64/
