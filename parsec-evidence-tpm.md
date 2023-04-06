# TPM Parsec Evidence

This document describes the format of the credential produced by the Parsec
service as a key attestation credential for TPM-backed keys.

The Parsec service produces a blob of binary data as a response to a key
attestation operation issued by a client. The service takes in a nonce and uses
it as freshness for the two attestation tokens it produces.

The attestation token produced by Parsec is a CBOR encoded structure, namely a
[Combined Attestation Bundle
(CAB)](https://datatracker.ietf.org/doc/draft-bft-rats-kat/). The full
high-level format is shown below.

```
parsecTpmAttestation = {
    "kat" => parsecTpmKeyStmtFormat,
    "pat" => parsecTpmPlatStmtFormat
}
```

The definition of `parsecTpmKeyStmtFormat` can be found in
[this](format-definitions/parsec-key-evidence-tpm.md) document, while the
definition of `parsecTpmPlatStmtFormat` can be found in
[this](format-definitions/parsec-platform-evidence-tpm.md) document.

The CAB produced by Parsec is then encapsulated in a [Conceptual Message
Wrapper](https://datatracker.ietf.org/doc/draft-ftbs-rats-msg-wrap/), which is
simply a CBOR-encoded array with the first value identifying the type of the
second value. In this specific case, the type is represented by the string
`application/vnd.parallaxsecond.key-attestation.tpm`, a media type string: 

```
[
    "application/vnd.parallaxsecond.key-attestation.tpm"
    bytes .cbor parsecTpmAttestation 
]
```
