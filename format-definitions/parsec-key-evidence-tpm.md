
# Parsec TPM key attestation data format

This document describes the data encoding for key attestation tokens produced using a TPM. The format relies on the [Attestation Object](https://www.w3.org/TR/webauthn/#sctn-attestation) format defined in WebAuthN, using the [TPM attestation statement format](https://www.w3.org/TR/webauthn-2/#sctn-tpm-attestation). All data structures below are expected to be encoded in [CTAP canonical CBOR encoding](https://fidoalliance.org/specs/fido-v2.0-ps-20190130/fido-client-to-authenticator-protocol-v2.0-ps-20190130.html#ctap2-canonical-cbor-encoding-form).

## TPM Attestation Statement Format

The attestation statement format defined for TPM backends is defined below.

CDDL representation of TPM Attestation Statement Format:
```
tpmStmtFormat = {
                 ver: "2.0",
                 alg: COSEAlgorithmIdentifier,
                 x5c: [ aikCert: bytes, * (caCert: bytes) ],
                 kid: bytes,
                 sig: bytes,
                 certInfo: bytes,
                 pubArea: bytes
             }
```


- `ver`: The version of the TPM specification to which the signature conforms.
- `alg`: A COSEAlgorithmIdentifier containing the identifier of the algorithm used to generate the attestation signature.
- `x5c`: (Optional) `aikCert` followed by its certificate chain, in X.509 encoding.
    - `aikCert`: The AIK certificate used for the attestation, in X.509 encoding.
- `kid`: (Optional) An identifier that is shared between attester and verifier to uniquely identify the AIK (for example, a thumbprint of the public part of the key). 
- `sig`: The attestation signature, in the form of a TPMT_SIGNATURE structure as specified in [TPMv2-Part2](https://trustedcomputinggroup.org/wp-content/uploads/TCG_TPM2_r1p59_Part2_Structures_pub.pdf) section 11.3.4.
- `certInfo`: The TPMS_ATTEST structure over which the above signature was computed, as specified in [TPMv2-Part2](https://trustedcomputinggroup.org/wp-content/uploads/TCG_TPM2_r1p59_Part2_Structures_pub.pdf) section 10.12.8.
- `pubArea`: The TPMT_PUBLIC structure (see [TPMv2-Part2](https://trustedcomputinggroup.org/wp-content/uploads/TCG_TPM2_r1p59_Part2_Structures_pub.pdf) section 12.2.4) used by the TPM to represent the credential public key.

The signature (`sig`) described above is that produced using the TPM2_Certify operation. In order to ensure freshness, the WebAuthN spec mandates the use of `extraData` in the operation. This extra data is obtained by hashing `attToBeSigned`, which represents the concatenation of `authData` and `clientDataHash`. Given that neither of these two fields is relevant in our case, `extraData` will instead contain a nonce provided by the relying party - `relyingPartyNonce`.

## Verification procedure

Given the verification procedure inputs `attStmt` and `relyingPartyNonce`, the verification procedure is as follows:

- Verify that `attStmt` is valid CBOR conforming to the syntax defined above and perform CBOR decoding on it to extract the contained fields.

- Verify that either `aikCert` or `kid` is present. Note: if both exist, the `kid` will be ignored.

- Verify the `sig` is a valid signature over `certInfo` using the attestation public key in `aikCert`, or the key identified by `kid` if `aikCert` is missing, with the algorithm specified in `alg`.

- If `aikCert` is present, verify that `aikCert` meets the requirements in § 8.3.1 TPM Attestation Statement Certificate Requirements.

- Validate that `certInfo` is valid:

    * Verify that `magic` is set to TPM_GENERATED_VALUE.

    * Verify that `type` is set to TPM_ST_ATTEST_CERTIFY.

    * Verify that `extraData` is set to `relyingPartyNonce`.

    * Verify that `attested` contains a TPMS_CERTIFY_INFO structure as specified in [TPMv2-Part2](https://trustedcomputinggroup.org/wp-content/uploads/TCG_TPM2_r1p59_Part2_Structures_pub.pdf) section 10.12.3, whose name field contains a valid Name for `pubArea`, as computed using the algorithm in the `nameAlg` field of `pubArea` using the procedure specified in [TPMv2-Part1] section 16.

    * Note that the remaining fields in the "Standard Attestation Structure" [TPMv2 Part1](https://trustedcomputinggroup.org/wp-content/uploads/TCG_TPM2_r1p59_Part1_Architecture_pub.pdf) section 31.2, i.e., `qualifiedSigner`, `clockInfo` and `firmwareVersion` are ignored. These fields MAY be used as an input to risk engines.

- If successful, return implementation-specific values representing attestation type AttCA and attestation trust path `x5c` if present, or the identity endorsed through `kid`.

**Note**: The above steps only serve as verification for the key attestation steps, **not** for platform attestation.