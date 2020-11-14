#!/bin/bash

. activate.sh

# Download
git clone https://github.com/rust-lang/rust.git

# Build and install
pip install ninja
cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed \
	-e "s;#prefix = .*;prefix = \"${PREFIX}\";" \
	-e "s;#sysconfdir = .*;sysconfdir = \"${PREFIX}/etc\";" \
	> config.toml
./x.py install
./x.py install cargo
