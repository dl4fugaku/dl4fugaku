#!/bin/bash

. activate.sh

cd ${DOWNLOAD_PATH}/sentencepiece
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ..
make -j $(nproc)
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -P cmake_install.cmake
export PKG_CONFIG_PATH=$(pwd)
# cmake --install . --target install
# ldconfig -v

pip install ninja

cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed -e "s;#prefix = .*;prefix = \"${PREFIX}\";"  > config.toml
# ./x.py build 
./x.py install

pip install transformers

