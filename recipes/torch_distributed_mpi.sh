#!/bin/bash
#PJM -L "rscunit=rscunit_ft01,rscgrp=small"
#PJM -L elapse=00:01:00
#PJM -L "node=2"
#PJM --mpi "proc=4"
#PJM -j
#PJM -S

# RUN IT WITH:
# $ pjsub magic.sh

export PATH=/home/apps/oss/PyTorch-1.7.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/PyTorch-1.7.0/lib:$LD_LIBRARY_PATH
LD_PRELOAD=libtcmalloc.so mpirun -n $PJM_MPI_PROC python3 torch_distributed_mpi.py

