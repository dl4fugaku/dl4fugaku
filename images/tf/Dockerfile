FROM ubuntu:19.04

WORKDIR /workdir/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    sudo \
    git \
    build-essential \
    cmake \
    pkg-config \
    gfortran \
    zip \
    zlib1g-dev \
    unzip \
    wget \
    curl \
    libcurl3-dev \
    libfreetype6-dev \
    libopenblas-dev \
    libhdf5-dev \
    openjdk-8-jdk \
    openjdk-8-jre-headless \
    swig \
    && \
    apt-get clean

RUN apt-get -yqq install --no-install-recommends \ 
    python3-dev \
    python3-pip \
    python3-wheel \
    python3-setuptools \
    && \
    apt-get clean

RUN ln -s /usr/bin/python3 /usr/bin/python & \
    ln -s /usr/bin/pip3 /usr/bin/pip

RUN pip3 install --upgrade --no-cache-dir \
    setuptools \
    wheel \
    six \
    numpy \
    cython \
    jupyter \
    Pillow \
    h5py \
    keras_applications \
    keras_preprocessing \
    matplotlib \
    mock \
    scipy \
    sklearn \
    pandas \
    future \
    portpicker \
    enum34

WORKDIR bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-dist.zip
RUN unzip bazel-0.26.1-dist.zip
ENV EXTRA_BAZEL_ARGS --host_javabase=@local_jdk//:jdk
RUN ./compile.sh
ENV PATH="/workdir/bazel/output/:${PATH}"

WORKDIR ..

RUN wget https://github.com/tensorflow/tensorflow/archive/v2.0.0-rc1.tar.gz
RUN tar -xvf v2.0.0-rc1.tar.gz
WORKDIR tensorflow-2.0.0-rc1
RUN ./configure
# --copt=-DUSE_CBLAS_GEMM --cxxopt=-DUSE_CBLAS_GEMM
RUN bazel build --jobs 12 --config=v2  //tensorflow/tools/pip_package:build_pip_package
RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package ./tmp/tensorflow_pkg
RUN pip3 install ./tmp/tensorflow_pkg/tensorflow-2.0.0rc1-cp37-cp37m-linux_aarch64.whl
WORKDIR ..

RUN pip3 install pydataset
RUN pip3 install py-cpuinfo
RUN pip3 install system_query[cpu,hdd,ram,swap]
RUN git clone https://github.com/undertherain/benchmarker.git
