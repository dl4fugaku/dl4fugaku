echo "PREFIX: ${PREFIX:=$(pwd)/.local}"
echo "VENV name: ${VENV_NAME:="fccbuild_v150"}"

export DOWNLOAD_PATH=/tmp/emil.vatai/down
# export UPLOAD_PATH=$(pwd)/up
export PYTORCH_INSTALL_PATH=${PREFIX} # todo(vatai): remove this var

export LD_LIBRARY_PATH=${PREFIX}/lib:${LD_LIBRARY_PATH}
export PATH=${PREFIX}/bin:${PATH}

export fcc_ENV="-Nclang -Kfast"
export FCC_ENV="-Nclang -Kfast"
export CC=fcc
export CXX=FCC

[ ! -d ${DOWNLOAD_PATH} ] && mkdir -p ${DOWNLOAD_PATH}
[ ! -d ${PREFIX} ] && mkdir -p ${PREFIX}
