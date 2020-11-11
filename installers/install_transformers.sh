#!/bin/bash

. activate.sh

cd ${DOWNLOAD_PATH}/sentencepiece
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ..
make -j $(nproc)
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -P cmake_install.cmake
# cmake --install . --target install
# ldconfig -v

cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed \
	-e "s;#prefix = .*;prefix = \"${PREFIX}\";" \
	-e 's;#ninja.*;ninja = false;' \
	-e "s;#ar =.*;ar = \"$(which ar)\";" \
	> config.toml
echo "Start ./x.py build"
echo $PATH
AR=ar RUST_BACKTRACE=full ./x.py build 
echo "Start ./x.py install"
AR=ar RUST_BACKTRACE=full ./x.py install

export PKG_CONFIG_PATH=$(pwd)
pip install transformers

