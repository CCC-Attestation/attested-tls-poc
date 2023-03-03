# Getting the mbedTLS prototype installed on MacOSX

## Install stock mbedTLS

```sh
brew install mbedtls
```

## Build and install QCBOR

```sh
git clone https://github.com/laurencelundblade/QCBOR
cd QCBOR
make
sudo make install
```

## Build and install t_cose

```sh
git clone https://github.com/laurencelundblade/t_cose
cd t_cose
env CRYPTO_LIB=/opt/homebrew/lib/libmbedcrypto.a CRYPTO_INC="-I /opt/homebrew/include" make -f Makefile.psa -e
sudo make -f Makefile.psa install
```

## Build ctoken

```sh
git clone https://github.com/laurencelundblade/ctoken.git
cd ctoken
env CRYPTO_LIB=/opt/homebrew/lib/libmbedcrypto.a CRYPTO_INC="-I /opt/homebrew/include" make -f Makefile.psa -e
```

Oddly, there is no `install` target in ctoken. A bit of DIY is needed:

```sh
sudo mkdir -p /usr/local/include/ctoken
sudo install -m 644  inc/ctoken/ctoken* /usr/local/include/ctoken
sudo install -m 644 libctoken.a /usr/local/lib
```

## Build the Veraison C Client

The mbedTLS demo uses [Veraison](https://github.com/veraison) for verification of attestation evidence. The
`ssl_server2` example program needs to make REST API calls to a suitable Veraison endpoint. In order to do this,
it consumes the C client for the Veraison challenge-response API.

The C client library is actually a wrapper of the Rust client library, so you must first
[install the Rust toolchain](https://www.rust-lang.org/tools/install).

Install the Veraison C API client as follows:

```sh
git clone https://github.com/veraison/rust-apiclient
cd rust-apiclient
cargo build
```

Again, a bit of DIY is needed in order to install the C wrapper pieces into a conventional location so that
mbedTLS can find the include files and the link library:

```sh
sudo mkdir -p /usr/local/include/veraison
sudo install -m 644 c-wrapper/veraison_client_wrapper.h /usr/local/include/veraison/
sudo install -m 644 ./target/debug/libveraison_apiclient_ffi.a /usr/local/lib/
```

## Build modified mbedTLS

```
git clone https://github.com/hannestschofenig/mbedtls
cd mbedtls
git checkout tls-attestation
make CFLAGS="-DCTOKEN_LABEL_CNF=8 -DCTOKEN_TEMP_LABEL_KAK_PUB=2500" LDFLAGS="-lqcbor -lctoken -lt_cose -lveraison_apiclient_ffi"
```

## Running the EAT example

```bash
cd programs/ssl
```

* Server side:

```bash
./ssl_server2 attestation_callback=1 force_version=tls13 auth_mode=required
```
* Client side:

```bash
./ssl_client2 client_att_type=eat
```

## Running the EAT example

```bash
cd programs/ssl
```

* Server side:

```bash
./ssl_server2 attestation_callback=1 force_version=tls13 auth_mode=required
```
* Client side:

```bash
./ssl_client2 client_att_type=eat
```
