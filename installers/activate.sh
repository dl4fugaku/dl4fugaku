# This file should be SOURCED, not executed!
# . /path/to/activate.sh

ABSPATH=$(dirname $(readlink -f $BASH_SOURCE))

export VENV_PATH=${ABSPATH}/venv
export PERFIX=${ABSPATH}/opt

export LD_LIBRARY_PATH=$PREFIX/lib/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
module load system/fx700
module load FJSVstclanga/1.1.0

[ -d ${VENV_PATH} ] && \
    source ${VENV_PATH}/bin/activate || \
    echo "Warning: venv non-existing (if you are installing python, it is ok!)"
