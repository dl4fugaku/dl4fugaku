# Known Issues

## Can't profile torch

As far as we know, `fapp` cannot be used to profile PyTorch performance.
There are two main problems with it:
- The binaries (both `python` and torch) need to be compiled/linked with the `fapp` libs;
- When running the profiler, one runs: `fapp <options> python script.py`.
  This profiles the `python` binary, and when torch forks, the profile data is not collected properly as stated in the [Profiler User's Guide, section 2.1.3 Compilation](https://www.fugaku.r-ccs.riken.jp/doc_root/en/manuals/tcsds-1.2.36/lang/Tool/j2ul-2568-01enz0.pdf)
