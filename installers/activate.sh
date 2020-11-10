# This file should be SOURCED, not executed!
# . /path/to/activate.sh

ABSPATH=$(dirname $(readlink -f $BASH_SOURCE))

export VENV_PATH=${ABSPATH}/venv
export PREFIX=${ABSPATH}/opt
export PATCH_DIR=${ABSPATH}/up

module purge
module load system/fx700
module load FJSVstclanga/1.1.0
export LD_LIBRARY_PATH=$PREFIX/lib/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

if [ -d "${VENV_PATH}" ]; then
    source ${VENV_PATH}/bin/activate
else
    echo "Warning: venv non-existing (if you are installing python, it is ok!)"
fi
