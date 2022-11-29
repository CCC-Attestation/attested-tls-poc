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

Oddly, there is no `install` target in ctoken.  A bit of DIY is needed:

```sh
sudo mkdir -p /usr/local/include/ctoken
sudo install -m 644  inc/ctoken/ctoken* /usr/local/include/ctoken
sudo install -m 644 libctoken.a /usr/local/lib
```

## Build Hannes's mbedTLS

```
git clone https://github.com/hannestschofenig/mbedtls
cd mbedtls
git checkout tls-attestation
make CFLAGS="-DCTOKEN_LABEL_CNF=8 -DCTOKEN_TEMP_LABEL_KAK_PUB=2500" LDFLAGS="-lqcbor -lctoken -lt_cose"
```
