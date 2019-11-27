#!/bin/bash

#
# Build EVERTims for Windows using MXE cross-compiler on Linux.
#

function indent
# To be able to indent outputs of cmake, make etc.
{
  sed 's/^/         /'
}

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

function find_mxe_libgnurx
# Find the MXE `libgnurx` package (M Cross Environment).
{
  if [ -f "$MXE_PATH/usr/x86_64-w64-mingw32.shared/installed/libgnurx" ]
  then
      echo -e "\e[32m-- Found MXE \`libgnurx\` package!"
  else
    echo -e "\e[31m-- Didn't find the \`libgnurx\` package from MXE!"
    echo -e "\e[35m-- Please make sure you've built the MXE \`libgnurx\` package for target \`x86_64-w64-mingw32.shared\`!"
    read -rsn1 -p $'\e[35m-- Do you want to build it now? This might take a while (~1 min)! (yY/nN)]\n' want_build_mxe_libgnurx
    case "$want_build_mxe_libgnurx" in
      y|Y) build_mxe_package libgnurx;;
      *) report_failure;;
    esac
  fi
}

function download_mxe
# Download the MXE (M Cross Environment).
{
  echo -e "\e[35m-- Starting MXE download..."
  cd $HOME
  git clone https://github.com/mxe/mxe.git | indent
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
    make MXE_TARGETS="x86_64-w64-mingw32.shared" $1 | indent
  else
    echo -e "\e[34m-- Password is required to be able to build the MXE \`$1\` package!"
    if [[ ! $(sudo echo 0) ]]; then exit; fi
    sudo make MXE_TARGETS="x86_64-w64-mingw32.shared" $1 | indent
  fi

  echo -e "\e[35m-- Finished MXE \`$1\` package build..."
}

function build_evertims
# Build the EVERTims application.
{
  echo -e "\e[35m-- Starting EVERTims build..."

  BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
  cd $BUILD_DIR

  if [ -d "win64" ]
  then
    rm -rf "win64"
  fi

  mkdir win64
  cd ..
  x86_64-w64-mingw32.shared-cmake --no-warn-unused-cli -I . -B build/win64 | indent
  cd $BUILD_DIR/win64
  make | indent

  # See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another.
  if [ ${PIPESTATUS[0]} -gt 0 ] || [ ${pipestatus[1]} -gt 0 ]
  then
    report_failure
  fi

  echo -e "\e[35m-- Finished EVERTims build..."
}

function install_evertims
# Install the EVERTims application.
{
  echo -e "\e[35m-- Starting EVERTims installation..."

  cd $BUILD_DIR/win64
  make DESTDIR="/home/springbok/Desktop" install | indent

  echo -e "\e[35m-- Finished EVERTims installation..."
}

function update_db
# Update the local files database to be able to locate MXE.
# This might take a while.
{
  echo -e "\e[34m-- Password is required to be able to update the file database!"
  if [[ ! $(sudo echo 0) ]]; then exit; fi
  sudo updatedb | indent

  MXE_PATH=$(locate mxe/Makefile | head -1)
}

function report_start
# Report a build/installation start.
{
  echo
  echo -e "\e[32m       _______     _______ ____ _____ _                 "
  echo -e "\e[32m      | ____\\ \\   / / ____|  _ \\_   _(_)_ __ ___  ___   "
  echo -e "\e[32m      |  _|  \\ \\ / /|  _| | |_) || | | | \'_ \` _ \\/ __|  "
  echo -e "\e[32m      | |___  \\ V / | |___|  _ < | | | | | | | | \\__ \\  "
  echo -e "\e[32m      |_____|  \\_/  |_____|_| \\_\\|_| |_|_| |_| |_|___/  "
  echo
  echo -e "\e[32m---------------------------------------------------------------"
  echo -e "\e[32m--                  Starting EVERTims build!                 --"
  echo -e "\e[32m---------------------------------------------------------------"
  echo
}

function report_success
# Report a build/installation success.
{
  echo
  echo -e "\e[32m---------------------------------------------------------------"
  echo -e "\e[32m--        EVERTims: Build and installation succesful!        --"
  echo -e "\e[32m---------------------------------------------------------------"
  echo
  exit
}

function report_failure
# Report a build/installation failure.
{
  echo
  echo -e "\e[31m---------------------------------------------------------------"
  echo -e "\e[31m--       EVERTims: Build or installation unsuccesful!        --"
  echo -e "\e[31m---------------------------------------------------------------"
  echo
  exit
}

source $HOME/.bash_profile

report_start

find_mxe
find_mxe_cc
find_mxe_cmake
find_mxe_libgnurx

build_evertims
install_evertims

report_success
