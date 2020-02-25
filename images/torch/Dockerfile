FROM ubuntu:19.04

WORKDIR /workdir/

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends software-properties-common && \
    apt-get install -yqq sudo && \
    apt-get install -yqq git && \
    apt-get install -yqq build-essential && \
    apt-get install -yqq cmake && \
    apt-get install -yqq pkg-config && \
    apt-get install -yqq zip && \
    apt-get install -yqq zlib1g-dev && \
    apt-get install -yqq unzip && \
    apt-get install -yqq wget

RUN apt-get install -yqq libopenblas-dev
RUN apt-get install -yqq libhdf5-dev

RUN apt-get -yqq install --no-install-recommends python3-dev && \
    apt-get -yqq install --no-install-recommends python3-pip && \
    apt-get -yqq install --no-install-recommends python3-wheel && \
    apt-get -yqq install --no-install-recommends python3-setuptools

RUN ln -s /usr/bin/python3 /usr/bin/python & \
    ln -s /usr/bin/pip3 /usr/bin/pip

RUN pip3 install jupyter
RUN pip3 install six numpy wheel setuptools mock
RUN pip3 install pydataset
RUN pip3 install py-cpuinfo
RUN pip3 install system_query[cpu,hdd,ram,swap]
RUN git clone https://github.com/undertherain/benchmarker.git

#RUN wget https://github.com/pytorch/pytorch/archive/v1.4.0.tar.gz
#RUN tar -xvf v1.4.0.tar.gz

ENV USE_CUDNN=0
ENV USE_FBGEMM=0
ENV BUILD_TEST=0
ENV USE_NNPACK=0
ENV USE_QNNPACK=0
ENV USE_DISTRIBUTED=0
ENV USE_SYSTEM_NCCL=0
ENV BUILD_CAFFE2_OPS=1
# ENV MAX_JOBS=36
ENV USE_NCCL=off
ENV USE_CUDA=off
ENV BLAS=OpenBLAS
ENV USE_MKLDNN=ON
ENV USE_MKLDNN_CBLAS=ON
ENV MKLDNN_USE_NATIVE_ARCH=ON
ENV CC=gcc
ENV CXX=g++
ENV ARCH_OPT_FLAGS="-msse4.2 -msse2avx -gno-inline-points -fearly-inlining -march=native -O3"
ENV CMAKE_C_FLAGS="-msse4.2 -msse2avx -gno-inline-points -fearly-inlining -march=native -O3"
ENV CMAKE_CXX_FLAGS="$CMAKE_C_FLAGS"
ENV CFLAGS="$CMAKE_C_FLAGS"

RUN git clone --recursive https://github.com/pytorch/pytorch.git
RUN pip3 install ninja pyyaml cffi typing
RUN cd pytorch; git checkout v1.4.0 && python3 setup.py install
