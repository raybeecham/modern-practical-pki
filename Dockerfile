FROM ubuntu:24.04

ARG OPENSSL_VERSION=4.0.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        build-essential \
        make \
        openssh-client \
        perl \
        pkg-config \
        xxd && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

RUN curl -fsSLO "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" && \
    tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz" && \
    cd "openssl-${OPENSSL_VERSION}" && \
    ./config shared enable-fips \
        --prefix=/opt/openssl \
        --openssldir=/opt/openssl/ssl && \
    make -j"$(nproc)" && \
    make install_sw install_ssldirs install_fips && \
    echo "/opt/openssl/lib64" > /etc/ld.so.conf.d/openssl-lab.conf && \
    ldconfig

ENV PATH="/opt/openssl/bin:${PATH}"
ENV PKG_CONFIG_PATH="/opt/openssl/lib64/pkgconfig"

WORKDIR /workspace

COPY Makefile README.md /workspace/
COPY openssl/ /workspace/openssl/
COPY scripts/ /workspace/scripts/

RUN chmod +x /workspace/scripts/*.sh

CMD ["bash"]
