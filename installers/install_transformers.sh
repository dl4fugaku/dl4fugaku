#!/bin/bash

. activate.sh

# Download
cd ${DOWNLOAD_PATH}
rm -rf sentencepiece
git clone git@github.com:google/sentencepiece.git

# Build and install
cd ${DOWNLOAD_PATH}/sentencepiece
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ..
make -j $(nproc)
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -P cmake_install.cmake
export PKG_CONFIG_PATH=$(pwd)
# cmake --install . --target install
# ldconfig -v

pip install transformers
