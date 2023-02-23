# Known Issues

## Can't profile torch

As far as we know, `fapp` cannot be used to profile PyTorch performance.
There are two main problems with it:
- The binaries (both `python` and torch) need to be compiled/linked with the `fapp` libs;
- When running the profiler, one runs: `fapp <options> python script.py`.
  This profiles the `python` binary, and when torch forks, the profile data is not collected properly as stated in the [Profiler User's Guide, section 2.1.3 Compilation](https://www.fugaku.r-ccs.riken.jp/doc_root/en/manuals/tcsds-1.2.36/lang/Tool/j2ul-2568-01enz0.pdf)

## Malformed version string causes doesn't allow `datasets` to be loaded

The output of `python -c "import sys; print(sys.version)"` is:

    3.9.15+ (heads/3.9:3b81c13ac3, Dec  7 2022, 00:35:29)
    [Clang 7.1.0 ]

Here `3.9.15+` is not accepted by `packaging.version` properly and when loading `datasets` the comparison of python versions fails.
The solution is probably to modify the `PY_VERSION` in `Include/patchlevel.h` before compiling (suggestion would be to modify it to `3.9.15+fj`).
