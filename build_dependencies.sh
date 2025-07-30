commandExist() {
  which $1 > /dev/null && echo '1' && return;
  echo '0';
}

source ~/.profile

CURRENT_FILE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && (pwd -W 2> /dev/null || pwd))

#  RUST INSTALL
if [ $(commandExist 'cargo') == "1" ]; then
  echo "RUST ALREADY INSTALLED TO YOUR OS";
else
  echo "CARGO NOT FOUND";
  echo "INSTALL RUST TO YOUR OS ?";
  echo "y / n ?";
  read answer
  if [ $answer == "y" ]; then
    if [ $(commandExist 'curl') != "1" ]; then
      echo "Please install curl";
      exit 0;
    fi
    echo "INSTALL RUST...";
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source ~/.profile
    source "$HOME/.cargo/env"
  else
    echo "RUST NOT INSTALLED. EXIT.";
    exit 0;
  fi
fi;
source "$HOME/.cargo/env" || true
rustup update

echo $'\nINSTALLATION RUST COMPLETE'



# DEPENDENCIES

if [ ! -d "./Dependencies" ]; then
  mkdir ./Dependencies
fi
cd Dependencies

# INSTALL ever-sdk
if [ ! -d "./ever-sdk" ]; then
  git clone https://github.com/tonlabs/ever-sdk.git
fi
cd ./ever-sdk && git reset --hard HEAD && git pull --ff-only
# git reset --hard 3cfcb2516aa5e64e8cb9992605838e2f90bfe789
cargo update

HEADER="$(pwd)/ever_client/tonclient.h"
DYLIB="$(pwd)/target/release/libton_client.dylib"

# BUILD ARCHITECTURES

if [ `uname -s` = Darwin ]; then
  
  rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

  if [ `uname -m` = arm64 ]; then
    echo 'DEBUG FOR aarch64-apple-ios-sim'
    cargo build --target aarch64-apple-ios-sim
  elif [ `uname -m` = x86_64 ]; then
    echo 'RELEASE FOR x86_64-apple-ios'
    cargo build --release --target x86_64-apple-ios

    echo 'DEBUG FOR x86_64-apple-ios'
    cargo build --target x86_64-apple-ios
  else
    echo 'THIS ONLY MACOS' && exit 1
  fi

  echo 'RELEASE FOR aarch64-apple-ios'
  cargo build --release --target aarch64-apple-ios

  echo 'DEBUG FOR aarch64-apple-ios'
  cargo build --target aarch64-apple-ios

  echo 'RELEASE FOR CURRENT OS'
  cargo build --release
else
  echo 'RELEASE FOR CURRENT OS'
  cargo build --release
fi


if [ `uname -s` = Darwin ]; then
  cd ../../ && swift ./cut_dependencies.swift

  # MAKE SYSTEM PC FILE  
  if [ $(commandExist 'port') == "1" ]; then
    MACOS_LIB_INCLUDE_DIR="/opt/local"
    echo "CHOOSE MACOS MACPORT INCLUDE DIR";
  fi

  if [ $(commandExist 'brew') == "1" ]; then
    if [ -d "/opt/homebrew" ]; then
      MACOS_LIB_INCLUDE_DIR="/opt/homebrew"
      echo "CHOOSE MACOS HOMEBREW /opt/homebrew";
    else
      MACOS_LIB_INCLUDE_DIR="/usr/local"
      echo "CHOOSE MACOS HOMEBREW /usr/local";
    fi
  fi

  if [ $(commandExist 'port') == "1" ]; then
    echo "...";
  elif [ $(commandExist 'brew') == "1" ]; then
    echo "...";
  else
    echo 'ERROR: homebrew or macport is not installed'
  fi

  MACOS_PKG_CONFIG=$'prefix='"$MACOS_LIB_INCLUDE_DIR"'
  exec_prefix=${prefix}
  includedir=${prefix}/include
  libdir=${exec_prefix}/lib

  Name: ton_client
  Description: ton_client
  Version: 1.0.0
  Cflags: -I${includedir}
  Libs: -L${libdir} -lton_client'

  if [[ -f "./libton_client.pc" ]]; then
    rm ./libton_client.pc
  else
    echo "OK: libton_client.pc already deleted"
  fi

  echo ""
  if [[ -f "$HEADER" ]]; then
    echo "CHECK: $HEADER - EXIST"
  else
    echo ""
    echo "ERROR: $HEADER - FILE NOT FOUND"
    exit 1;
  fi

  echo ""
  echo "Create symbolic link tonclient.h"
  if [[ -h "${MACOS_LIB_INCLUDE_DIR}/include/tonclient.h" ]]; then
    sudo rm ${MACOS_LIB_INCLUDE_DIR}/include/tonclient.h
    echo "OK: ${MACOS_LIB_INCLUDE_DIR}/include/tonclient.h old symlink deleted and will create new"
  fi
  echo "$HEADER ${MACOS_LIB_INCLUDE_DIR}/include/tonclient.h"
  sudo ln -s $HEADER ${MACOS_LIB_INCLUDE_DIR}/include/tonclient.h || echo "ERROR: symbolic link tonclient.h already exist"
  echo ""
  echo "Create symbolic link libton_client.dylib"
  if [[ -h "${MACOS_LIB_INCLUDE_DIR}/lib/libton_client.dylib" ]]; then
    sudo rm ${MACOS_LIB_INCLUDE_DIR}/lib/libton_client.dylib
    echo "OK: ${MACOS_LIB_INCLUDE_DIR}/lib/libton_client.dylib old symlink deleted and will create new"
  fi
  sudo ln -s $DYLIB ${MACOS_LIB_INCLUDE_DIR}/lib/libton_client.dylib || echo "ERROR: symbolic link libton_client.dylib already exist"
  echo "${DYLIB} to ${MACOS_LIB_INCLUDE_DIR}/lib/libton_client.dylib"

  echo ""
  echo "Copy pc file"
  echo "$MACOS_PKG_CONFIG" >> libton_client.pc
  sudo mv libton_client.pc ${MACOS_LIB_INCLUDE_DIR}/lib/pkgconfig/libton_client.pc
  echo "libton_client.pc to ${MACOS_LIB_INCLUDE_DIR}/lib/pkgconfig/libton_client.pc"
  
  > $CURRENT_FILE_PATH/Everspace-Bridging-Header.h
