run:
	MKLDNN_VERBOSE=1 python3 conv_torch.py

cprof:
	python3 -m cProfile -o myLog.profile ./conv_torch.py
	gprof2dot -f pstats myLog.profile -o callGraph.dot
	dot -Tpng callGraph.dot -o outfile.png

perf:
	sudo perf record -F 99 --call-graph dwarf -g python3 ./conv_torch.py
	sudo perf report

trace:
	export LD_PROFILE=libopenblas.so.0
	python3 ./conv_torch