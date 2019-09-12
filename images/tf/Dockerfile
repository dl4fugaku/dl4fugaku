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

RUN apt-get install -yqq openjdk-8-jdk


RUN apt-get -yqq install --no-install-recommends python3-dev && \
    apt-get -yqq install --no-install-recommends python3-pip && \
    apt-get -yqq install --no-install-recommends python3-wheel && \
    apt-get -yqq install --no-install-recommends python3-setuptools

RUN pip3 install jupyter
RUN pip3 install six numpy wheel setuptools mock
RUN pip3 install -U --user keras_applications==1.0.6 --no-deps
RUN pip3 install -U --user keras_preprocessing==1.0.5 --no-deps

RUN wget https://github.com/bazelbuild/bazel/archive/0.29.1.tar.gz
RUN tar -xvf 0.29.1.tar.gz
WORKDIR bazel-0.29.1
RUN PROTOC=`pwd`/bin/protoc EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" GRPC_JAVA_PLUGIN=`pwd`/grpc-java bash ./compile.sh
# export PATH=$PATH:`pwd`/../bazel-0.25.2/output