cat >$CURRENT_FILE_PATH/Everspace-Bridging-Header.h <<EOL
//
//  Everspace-Bridging-Header.h
//  Everspace
//
//  Created by Oleh Hudeichuk on 03.05.2022.
//

#ifndef Everspace_Bridging_Header_h
#define Everspace_Bridging_Header_h

#import "stdbool.h"
#import "tonclient.h"

#endif /* Everspace_Bridging_Header_h */
EOL




else





  LINUX_LIB_INCLUDE_DIR="/usr"
  
  
  LINUX_PKG_CONFIG=$'prefix='"$LINUX_LIB_INCLUDE_DIR"'
  exec_prefix=${prefix}
  includedir=${prefix}/include
  libdir=${exec_prefix}/lib

  Name: ton_client
  Description: ton_client
  Version: 1.0.0
  Cflags: -I${includedir}
  Libs: -L${libdir} -lton_client'

  HEADER="$(pwd)/ever_client/tonclient.h"

  echo ""
  if [[ -f "$HEADER" ]]; then
    echo "CHECK: $HEADER - EXIST"
  else
    echo ""
    echo "ERROR: $HEADER - FILE NOT FOUND"
    exit 1;
  fi

  if [[ -f "./libton_client.pc" ]]; then
    rm ./libton_client.pc
  else
    echo "OK: libton_client.pc already deleted"
  fi

  echo "INSTALL TO LINUX"
  echo "Create symbolic link tonclient.h"
  if [[ -h "${LINUX_LIB_INCLUDE_DIR}/include/tonclient.h" ]]; then
    sudo rm ${LINUX_LIB_INCLUDE_DIR}/include/tonclient.h
    echo "OK: ${LINUX_LIB_INCLUDE_DIR}/include/tonclient.h old symlink already deleted and will create new"
  fi
  sudo cp $HEADER ${LINUX_LIB_INCLUDE_DIR}/include/tonclient.h || echo "ERROR: symbolic link tonclient.h already exist"

  DYLIB="$(pwd)/target/release/libton_client.so"
  echo ""
  echo "Create symbolic link libton_client.so"
  if [ -h "${LINUX_LIB_INCLUDE_DIR}/lib/libton_client.so" ]; then
    sudo rm ${LINUX_LIB_INCLUDE_DIR}/lib/libton_client.so
    echo "OK: ${LINUX_LIB_INCLUDE_DIR}/lib/libton_client.so old symlink already deleted and will create new"
  fi
  sudo cp $DYLIB ${LINUX_LIB_INCLUDE_DIR}/lib/libton_client.so || echo "ERROR: symbolic link libton_client.so already exist"

  
  echo "$LINUX_PKG_CONFIG" >> libton_client.pc
  sudo mv libton_client.pc ${LINUX_LIB_INCLUDE_DIR}/lib/pkgconfig/libton_client.pc
fi


rm -rf ./Dependencies
echo $'\nINSTALLATION TON-SDK COMPLETE'




















