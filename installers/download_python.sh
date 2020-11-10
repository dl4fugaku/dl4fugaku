#!/bin/bash
# download_python.sh

. activate.sh

cd ${DOWNLOAD_PATH}
rm -rf Python-3.8.2 Python-3.8.2.tgz

curl -O https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz
tar zxf Python-3.8.2.tgz
cd Python-3.8.2
patch < ${PATCH_DIR}/fj_python.patch

cd ..
