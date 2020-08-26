echo "PREFIX: ${PREFIX:=$(pwd)}"
echo "Compiler dir: ${TCSDS_PATH:=/opt/FJSVstclanga/v1.0.0}"
echo "VENV name: ${VENV_NAME:="fccbuild_v150"}"

export DOWNLOAD_PATH=${PREFIX}/down
export UPLOAD_PATH=${PREFIX}/up
export PYTORCH_INSTALL_PATH=${PREFIX}

export LD_LIBRARY_PATH=${TCSDS_PATH}/lib64:${PREFIX}/.local/lib:${LD_LIBRARY_PATH}
export PATH=${PREFIX}/.local/bin:${PATH}

export CC="${TCSDS_PATH}/bin/fcc -Nclang -Kfast"
export CXX="${TCSDS_PATH}/bin/FCC -Nclang -Kfast"

[ ! -d ${DOWNLOAD_PATH} ] && mkdir ${DOWNLOAD_PATH}
[ ! -d ${PREFIX}/.local ] && mkdir ${PREFIX}/.local
