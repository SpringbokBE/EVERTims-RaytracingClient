#!/bin/bash

#
# Build libevert for Windows using MXE cross-compiler on Linux.
#

function find_mxe
# Find the MXE (M Cross Environment).
{
  MXE_PATH=$(locate mxe/Makefile | head -1)

  if [ -z "$MXE_PATH" ]
  then
    echo -e "\e[31m-- Didn't find MXE!"
    echo -e "\e[35m-- Please make sure you've downloaded the MXE source from 'https://github.com/mxe/mxe.git'!"
    read -rsn1 -p $'\e[34m-- Update your file database to find MXE? (yY/nN)]\n' want_update_db
    case "$want_update_db" in
      y|Y) update_db;;
    esac
    if [ -z "$MXE_PATH" ]
    then
      read -rsn1 -p $'\e[34m-- Do you want to download it now? (yY/nN)]\n' want_download_mxe
      case "$want_download_mxe" in
        y|Y) download_mxe;;
        *) report_failure;
      esac
    else
      MXE_PATH=$(dirname $MXE_PATH)
    fi
  else
    MXE_PATH=$(dirname $MXE_PATH)

    echo -e "\e[32m-- Found MXE!"
  fi
}

function find_mxe_cc
# Find the MXE `cc` package (M Cross Environment).
{
  if [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/ccache" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/gmp" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/isl" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/mpc" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/mpfr" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/mxe-conf" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/pkgconf" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/binutils" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/cc" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/ccache" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/gcc" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/mingw-w64" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/mxe-conf" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/pkgconf" ]
  then
      echo -e "\e[32m-- Found MXE \`cc\` package!"
  else
    echo -e "\e[31m-- Didn't find the \`cc\` package from MXE!"
    echo -e "\e[35m-- Please make sure you've built the MXE \`cc\` package for target \`x86_64-w64-mingw32.shared\`!"
    read -rsn1 -p $'\e[35m-- Do you want to build it now? This might take a while (~30 min)! (yY/nN)]\n' want_build_mxe_cc
    case "$want_build_mxe_cc" in
      y|Y) build_mxe_package cc;;
      *) report_failure;;
    esac
    echo "export PATH=$MXE_PATH/usr/bin:\$PATH" >> $HOME/.bash_profile
    source $HOME/.bash_profile
  fi
}

function find_mxe_cmake
# Find the MXE `cmake` package (M Cross Environment).
{
  if [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/cmake" ] &&
     [ -f "$MXE_PATH/usr/x86_64-pc-linux-gnu/installed/cmake-conf" ] &&
     [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/cmake-conf" ]
  then
      echo -e "\e[32m-- Found MXE \`cmake\` package!"
  else
    echo -e "\e[31m-- Didn't find the \`cmake\` package from MXE!"
    echo -e "\e[35m-- Please make sure you've built the MXE \`cmake\` package for target \`x86_64-w64-mingw32.shared\`!"
    read -rsn1 -p $'\e[35m-- Do you want to build it now? This might take a while (~15 min)! (yY/nN)]\n' want_build_mxe_cmake
    case "$want_build_mxe_cmake" in
      y|Y) build_mxe_package cmake;;
      *) report_failure;;
    esac
  fi
}

function download_mxe
# Download the MXE (M Cross Environment).
{
  echo -e "\e[35m-- Starting MXE download..."
  cd $HOME
  git clone https://github.com/mxe/mxe.git
  MXE_PATH="$HOME/mxe"

  echo -e "\e[35m-- Finished MXE download..."
}

function build_mxe_package
# Build the given MXE package (M Cross Environment).
{
  echo -e "\e[35m-- Starting MXE \`$1\` package build..."

  cd $MXE_PATH

  if [ -w $MXE_PATH ]
  then
    make MXE_TARGETS="x86_64-w64-mingw32.shared" $1
  else
    echo -e "\e[34m-- Password is required to be able to build the MXE \`$1\` package!"
    if [[ ! $(sudo echo 0) ]]; then exit; fi
    sudo make MXE_TARGETS="x86_64-w64-mingw32.shared" $1
  fi

  echo -e "\e[35m-- Finished MXE \`$1\` package build..."
}

function build_libevert
# Build the libevert library.
{
  echo -e "\e[35m-- Starting libevert build..."

  BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
  cd $BUILD_DIR

  if [ -d "win64" ]
  then
    rm -rf "win64"
  fi

  mkdir win64
  cd ..
  x86_64-w64-mingw32.shared-cmake -I . -B build/win64
  cd $BUILD_DIR/win64
  make

  echo -e "\e[35m-- Finished libevert build..."
}

function update_db
# Update the local files database to be able to locate MXE.
# This might take a while.
{
  echo -e "\e[34m-- Password is required to be able to update the file database!"
  if [[ ! $(sudo echo 0) ]]; then exit; fi
  sudo updatedb

  MXE_PATH=$(locate mxe/Makefile | head -1)
}

function report_failure
# Report a build failure.
{
  echo -e "\e[31m-- Build unsuccesful!"
  exit
}

find_mxe
find_mxe_cc
find_mxe_cmake

build_libevert
