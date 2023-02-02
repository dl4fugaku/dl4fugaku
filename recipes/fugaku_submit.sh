#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L elapse=00:01:00
#PJM -L "node=2"
#PJM --mpi "proc=8"
#PJM -j
#PJM -S

# rscgrp=large for more nodes
# elapse HH:MM:SS
# Process per node (PPN) is P/N where `--mpi "proc=P"` and `-L "node=N"`
# -j merges stdout and stderr
# -S generates statistics report (after job completion)

# RUN IT WITH:
# $ pjsub fugaku_submit.sh

# pytorch 1.10 build instructions are available
export PATH=/home/apps/oss/PyTorch-1.7.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/PyTorch-1.7.0/lib:$LD_LIBRARY_PATH
LD_PRELOAD=libtcmalloc.so \
  mpirun python3 torch_distributed.py
