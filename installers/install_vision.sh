#!/bin/bash

. common.sh

cd ${DOWNLOAD_PATH}/vision
python3 setup.py clean
python3 setup.py install

