FROM fedora:31

WORKDIR /workdir/

RUN dnf update -y
RUN dnf install -y zsh wget git sudo cmake python3 pkg-config unzip @development-tools
RUN dnf install -y xz xz-devel file gcc-plugin-devel gcc-python3-plugin gcc-python2-plugin openblas
RUN dnf install -y diffutils findutils which gcc gcc-c++ gcc-gfortran gcc-gnat vim-enhanced
RUN dnf install -y bzip2 bzip2-devel
RUN dnf install -y llvm-devel clang-devel
RUN dnf install -y openblas-devel
RUN dnf install -y python3-devel
RUN dnf install -y python3-pip

RUN python3 -m pip install future numpy pyyaml requests setuptools six typing wheel

WORKDIR /workdir/
RUN git clone --recursive https://github.com/dl4fugaku/pytorch.git
WORKDIR /workdir/pytorch
RUN git checkout bd604cb5b7ae4f6388aca461891d620b0d485fbb
RUN git submodule update --init --recursive

ENV ARCH_OPT_FLAGS="-msse4.2 -msse2avx -gno-inline-points -fearly-inlining -march=native -O3 -DEIGEN_NO_DEBUG -DEIGEN_USE_BLAS"
ENV CMAKE_C_FLAGS="$ARCH_OPT_FLAGS"
ENV CMAKE_CXX_FLAGS="$CMAKE_C_FLAGS"
ENV CFLAGS="$CMAKE_C_FLAGS"
ENV USE_CUDNN=0
ENV USE_FBGEMM=0
ENV BUILD_TEST=0
ENV BUILD_TESTS=0
ENV USE_NNPACK=0
ENV USE_QNNPACK=0
ENV USE_DISTRIBUTED=0
ENV USE_SYSTEM_NCCL=0
ENV USE_NCCL=0
ENV USE_CUDA=0
ENV BLAS=OpenBLAS
ENV USE_MKLDNN=1
ENV USE_MKLDNN_CBLAS=1
ENV MKLDNN_USE_NATIVE_ARCH=1
ENV MKLDNN_LIBRARY_TYPE=SHARED
ENV DNNL_LIBRARY_TYPE=SHARED
ENV BUILD_CAFFE2_OPS=1
ENV BUILD_CAFFE2_MOBILE=0
ENV ENFORCE_AVX512F=1
ENV ENFORCE_OPENMP=1
ENV BUILD_NAMEDTENSOR=OFF
ENV DISABLE_NUMA=1
ENV PERF_WITH_AVX=1
ENV PERF_WITH_AVX2=1
ENV PERF_WITH_AVX512=1
ENV USE_GFLAGS=OFF
ENV USE_GLOG=OFF
ENV VERBOSE=1
ENV MAX_JOBS=32
RUN sed -i -e 's/MKLDNN_LIBRARY_TYPE STATIC/MKLDNN_LIBRARY_TYPE SHARED/' ./cmake/Modules/FindMKLDNN.cmake

RUN /bin/bash -l -c 'python3 setup.py bdist_wheel 2>&1 | tee build.log'
RUN python3 -m pip install --user --upgrade ./dist/torch-1.5.0a0+bd604cb-cp37-cp37m-linux_x86_64.whl

WORKDIR /workdir/

# testing dnnl which came with torch
ENV LD_LIBRARY_PATH=/workdir/pytorch/build/lib
RUN python3 -c "import torch; print(torch.__config__.show())"

RUN wget https://raw.githubusercontent.com/dl4fugaku/dl4fugaku/simple/simple_kernels/conv_torch.py
RUN sed -i '/cuda/d' ./conv_torch.py
RUN sed -i '/to(device/d' ./conv_torch.py
RUN MKLDNN_JIT_DUMP=1 MKLDNN_VERBOSE=2 MKLDNN_ENABLE_JIT_PROFILING=1 OMP_NUM_THREADS=32 GOMP_SPINCOUNT=0 OMP_SCHEDULE=static OPENBLAS_NUM_THREADS=1 python3 ./conv_torch.py

# replacing dnnl
RUN git clone https://github.com/intel/mkl-dnn.git
RUN mkdir -p /workdir/mkl-dnn/build
WORKDIR /workdir/mkl-dnn/build
RUN cmake -DDNNL_LIBRARY_TYPE=SHARED -DDNNL_CPU_RUNTIME=OMP -DDNNL_GPU_RUNTIME=NONE -DDNNL_BUILD_EXAMPLES=ON -DDNNL_BUILD_TESTS=ON -DDNNL_ARCH_OPT_FLAGS="-msse4.2 -msse2avx -gno-inline-points -fearly-inlining -march=native" ..
RUN make -j $MAX_JOBS

WORKDIR /workdir/
ENV LD_LIBRARY_PATH=/workdir/mkl-dnn/build/src
RUN MKLDNN_JIT_DUMP=1 MKLDNN_VERBOSE=2 MKLDNN_ENABLE_JIT_PROFILING=1 OMP_NUM_THREADS=32 GOMP_SPINCOUNT=0 OMP_SCHEDULE=static OPENBLAS_NUM_THREADS=1 python3 ./conv_torch.py

