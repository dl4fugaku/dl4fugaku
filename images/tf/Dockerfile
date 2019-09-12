FROM ubuntu:19.04

WORKDIR /workdir/

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends software-properties-common && \
    apt-get install -yqq sudo && \
    apt-get install -yqq git && \
    apt-get install -yqq build-essential && \
    apt-get install -yqq cmake  && \
    apt-get install -yqq pkg-config  && \
    apt-get install -yqq zip  && \
    apt-get install -yqq zlib1g-dev  && \
    apt-get install -yqq unzip


RUN apt-get -yqq install --no-install-recommends python3-dev && \
    apt-get -yqq install --no-install-recommends python3-pip && \
    apt-get -yqq install --no-install-recommends python3-wheel && \
    apt-get -yqq install --no-install-recommends python3-setuptools

RUN pip3 install jupyter
RUN pip3 install six numpy wheel setuptools mock
RUN pip3 install -U --user keras_applications==1.0.6 --no-deps
RUN pip3 install -U --user keras_preprocessing==1.0.5 --no-deps
