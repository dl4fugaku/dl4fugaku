# dl4fugaku
Main repo to keep scripts, dockerfiles, wiki, etc

# Activating pytorch on Fugaku
Use the following command:
```
export PATH=/home/apps/oss/PyTorch-1.7.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/PyTorch-1.7.0/lib:$LD_LIBRARY_PATH
```

# Notes

## FJ hugepages with non-FJ compilers
```
-Wl,-T/opt/FJSVxos/mmm/util/bss-2mb.lds -L/opt/FJSVxos/mmm/lib64 -lmpg
```

## `tcmalloc` brings better performance
Python (especially pytorch) should be run like this:
```
$ LD_PRELOAD=libtcmalloc.so python # ...
```

## Running multiple MPI processes on a single node
It can happen that one wishes to run e.g. 1 MPI process per CMG, which
means 4 MPI processes per node.  To do this one needs to specify both
number of nodes and number of MPI processes.  As an example, to run a
program of 8 MPI processes on 1 CMG each, which means 2 nodes with 4
MPI processes each, one would add to the beginning of the submission
script, lines similar to these :

```
#PJM --mpi "proc=4" 
#PJM -L "node=1,rscunit=rscunit_ft01,rscgrp=int,elapse=2:00:00"
```

### Checking the layout of cores per MPI process
Try something like this:
```
LOGIN_NODE $ pjsub --interact --llio sharedtmp-size=80Gi --mpi "proc=4" -L "node=1,rscunit=rscunit_ft01,rscgrp=int,elapse=2:00:00" --sparam wait-time=1000
...
COMPUTE_NODE $ mpirun env | grep FLIB_AFF
FLIB_AFFINITY_ON_PROCESS=12,13,14,15,16,17,18,19,20,21,22,23
FLIB_AFFINITY_ON_PROCESS=48,49,50,51,52,53,54,55,56,57,58,59
FLIB_AFFINITY_ON_PROCESS=36,37,38,39,40,41,42,43,44,45,46,47
FLIB_AFFINITY_ON_PROCESS=24,25,26,27,28,29,30,31,32,33,34,35
```

## Faster storage
The `pjsub --llio sharedtmp-size=80Gi` `pjsub` switch or equivalently
`#PJM --llio sharedtmp-size=80Gi` inside the submission scripts
allocates fast temporary storage (SSDs) shared between all allocated nodes.

If you do `--llio sharedtmp-size=XX` then the llio storage is `/share`, 
while for `--llio localtmp-size=XX` it is `/local`.

## NUMA commands
Disclaimer: This is generally discouraged, but can be useful for
experimenting.  To achieve something similar you need to [Running
multiple MPI processes on a single
node](#running-multiple-mpi-processes-on-a-single-node).

You can use this `run_on_cmg` to run on a single CMG:
```
$ cat run_on_cmg
OMP_NUM_THREADS=12 numactl -N 4 -m 4 $@
```
The following command (on Fugaku compute node) shows where the 4s come from:
```
$ numactl --show
policy: default
preferred node: current
physcpubind: 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 
cpubind: 4 5 6 7 
nodebind: 4 5 6 7 
membind: 4 5 6 7 
```

If you need to rune 1 core on each CMG: 
```
OMP_NUM_THREADS=4 numactl -l -C 12,24,36,48 <cmd>
```

### Interleaved memory
Usually 4PPN (processes per node) i.e. one process per CMG is optimal, however some apps benefit from 1PPN.  In this situation you might want to experiment with interleaved memory:
```
mpirun -mca plm_ple_memory_allocation_policy interleave_all app args
```

## Installing/compiling Pytorch from source (Fujitsu repo)

https://github.com/fujitsu/pytorch/wiki/PyTorch-DNNL_aarch64-build-manual-for-FUJITSU-Software-Compiler-Package-(PyTorch-v1.7.0)
