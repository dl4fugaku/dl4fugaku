#!/bin/bash

. common.sh

cd ${PYTORCH_INSTALL_PATH}/${VENV_NAME}
source bin/activate

cd ${DOWNLOAD_PATH}/sentencepiece
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}/.local ..
make -j $(nproc)
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX}/.local -P cmake_install.cmake
# cmake --install . --target install
# ldconfig -v
export PKG_CONFIG_PATH=$(pwd)
pip install transformers
