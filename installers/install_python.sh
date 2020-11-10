#!/bin/bash

. common.sh

export OPT=-O3
export ac_cv_opt_olimit_ok=no
export ac_cv_olimit_ok=no
export ac_cv_cflags_warn_all=''

# Build PyThon 3.8.2
cd ${DOWNLOAD_PATH}/Python-3.8.2
./configure --enable-shared --disable-ipv6 --target=aarch64 --build=aarch64 --prefix=${PREFIX}
make clean
make -j$(nproc)
# mv python python_org
# ${CXX} --linkfortran -SSL2 -Kopenmp -Nlibomp -o python Programs/python.o -L. -lpython3.8 -ldl  -lutil   -lm
make install
${PREFIX}/bin/python3.8 -m venv ${VENV_PATH}
. ${VENV_PATH}/bin/activate

pip install cython
pip install PyYAML
pip install numpy
