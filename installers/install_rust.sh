#!/bin/bash
#SBATCH --time=02:00:00

. activate.sh

# Download
cd ${DOWNLOAD_PATH}
rm -rf rust
git clone https://github.com/rust-lang/rust.git

# Build and install
pip install ninja
cd ${DOWNLOAD_PATH}/rust
cat config.toml.example  | sed \
	-e "s;#prefix = .*;prefix = \"${PREFIX}\";" \
	-e "s;#sysconfdir = .*;sysconfdir = \"${PREFIX}/etc\";" \
	-e "s;#ninja = .*;ninja = true;" \
	-e "s;#docs = .*;docs = false;" \
	-e "s;#compiler-docs = .*;compiler-docs = false;" \
	> config.toml
./x.py install
./x.py install cargo
