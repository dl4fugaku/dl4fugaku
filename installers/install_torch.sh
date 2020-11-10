#!/bin/bash -x

. activate.sh

export USE_LAPACK=1
export USE_NNPACK=0
export USE_XNNPACK=0
export USE_NATIVE_ARCH=1
export MAX_JOBS=$(nproc)

# Build PyTorch
cd ${DOWNLOAD_PATH}/pytorch/third_party/ideep/
rm -rf mkl-dnn
cp -rf ${DOWNLOAD_PATH}/dnnl_aarch64 mkl-dnn
cd mkl-dnn/third_party/
mkdir build_xed_aarch64
cd build_xed_aarch64/
../xbyak_translator_aarch64/translator/third_party/xed/mfile.py --shared examples install --cc="${CC}" --cxx="${CXX}"
cd kits/
ln -sf xed-install-base-* xed
cd ../../../../../../
python3 setup.py install
ln -sf ${DOWNLOAD_PATH}/pytorch/third_party/ideep/mkl-dnn/third_party/build_xed_aarch64/kits/xed/lib/libxed.so ${PREFIX}/lib/libxed.so

