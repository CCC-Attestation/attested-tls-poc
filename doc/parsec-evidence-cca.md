# CCA Parsec Evidence

This document describes the format of the credential produced by the Parsec
service as a key attestation credential for applications running in an Arm CCA
Realm.

The Parsec service produces a blob of binary data as a response to a key
attestation operation issued by a client. The service takes in a nonce and uses
it as freshness for the attestation token.

The attestation token produced by Parsec is a CBOR encoded structure, namely a
[Combined Attestation Bundle
(CAB)](https://datatracker.ietf.org/doc/draft-bft-rats-kat/). The format is
described below in CDDL.

```
parsecCcaAttestation = {
    "kat" => UCCS-KAT,
    "pat" => CCA-token
}

UCCS-KAT = <TBD601>({
  &(eat_nonce: 10) => bstr .size (8..64)
  &(cnf: 8) => ik-pub
})

ik-pub = cnf-map

cnf-map = {
  &(cose-key: 1) => COSE_Key
}
```

- `pat`: An Arm CCA Attestation Token as defined in the [Arm CCA Realm
   Management Monitor
   specification](https://developer.arm.com/documentation/den0137/latest) (see
   "Attestation Token Format" section). Note that this token represents the
   entire credential issued by the Root of Trust, composed of a CCA platform
   token and a CCA Realm token. The Platform Attestation Token (PAT) referenced
   by this document should not be confused with the CCA platform token.
- `kat`: A sidecar token used to link the application identity key to the PAT.
- `eat_nonce`: A nonce issued by the challenger to prove the freshness of the
   attestation token.
- `cnf`: The public part of the application identity key, encoded as a
   [COSE_Key](https://www.rfc-editor.org/rfc/rfc9052#name-key-objects).

PAT contains a collection of tokens, which are individually signed. The PAT is
also cryptographically linked to the Key Attestation Token (KAT) to provide the
assurance needed for the origin of the application identity key. The linking
MUST be performed by hashing the encoded KAT with the SHA512 algorithm, and
using the resulting fingerprint as a challenge when obtaining the PAT.

## Verification procedure

The verification procedure is as follows:

- Verify that the `parsecCcaAttestation` token is in the right format (as
   defined above).
- Verify that the `pat` is a valid Arm CCA attestation token. The exact steps
   for this are omitted from this document, and should instead be gathered from
   alternative sources.
- Verify that the `kat` and `pat` are correctly linked together.
   - Extract the `kat` from the `parsecCcaAttestation` token.
   - Hash the `kat` using the SHA512 algorithm.
   - Verify that the challenge claim (denoted `cca-realm-challenge` in the
      specification) included in the `pat` is equal to the fingerprint computed
      in the previous step.
- Verify that the `kat` is using the correct CBOR tag.
- Verify that the `eat_nonce` included in the KAT is the one provided by the
   challenger.
- If succesful, return the application identity key described under `cnf`.

## CMW encoding

The CAB produced by Parsec is encapsulated in a [Conceptual Message
Wrapper](https://datatracker.ietf.org/doc/draft-ftbs-rats-msg-wrap/), which is
simply a CBOR-encoded array with the first element identifying the type of the
second element. In this specific case, the type is represented by the string
`application/vnd.parallaxsecond.key-attestation.tpm`, a media type string:

```
[
    "application/vnd.parallaxsecond.key-attestation.cca"
    bytes .cbor parsecCcaAttestation
]
```
