#!/bin/bash

# install_toch.sh

export USE_LAPACK=1
export USE_NNPACK=0
export USE_XNNPACK=0
export USE_NATIVE_ARCH=1
export MAX_JOBS=48

# Create venv
cd ${PYTORCH_INSTALL_PATH}
${PREFIX}/.local/bin/python3.8 -m venv ${VENV_NAME}
cd ${VENV_NAME}
cp -rf ${DOWNLOAD_PATH}/pytorch pytorch
source bin/activate

# Install requires
pip3 install ${UPLOAD_PATH}/PyYAML-5.3-cp38-cp38-linux_aarch64.whl
pip3 install ${UPLOAD_PATH}/numpy-1.18.4-cp38-cp38-linux_aarch64.whl

# Build PyTorch
cd pytorch/
patch -p1 < ${UPLOAD_PATH}/fj_pytorch.patch
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
ln -sf ${PYTORCH_INSTALL_PATH}/${VENV_NAME}/pytorch/third_party/ideep/mkl-dnn/third_party/build_xed_aarch64/kits/xed/lib/libxed.so ${PREFIX}/.local/lib/libxed.so

