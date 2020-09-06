#!/bin/bash

. common.sh

export USE_LAPACK=1
export USE_NNPACK=0
export USE_XNNPACK=0
export USE_NATIVE_ARCH=1
export MAX_JOBS=48

# Build cmake
cd ${DOWNLOAD_PATH}/cmake-3.11.4
./configure --prefix=${PREFIX}/.local
make clean
make -j$(nproc)
make install

# Create venv
cd ${PYTORCH_INSTALL_PATH}
${PREFIX}/.local/bin/python3.8 -m venv ${VENV_NAME}
cd ${VENV_NAME}
source bin/activate

# Install requires
pip3 install PyYAML
pip3 install numpy

# Build PyTorch
cd ${DOWNLOAD_PATH}/pytorch/
cd third_party/ideep/
rm -rf mkl-dnn
cp -rf ${DOWNLOAD_PATH}/dnnl_aarch64 mkl-dnn
cd mkl-dnn/third_party/
mkdir build_xed_aarch64
cd build_xed_aarch64/
../xbyak_translator_aarch64/translator/third_party/xed/mfile.py --shared examples install --cc="${TCSDS_PATH}/bin/fcc -Nclang -Kfast" --cxx="${TCSDS_PATH}/bin/FCC -Nclang -Kfast"
cd kits/
ln -sf xed-install-base-* xed
cd ../../../../../../
python3 setup.py install
ln -sf ${DOWNLOAD_PATH}/pytorch/third_party/ideep/mkl-dnn/third_party/build_xed_aarch64/kits/xed/lib/libxed.so ${PREFIX}/.local/lib/libxed.so

