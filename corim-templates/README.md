# How to ship Parsec TPM endorsements to Veraison

* Install [`cocli`](https://github.com/veraison/corim/cocli/README.md):

```shell
go install github.com/veraison/corim/cocli@latest 
```

* Create a folder to stash the CoMID intermediates:

```shell
mkdir out
```

* Create the CoMID for the attestation verification key:

```shell
cocli comid create -o out -t comid-key.json
```

* Create the CoMID for the "golden" PCR values:

```shell
cocli comid create -o out -t comid-pcr.json
```

* Assemble the CoRIM (`corim-parsec-tpm.cbor`):

```shell
cocli corim create -t corim.json -M out -o corim-parsec-tpm.cbor
```

* Ship the CoRIM to Veraison (you'll need to change the URL to match your deployment):

```shell
cocli corim submit -f corim-parsec-tpm.cbor \
                   -s 'https://veraison.example/endorsement-provisioning/v1/submit' \
                   -m 'application/corim-unsigned+cbor; profile="tag:github.com/parallaxsecond,2023-03-03:tpm"'
```
