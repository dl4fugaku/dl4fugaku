#!/bin/bash

. common.sh

cd ${PYTORCH_INSTALL_PATH}/${VENV_NAME}
source bin/activate

cd ${DOWNLOAD_PATH}/vision
python3 setup.py clean
python3 setup.py install

