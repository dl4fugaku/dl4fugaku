#!/bin/sh

#$ -l rt_F=2
#$ -j y
#$ -cwd

source /etc/profile.d/modules.sh
module load gcc/9.3.0
module load cuda/10.2
module load cudnn/8.2
module load nccl/2.9
module load openmpi/4.0.5
module load python/3.8


NUM_NODES=${NHOSTS}
NUM_GPUS_PER_NODE=4
NUM_GPUS_PER_SOCKET=$(expr ${NUM_GPUS_PER_NODE} / 2)
NUM_PROCS=$(expr ${NUM_NODES} \* ${NUM_GPUS_PER_NODE})


MPIOPTS="-np ${NUM_PROCS} -map-by ppr:${NUM_GPUS_PER_NODE}:node -mca pml ob1 -mca btl ^openib -mca btl_tcp_if_include bond0"

mpirun ${MPIOPTS} \
       bash -c "\
       NCCL_SOCKET_IFNAME=eth0 \
       WORLD_SIZE=\$OMPI_COMM_WORLD_SIZE \
       RANK=\$OMPI_COMM_WORLD_RANK \
       MASTER_ADDR=${HOSTNAME} \
       MASTER_PORT=1234 \
       python3 torch_distributed.py \
       "
