#!/bin/bash

. activate.sh

cd ${DOWNLOAD_PATH}/jpeg-9d/
./configure --prefix="${PREFIX}" --enable-shared
make clean
make -j$(nproc)
make install

cd ${DOWNLOAD_PATH}/Pillow
MAX_CONCURRENCY=8 CFLAGS="-I${PREFIX}/include" python3 setup.py install

cd ${DOWNLOAD_PATH}/vision
python3 setup.py clean
python3 setup.py install

