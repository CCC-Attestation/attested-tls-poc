FROM ubuntu:20.04

ARG TARGETARCH
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig
ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y autoconf-archive libcmocka0 libcmocka-dev procps
RUN apt install -y iproute2 build-essential git pkg-config gcc libtool automake libssl-dev uthash-dev doxygen libjson-c-dev
RUN apt install -y --fix-missing wget python3 cmake clang
RUN apt install -y libini-config-dev libcurl4-openssl-dev curl libgcc1
RUN apt install -y python3-distutils libclang-12-dev protobuf-compiler python3-pip 
RUN apt install -y openssl
RUN pip3 install Jinja2
RUN apt-get -y install tzdata

WORKDIR /tmp

# Download and install TSS 2.0
RUN git clone https://github.com/tpm2-software/tpm2-tss.git --branch 3.2.2
RUN cd tpm2-tss \
	&& ./bootstrap \
	&& ./configure \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig
RUN rm -rf tpm2-tss

# Download and install TPM 2.0 Tools verison 4.1.1
RUN git clone https://github.com/tpm2-software/tpm2-tools.git --branch 4.1.1
RUN cd tpm2-tools \
	&& ./bootstrap \
	&& ./configure --prefix=/usr \
	&& make -j$(nproc) \
	&& make install
RUN rm -rf tpm2-tools

# Download and install software TPM
ARG ibmtpm_name=ibmtpm1637
RUN wget -L "https://downloads.sourceforge.net/project/ibmswtpm2/$ibmtpm_name.tar.gz"
RUN sha256sum $ibmtpm_name.tar.gz | grep ^dd3a4c3f7724243bc9ebcd5c39bbf87b82c696d1c1241cb8e5883534f6e2e327
RUN mkdir -p $ibmtpm_name \
	&& tar -xvf $ibmtpm_name.tar.gz -C $ibmtpm_name \
	&& chown -R root:root $ibmtpm_name \
	&& rm $ibmtpm_name.tar.gz
WORKDIR $ibmtpm_name/src
RUN sed -i 's/-DTPM_NUVOTON/-DTPM_NUVOTON $(CFLAGS)/' makefile
RUN CFLAGS="-DNV_MEMORY_SIZE=32768 -DMIN_EVICT_OBJECTS=7" make -j$(nproc) \
	&& cp tpm_server /usr/local/bin
RUN rm -rf $ibmtpm_name/src $ibmtpm_name

WORKDIR /tmp

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:/opt/rust/bin:${PATH}"

# Install Parsec service
RUN git clone -b attested-tls https://github.com/ionut-arm/parsec.git \
	&& cd parsec \
	&& git checkout 1ac2060531b391ff1f335369dc4d1e4f17aee1aa \
	&& cargo build --release --features=tpm-provider \
	&& cp ./target/release/parsec /usr/bin/
RUN mkdir /etc/parsec/
COPY parsec-config.toml /etc/parsec/config.toml

# At runtime, Parsec is configured with the socket in /tmp/
ENV PARSEC_SERVICE_ENDPOINT="unix:/tmp/parsec.sock"

# Install MbedTLS (used for building purposes)
RUN git clone https://github.com/ARMmbed/mbedtls.git
RUN cd mbedtls \
	&& git checkout v3.0.0 \
	&& ./scripts/config.py crypto \
	&& ./scripts/config.py set MBEDTLS_PSA_CRYPTO_SE_C \
	&& make \
	&& make install
ENV MBEDTLS_PATH=/tmp/mbedtls
ENV MBEDTLS_INCLUDE_DIR=$MBEDTLS_PATH/include

# Build and install the Parsec C client
RUN git clone -b attested-tls https://github.com/ionut-arm/parsec-se-driver.git
RUN cd parsec-se-driver \
	&& cargo build --release \
	&& install -m 644 target/release/libparsec_se_driver.a /usr/local/lib \
	&& mkdir -p /usr/local/include/parsec \
	&& install -m 644 include/* /usr/local/include/parsec

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

# Build attester MbedTLS
RUN cd mbedtls \
	&& make clean \
	&& git reset --hard HEAD \
	&& git remote add ionut https://github.com/ionut-arm/mbedtls.git \
	&& git fetch ionut parsec-attestation  \
	&& git checkout f4ac7593826a506fc509c83cad73786acab1d442 \
	&& make CFLAGS="-DCTOKEN_LABEL_CNF=8 -DCTOKEN_TEMP_LABEL_KAK_PUB=2500" LDFLAGS="-lctoken -lt_cose -lqcbor -lm -lparsec_se_driver -lpthread -ldl" \
	&& install -m 755 programs/ssl/ssl_client2 /usr/local/bin

# Install Parsec tool
RUN git clone -b attested-tls https://github.com/ionut-arm/parsec-tool.git \
	&& cd parsec-tool \
	&& git checkout 45feaf20fcb0a886b2e20f4f19333b86608e215d \
	&& cargo build --release \
	&& cp target/release/parsec-tool /usr/bin/parsec-tool

# Install Go toolchain
RUN wget -c https://dl.google.com/go/go1.20.4.linux-$TARGETARCH.tar.gz -O - | tar -xz -C /usr/local
ENV PATH $PATH:/usr/local/go/bin:/root/go/bin

# Install cocli
RUN go install github.com/veraison/corim/cocli@v2.0.0-rc0

# Introduce scripts
COPY endorse.sh /root/
COPY handshake.sh /root/
COPY start.sh /root/

# Introduced platform endorsement templates
COPY comid-pcr.json /root/
COPY corim.json /root/

WORKDIR /root/

CMD /root/start.sh
