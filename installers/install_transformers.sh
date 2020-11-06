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

cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed -e "s+#prefix = .*+prefix = \"${PREFIX}/.local\"+" -e 's/#ninja.*/ninja = false/' > config.toml
echo "Start ./x.py build"
RUST_BACKTRACE=1 ./x.py build 
echo "Start ./x.py install"
RUST_BACKTRACE=1 ./x.py install

#export PKG_CONFIG_PATH=$(pwd)
#pip install transformers

