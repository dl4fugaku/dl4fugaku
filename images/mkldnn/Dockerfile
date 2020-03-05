FROM ubuntu:19.10

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
RUN apt-get install -yqq doxygen
RUN apt-get install -yqq mc

# RUN git clone https://github.com/01org/mkl-dnn.git
RUN git clone https://github.com/intel/mkl-dnn.git

WORKDIR mkl-dnn
# RUN cd scripts && ./prepare_mkl.sh && cd ..
RUN mkdir -p build && cd build && cmake .. && make -j 4
WORKDIR build
RUN make install
