#!/bin/bash

. activate.sh

# Download jpegsrc
cd ${DOWNLOAD_PATH}
rm -rf jpeg-9d/
curl -O http://www.ijg.org/files/jpegsrc.v9d.tar.gz
tar xzvf jpegsrc.v9d.tar.gz

# Download Pillow
cd ${DOWNLOAD_PATH}
rm -rf Pillow
git clone https://github.com/python-pillow/Pillow.git
cd Pillow
git checkout 6.2.1 -b 6.2.1
sed -i "s;JPEG_ROOT = None;JPEG_ROOT = \"${PREFIX}/lib\";" setup.py

cd ${DOWNLOAD_PATH}
rm -rf vision
git clone https://github.com/pytorch/vision.git
cd vision
git checkout v0.5.0 -b v0.5.0

# Build and install
cd ${DOWNLOAD_PATH}/jpeg-9d/
./configure --prefix="${PREFIX}" --enable-shared
make clean
make -j$(nproc)
make install

cd ${DOWNLOAD_PATH}/Pillow
MAX_CONCURRENCY=8 CFLAGS="-I${PREFIX}/include" python setup.py install

cd ${DOWNLOAD_PATH}/vision
python setup.py clean
python setup.py install

