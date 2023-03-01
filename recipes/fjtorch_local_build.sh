#! /usr/bin/bash

set -e

source fj_pytorch_build_funcs.src



[ $# -lt 1 ] && echo "Usage: [KFAST=true] $0 <tar file> (if KFAST=true compile with -Kfast option)" && exit -1

JOBNAME=$(basename $0)
TARFILE=$1
ELAPSE=08:00:00

echo "This file will be created: ${TARFILE}"
are_you_sure

cat << EOF | pjsub
#!/usr/bin/bash
#PJM -N ${JOBNAME}
#PJM -L "rscgrp=small"
#PJM -L "elapse=${ELAPSE}"
#PJM -L "node=1"
#PJM --mpi "proc=1"
#PJM -j
#PJM -g ra000012
#PJM -S
#PJM -x PJM_LLIO_GFSCACHE=/vol0004
#PJM --llio localtmp-size=80Gi
# #PJM -o
# #PJM -e

source fj_pytorch_build_funcs.src

pushd \${PJM_LOCALTMP}

prep_fj_repo_2pushd \${PJM_LOCALTMP} ${KFAST}

bash 1_python.sh
bash 3_venv.sh
### 20min mark ###
bash 4_numpy_scipy.sh
bash 5_pytorch.sh
bash 6_vision.sh
bash 7_horovod.sh
bash 8_libtcmalloc.sh

popd
popd

echo ">>> BEGIN TAR <<<"
tar czf ${TARFILE} opt venv

popd

echo ">>> BEGIN COPY <<<"
cp \${PJM_LOCALTMP}/${TARFILE} .

echo ">>> DONE <<<"
EOF

