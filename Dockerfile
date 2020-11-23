FROM ubuntu:20.04
LABEL "maintainer"="vh@thc.org"

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_RTLIB_32=ON

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get -y install \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    ca-certificates \
    tar \
    gzip \
    vim \
    curl \
    apt-utils \
    libelf-dev \
    libelf1 \
    libiberty-dev \
    libboost-all-dev \
    libtbb2 \
    libtbb-dev && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/dyninst/dyninst \
    && cd dyninst && mkdir build && cd build \
    && cmake .. \
    && make \
    && make install

RUN git clone https://github.com/vanhauser-thc/AFLplusplus \
    && cd AFLplusplus \
    && make source-only \
    && make install

RUN git clone https://github.com/vanhauser-thc/afl-dyninst \
    && cd afl-dyninst \
    && ln -s ../AFLplusplus afl \
    && make \
    && make install

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig \
    && echo "export DYNINSTAPI_RT_LIB=/usr/local/lib/libdyninstAPI_RT.so" >> .bashrc

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so
