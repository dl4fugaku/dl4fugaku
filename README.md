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
