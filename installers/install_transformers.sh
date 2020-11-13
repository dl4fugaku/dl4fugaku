#!/bin/bash
#SBATCH --time=02:00:00

. activate.sh

# Download sentencepiece transformers requirements
cd ${DOWNLOAD_PATH}
rm -rf sentencepiece
git clone git@github.com:google/sentencepiece.git
git clone https://github.com/rust-lang/rust.git

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

pip install ninja

cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed \
	-e "s;#prefix = .*;prefix = \"${PREFIX}\";" \
	-e "s;#sysconfdir = .*;sysconfdir = \"${PREFIX}/etc\";" \
	> config.toml
# ./x.py build 
./x.py install
./x.py install cargo

pip install transformers

