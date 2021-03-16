# dl4fugaku
Main repo to keep scripts, dockerfiles, wiki, etc

# Activating pytorch on Fugaku
Use the following command:
```
export PATH=/home/apps/oss/PyTorch-1.7.0/bin:$PATH
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

## NUMA commands
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
