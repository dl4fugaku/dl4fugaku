FROM ubuntu:19.04

WORKDIR /workdir/

# COPY install-dependencies.sh \
#      requirements.txt ./

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends software-properties-common && \
    apt-get install -yqq sudo && \
    apt-get install -yqq git && \
    apt-get install -yqq build-essential && \
    apt-get install -yqq cmake

# TODO: freeze to commit/release
# TODO: merge commands when debugged
# TODO: check if config needs to be adnjusted

RUN git clone --recursive https://github.com/dmlc/tvm
WORKDIR /workdir/tvm 
RUN    mkdir build
RUN    cp cmake/config.cmake build
RUN    cd build && cmake .. && make -j4
