#!/bin/bash

. activate.sh

# Download dnnl
cd ${DOWNLOAD_PATH}
rm -rf dnnl_aarch64
git clone https://github.com/fujitsu/dnnl_aarch64.git
cd dnnl_aarch64/
git submodule sync
git submodule update --init --recursive

# Download torch
cd ${DOWNLOAD_PATH}
rm -rf pytorch
git clone https://github.com/pytorch/pytorch.git
cd pytorch
git checkout -b v1.5.0 refs/tags/v1.5.0
git submodule sync
git submodule update --init --recursive
patch -p1 < ${PATCH_DIR}/fj_pytorch.patch

# Build PyTorch
export USE_LAPACK=1
export USE_NNPACK=0
export USE_XNNPACK=0
export USE_NATIVE_ARCH=1
export MAX_JOBS=$(nproc)

cd ${DOWNLOAD_PATH}/pytorch/third_party/ideep/
rm -rf mkl-dnn
cp -rf ${DOWNLOAD_PATH}/dnnl_aarch64 mkl-dnn
cd mkl-dnn/third_party/
mkdir build_xed_aarch64
cd build_xed_aarch64/
../xbyak_translator_aarch64/translator/third_party/xed/mfile.py --shared examples install --cc="${CC}" --cxx="${CXX}"
cd kits/
ln -sf xed-install-base-* xed

cd ${DOWNLOAD_PATH}/pytorch
python setup.py install
cp -L ${DOWNLOAD_PATH}/pytorch/third_party/ideep/mkl-dnn/third_party/build_xed_aarch64/kits/xed/lib/libxed.so ${PREFIX}/lib/libxed.so

