#!/bin/bash

. common.sh

# Download sentencepiece transformers requirements
cd ${DOWNLOAD_PATH}
rm -rf sentencepiece
git clone git@github.com:google/sentencepiece.git
