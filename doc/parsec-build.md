# Getting the Parsec prototype installed

Building and running the Parsec PoC involves two independent components: the Parsec service which
interacts with the RoT, and the client library that the TLS implementation uses to communicate with
the service. More information about the Parsec service can be found
[here](https://parallaxsecond.github.io/parsec-book/).

Both components require a Rust toolchain to be available locally. You can find information on
installing Rust [here](https://www.rust-lang.org/tools/install).

## Parsec service

This section captures the steps needed to set up the Parsec service from scratch.

### Prerequisites

The Parsec service serves as an abstraction layer over Root of Trust (RoT) APIs, meaning it must be
able to interact with those APIs. The service executable thus requires linking against the correct
libraries that enable communication with the RoT. In the case of our PoC, the RoT of choice is a
TPM2.0. We recommend using:

- [tpm2-tss](https://github.com/tpm2-software/tpm2-tss) libraries - version 2.4.6
- [ibmswtpm2](https://sourceforge.net/projects/ibmswtpm2/) - version 1637

Follow the steps described [here](https://github.com/tpm2-software/tpm2-tss/blob/2.4.6/INSTALL.md)
to build and install the TSS2 libraries. No special configuration options are needed.

Build and install the TPM2 tools following the instructions found
[here](https://tpm2-tools.readthedocs.io/en/latest/#build-and-installation-instructions). (Note: the
`tpm2-tabrmd` is not needed for our use-case.)

To build and install the software TPM emulator (taken and modified from
[here](https://github.com/tpm2-software/tpm2-software-container/blob/master/modules/ibmtpm1637.m4)):

```bash
cd /tmp
wget -L "https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm1637.tar.gz"
mkdir -p ibmtpm1637
tar xv --no-same-owner -f ibmtpm1637.tar.gz -C ibmtpm1637
rm ibmtpm1637.tar.gz
cd ibmtpm1637/src
sed -i 's/-DTPM_NUVOTON/-DTPM_NUVOTON $(CFLAGS)/' makefile
CFLAGS="-DNV_MEMORY_SIZE=32768 -DMIN_EVICT_OBJECTS=7" make -j$(nproc)
sudo cp tpm_server /usr/local/bin
rm -fr /tmp/ibmtpm1637
```

### Building the service

To fetch and build the Parsec service:

```bash
git clone -b attested-tls https://github.com/ionut-arm/parsec.git
cd parsec
cargo build --features=tpm-provider,direct-authenticator
export PARSEC=$(pwd)/target/debug/parsec
```

Once the build steps are done, the Parsec executable can be found at `$PARSEC`.

### Running the service

To run the service, the software TPM2.0 server must first be started:

```bash
pushd /tmp
tpm_server &
tpm2_startup -c -T mssim
popd
```

The Parsec service relies on a configuration file to instruct it what type of RoT to use, whether to
provision an attesting key and so on. An example configuration file that can be used to run this PoC
can be found [here](parsec-config.toml). Once this file has been created, say at path
`$PARSEC_CONFIG`, the service can be run:

```bash
RUST_LOG=info $PARSEC -c $PARSEC_CONFIG
```

### Cleaning up

When stopping the service, a few extra steps need to be taken.

The service can simply be stopped through `pkill`, followed by the software TPM:

```bash
pkill parsec
pkill tpm_server
```

If the system needs to be preserved to continue the testing at a later point, then no other changes
need to be made (though it's important to note that all persistent values are in `/tmp/`, so a
reboot could have them deleted). Otherwise, to fully clean up the data and allow a fresh run:

```bash
rm -rf /tmp/mappings
rm /tmp/NVChip
rm /tmp/parsec.sock
```

Build artifacts and executables will still be available in the repo directory.

## Parsec client

Parsec clients exist for multiple languages, however the PoC used here revolves around the C client.
In particular, because of the cryptography-centric nature of Parsec APIs, and because of its origin
in the PSA Cryptography API, most of the Parsec functionality is available in C via the PSA Crypto
API, via a Secure Element (SE) driver interface that plugs into the PSA Crypto implementation.
However, because attestation is *not* part of the PSA Crypto API, attestation primitives are exposed
separately, directly to C clients.

In order to build this hybrid C client library, a local copy of mbedTLS is needed:

```bash
git clone https://github.com/ARMmbed/mbedtls.git
cd mbedtls
git checkout v3.0.0
./scripts/config.py crypto
./scripts/config.py set MBEDTLS_PSA_CRYPTO_SE_C
export MBEDTLS_PATH=$(pwd)
```

After which the Parsec client can be built:

```bash
git clone -b attested-tls https://github.com/ionut-arm/parsec-se-driver.git
cd parsec-se-driver
MBEDTLS_INCLUDE_DIR=$MBEDTLS_PATH/include cargo build
```

And the library can then be found in `./target/debug/libparsec_se_driver.a`.
