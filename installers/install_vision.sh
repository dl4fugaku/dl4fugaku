#!/bin/bash

. common.sh

cd ${PYTORCH_INSTALL_PATH}/${VENV_NAME}
source bin/activate

cd ${DOWNLOAD_PATH}
cd jpeg-9d/
./configure --prefix="${PREFIX}/.local" --enable-shared
make clean
make -j$(nproc)
make install

cd ${DOWNLOAD_PATH}
cd Pillow
MAX_CONCURRENCY=8 CFLAGS="-I${PREFIX}/.local/include" python3 setup.py install

cd ${DOWNLOAD_PATH}/vision
python3 setup.py clean
python3 setup.py install

