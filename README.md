# dl4fugaku
Main repo to keep scripts, dockerfiles, wiki, etc

# Notes

## `tcmalloc` brings better performance
Python (especially pytorch) should be run like this:
```
$ LD_PRELOAD=libtcmalloc.so python # ...
```
