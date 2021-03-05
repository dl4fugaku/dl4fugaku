# dl4fugaku
Main repo to keep scripts, dockerfiles, wiki, etc

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
