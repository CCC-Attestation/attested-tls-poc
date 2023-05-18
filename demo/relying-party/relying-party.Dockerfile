FROM ubuntu:20.04

# TODO(paulhowardarm) - Some of the contents here are common with the attester Dockerfile, and we should look at
# making either a common base image or a Docker include.

ENV DEBIAN_FRONTEND=nonintercative
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

RUN apt update
RUN apt install -y autoconf-archive libcmocka0 libcmocka-dev procps
RUN apt install -y iproute2 build-essential git pkg-config gcc libtool automake libssl-dev uthash-dev doxygen libjson-c-dev
RUN apt install -y --fix-missing wget python3 cmake clang
RUN apt install -y libini-config-dev libcurl4-openssl-dev curl libgcc1
RUN apt install -y python3-distutils libclang-6.0-dev protobuf-compiler python3-pip
RUN pip3 install Jinja2
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
WORKDIR /tmp

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:/opt/rust/bin:${PATH}"

# Install regular MbedTLS (used for building purposes)
RUN git clone https://github.com/ARMmbed/mbedtls.git
RUN cd mbedtls \
	&& git checkout v3.0.0 \
	&& ./scripts/config.py crypto \
	&& make \
	&& make install
ENV MBEDTLS_PATH=/tmp/mbedtls
ENV MBEDTLS_INCLUDE_DIR=$MBEDTLS_PATH/include

# Build and install QCBOR
RUN git clone https://github.com/laurencelundblade/QCBOR
RUN cd QCBOR \
	&& make \
	&& make install

# Build and install t_cose
RUN git clone https://github.com/laurencelundblade/t_cose
RUN cd t_cose \
	&& env CRYPTO_LIB=/usr/local/lib/libmbedcrypto.a CRYPTO_INC="-I $MBEDTLS_INCLUDE_DIR" QCBOR_LIB="-lqcbor -lm" make -f Makefile.psa -e \
	&& make -f Makefile.psa install

# Build and install ctoken
RUN git clone https://github.com/laurencelundblade/ctoken.git
RUN cd ctoken \
	&& env CRYPTO_LIB=/usr/local/lib/libmbedcrypto.a CRYPTO_INC="-I $MBEDTLS_INCLUDE_DIR" QCBOR_LIB="-lqcbor -lm" make -f Makefile.psa -e \
	&& mkdir -p /usr/local/include/ctoken \
	&& install -m 644  inc/ctoken/ctoken* /usr/local/include/ctoken \
	&& install -m 644 libctoken.a /usr/local/lib

# Build and install the C client to Veraison, which is a wrapper of the Rust client
RUN git clone https://github.com/veraison/rust-apiclient.git
RUN cd rust-apiclient \
    && cargo build \
    && mkdir -p /usr/local/include/veraison \
    && install -m 644 c-wrapper/veraison_client_wrapper.h /usr/local/include/veraison \
    && install -m 644 ./target/debug/libveraison_apiclient_ffi.a /usr/local/lib

# Build and install libjwt/jansson, required by c-ear library
RUN git clone --depth 1 --branch v1.15.2  https://github.com/benmcollins/libjwt.git
RUN cd libjwt \
    && mkdir _build \
    && cd _build \
    && cmake -DUSE_INSTALLED_JANSSON=OFF -DJANSSON_BUILD_DOCS=OFF .. \
    && cmake --build . --target install

# Build and install the C EAR library (Entity Attestation Results)
RUN git clone https://github.com/veraison/c-ear.git
RUN cd c-ear \
    && mkdir _build \
    && cd _build \
    && cmake .. \
    && cmake --build . --target install

# Build relying party MbedTLS
RUN cd mbedtls \
	&& make clean \
	&& git reset --hard HEAD \
	&& git remote add paulh https://github.com/paulhowardarm/mbedtls.git \
	&& git fetch paulh ph-tls-attestation  \
	&& git checkout ph-tls-attestation \
	&& make CFLAGS="-DCTOKEN_LABEL_CNF=8 -DCTOKEN_TEMP_LABEL_KAK_PUB=2500" LDFLAGS="-lctoken -lt_cose -lqcbor -lveraison_apiclient_ffi -lear -ljwt -ljansson -lm -lssl -lcrypto -lgcc_s -lutil -lrt -lpthread -ldl -lc" \
	&& install -m 755 programs/ssl/ssl_server2 /usr/local/bin

WORKDIR /root/

CMD ssl_server2 attestation_callback=1 force_version=tls13 auth_mode=required server_port=4433 veraison_endpoint="http://verification-service.veraison-net:8080"
