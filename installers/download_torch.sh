#!/bin/bash
# download_torch.sh

. common.sh

# Download cmake
cd ${DOWNLOAD_PATH}
rm -rf cmake*
curl -O https://cmake.org/files/v3.11/cmake-3.11.4.tar.gz
tar xvf cmake-3.11.4.tar.gz

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
patch -p1 < ${UPLOAD_PATH}/fj_pytorch.patch
cd ../

