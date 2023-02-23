#! /usr/bin/bash

set -e

OLD_PWD=$(pwd)
ROOT=$(pwd)/$1

test $# -eq 1

rm -r ${ROOT}
mkdir ${ROOT}

cd $ROOT

git clone https://github.com/fujitsu/pytorch.git
cd pytorch
git checkout fujitsu_v1.10.1_for_a64fx

cd scripts/fujitsu

sed '/https:\/\/github.com/a\ \ \ \ sed -e s/3.9.15+/3.9.15+fj/ ${DOWNLOAD_PATH}/${PYTHON_DIR}/Include/patchlevel.h' 1_python.sh
sed -ie "s!#\\(TCSDS_PATH=.*FX1\\)!\\1!g"       env.src
sed -ie "s!\\(TCSDS_PATH=.*FX7\\)!#\\1!"        env.src
sed -ie "s!\\(VENV_PATH=\\).*!\\1${ROOT}/venv!" env.src
sed -ie "s!\\(PREFIX=\\).*!\\1${ROOT}/opt!"     env.src 
if [ ${KFAST} = "true" ]; then
  sed -ie "s!CFLAGS=-O3 CXXFLAGS=-O3!CFLAGS=-Kfast!"     5_pytorch.sh
fi

cat << EOF | pjsub
#!/usr/bin/bash
#PJM -L "rscgrp=small"
#PJM -L elapse=08:00:00
#PJM -L "node=1"
#PJM --mpi "proc=1"
#PJM -j
#PJM -g ra000012
#PJM -S
#PJM -x PJM_LLIO_GFSCACHE=/vol0004
# #PJM -o
# #PJM -e
# #PJM --llio sharedtmp-size=80Gi

bash 1_python.sh
bash 3_venv.sh
bash 4_numpy_scipy.sh
bash 5_pytorch.sh
bash 6_vision.sh
bash 7_horovod.sh
bash 8_libtcmalloc.sh
EOF

cd ${OLD_PWD}
