#!/bin/bash

. common.sh

# move download path
rm -rf ${DOWNLOAD_PATH}/Python-3.8.2 ${DOWNLOAD_PATH}/Python-3.8.2.tgz
cd ${DOWNLOAD_PATH}

# Download python
curl -O https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz
tar zxf Python-3.8.2.tgz

cd ..
