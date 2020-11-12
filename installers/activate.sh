# This file should be SOURCED, not executed!
# . /path/to/activate.sh

ROOT_DIR=$(dirname $(readlink -f $BASH_SOURCE))

export VENV_PATH=${ROOT_DIR}/venv
export PREFIX=${ROOT_DIR}/opt
export PATCH_DIR=${ROOT_DIR}/up

if [[ $(hostname) == *r-ccs.riken.jp ]]; then
	module purge
	module load system/fx700
	module load FJSVstclanga/1.1.0
fi

export LD_LIBRARY_PATH=$PREFIX/lib/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

if [ -d "${VENV_PATH}" ]; then
	source ${VENV_PATH}/bin/activate
else
	echo "Warning: venv non-existing (if you are installing python, it is ok!)"
fi

export PATH=${PREFIX}/bin:${PATH}

export DOWNLOAD_PATH=/tmp/$(whoami)/download_and_build_dir
export fcc_ENV="-Nclang -Kfast"
export FCC_ENV="-Nclang -Kfast"
export CC=fcc
export CXX=FCC
export AR=ar

[ ! -d ${DOWNLOAD_PATH} ] && mkdir -p ${DOWNLOAD_PATH}
[ ! -d ${PREFIX} ] && mkdir -p ${PREFIX}/etc
