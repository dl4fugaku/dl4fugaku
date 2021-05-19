# dl4fugaku
Main repo to keep scripts, dockerfiles, wiki, etc

# Activating pytorch on Fugaku
Use the following command:
```
export PATH=/home/apps/oss/PyTorch-1.7.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/PyTorch-1.7.0/lib:$LD_LIBRARY_PATH
```

## Installing Pytorch from Fujitsu repo (obsolete)

These are notes in addition to the README.md of Fujitsu's [github repo](https://github.com/fujitsu/pytorch/tree/fujitsu_v1.7.0_for_a64fx/scripts/fujitsu). 
You should primarily follow the README.md, but the idea is to just copy paste these commands and make everything work like magic (which reminds me that I should put these in a bash script).
My insall process looks something like this:

```shell
git clone git@github.com:fujitsu/pytorch.git pytorch-fujitsu
cd pytorch-fujitsu
git checkout fujitsu_v1.7.0_for_a64fx
cd scripts/fujitsu/
sed -i -e 's!PREFIX=.*!PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null ; pwd)"!' env.src
sed -i -e 's!TCSDS_PATH=.*!TCSDS_PATH=/opt/FJSVxtclanga/tcsds-1.2.29!' env.src
sed -i -e 's/rscgrp=ai-default/rscgrp=eap-small/' submit_*.sh opennmt_build_pack/submit_*.sh
./checkout.sh
pjsub submit_build.sh
# and then follow readme
```

### Notes on the `sed`s

- First `sed` substitutes the magic command which evaluates to the current directory of `env.src`.
- Second `sed` sets the path to the compiler. This needs to be the path **on the compute node** (not the login node).
- Third `sed` sets the resource group.  Run `pjstat --rsc` to see the resource groups.

### If everything worked

If the jobs complete successfully, you probably want a single file which will activate the venv created by the install scripts.  Put this file in the `<pytorch-fujitsu-repo>/scripts/fujitsu` dir (where the install scripts are):
```shell
cat data/pytorch-fujitsu/scripts/fujitsu/activate.sh 
PREFIX="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null ; pwd )"
source ${PREFIX}/env.src
source ${PREFIX}/fccbuild_v170/bin/activate
```
# Notes

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
allocates fast temporary storage (SSDs) shared between 16 nodes.

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
