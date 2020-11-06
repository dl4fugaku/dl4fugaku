echo "PREFIX: ${PREFIX:=$(pwd)/.local}"
echo "Compiler dir: ${TCSDS_PATH:=/opt/FJSVstclanga/v1.1.0}"
echo "VENV name: ${VENV_NAME:="fccbuild_v150"}"

export DOWNLOAD_PATH=/tmp/emil.vatai/down
# export UPLOAD_PATH=$(pwd)/up
export PYTORCH_INSTALL_PATH=${PREFIX} # todo(vatai): remove this var

export LD_LIBRARY_PATH=${TCSDS_PATH}/lib64:${PREFIX}/lib:${LD_LIBRARY_PATH}
export PATH=${PREFIX}/bin:${PATH}

export CC="${TCSDS_PATH}/bin/fcc -Nclang -Kfast"
export CXX="${TCSDS_PATH}/bin/FCC -Nclang -Kfast"

[ ! -d ${DOWNLOAD_PATH} ] && mkdir -p ${DOWNLOAD_PATH}
[ ! -d ${PREFIX} ] && mkdir -p ${PREFIX}
