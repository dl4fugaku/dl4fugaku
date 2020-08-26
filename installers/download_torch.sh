#!/bin/bash

. common.sh

cd ${DOWNLOAD_PATH}
# download_torch.sh
rm -rf dnnl_aarch64
git clone https://github.com/fujitsu/dnnl_aarch64.git
cd dnnl_aarch64/
git submodule sync
git submodule update --init --recursive
cd ../

rm -rf pytorch
git clone https://github.com/pytorch/pytorch.git
cd pytorch
git checkout -b v1.5.0 refs/tags/v1.5.0
git submodule sync
git submodule update --init --recursive
cd ../

