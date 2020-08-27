#!/bin/bash
# download_vision.sh

. common.sh

cd ${DOWNLOAD_PATH}
rm -rf vision
git clone https://github.com/pytorch/vision.git
cd vision
git checkout v0.5.0 -b v0.5.0
cd ../

