echo PREFIX: ${PREFIX:=$(pwd)/.local/opt}

. activate.sh

export DOWNLOAD_PATH=/tmp/emil.vatai/down
# export UPLOAD_PATH=$(pwd)/up

export PATH=${PREFIX}/bin:${PATH}

export fcc_ENV="-Nclang -Kfast"
export FCC_ENV="-Nclang -Kfast"
export CC=fcc
export CXX=FCC

[ ! -d ${DOWNLOAD_PATH} ] && mkdir -p ${DOWNLOAD_PATH}
[ ! -d ${PREFIX} ] && mkdir -p ${PREFIX}

