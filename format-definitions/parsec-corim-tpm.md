# Parsec TPM endorsement

This document covers the technical details of the metadata produced by the Parsec service for endorsing the platform to Veraison.

The endorsement will allow the Veraison-based verifier to trust and verify attestation tokens produced by this platform. Two endorsements are needed: one to identify the identity key used by the platform to sign attestation tokens, and another one to specify the reference values expected for a class of platforms. The identity key endorsement must be provided for each platform that needs to attest itself, while the platform endorsement is only needed once per class of platforms. A class of platforms is a group of devices expected to run identical software stacks, which would thus produce identical quotes as platform attestation tokens.

## TPM key endorsement format

Endorsements for a Veraison-based verifier are provided in a CoRIM format. In our use-case, the endorsements for platform identity keys are JSON encoded using the template below.

```json
{
    "tag-identity": {
            "id": uuid // example: uuid = "00000000-0000-0000-0000-000000000000"
        },
    "entities": [
        {
            "name": "PARSEC",
            "regid": "https://github.com/parallaxsecond",
            "roles": [
                "tagCreator",
                "creator",
                "maintainer"
            ],
        }
    ],
    "triples": {
        "attester-verification-keys": [
            {
                "environment": {
                    "class": {
                        "type": "uuid",
                        "value": class // example: class = "ffffffff-ffff-ffff-ffff-ffffffffffff"
                    },
                    "instance": {
                        "type": "ueid",
                        "value": key_id, // example: key_id = "f05eae32-0003-4a82-8cfa-3780ea7817a0"
                    }
                },
                "verification-keys": [
                    {
                        "key": key, // example: key = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAETKRFE_RwSXooI8DdatPOYg_uiKm2XrtT_uEMEvqQZrwJHHcfw0c3WVzGoqL3Y_Q6xkHFfdUVqS2WWkPdKO03uw=="
                    }
                ]
            }
        ]
    }
}
```

- `uuid` (String): A random UUID that will identify the endorsement.
- `class` (String): The class of devices to which this platform belongs. This will link the platform with reference PCR values, which are provided in a separate endorsement document.
- `key_id`: (String) A fingerprint of the public part of the cryptographic key which will be used as the identity key of the platform.
- `key` (String): The BASE64 encoding of the Subject Public Key Info of the identity key of the platform identified by `key_id`.

## TPM platform class endorsement format

Endorsements for a Veraison-based verifier are provided in a CoRIM format. In our use-case, the endorsements for platform measurements for a given device class are JSON encoded using the template below.

```json
{
  "tag-identity": {
    "id": uuid // example: uuid = "00000000-0000-0000-0000-000000000000"
  },
  "entities": [
    {
      "name": "Parsec TPM",
      "regid": "https://github.com/parallaxsecond",
      "roles": [
        "tagCreator",
        "creator",
        "maintainer"
      ]
    }
  ],
  "triples": {
    "reference-values": [
      {
        "environment": {
          "class": {
            "type": "uuid",
            "value": class // example: class = "ffffffff-ffff-ffff-ffff-ffffffffffff"
          }
        },
        "measurements": [
          {
            "key": {
              "type": "uint",
              "value": pcr[0]['index'] // example: pcr[0]['index'] = 0
            },
            "value": {
              "digests": pcr[0]['reference-values']
                // example: pcr[0]['reference-values'] = [
                // "sha-256:h0KPxSKAPTEGXnvOPPA/5HUJZjHl4Hu9eg/eYMTPJcc=",
                // "sha-384:QoS1aUymwNLPR4mguVrIAlyBjeUjBDZL580pgbLS7caFsyInfsJYGZYkE9jJssH1"
                //   ]
            }
          },
          {
            "key": {
              "type": "uint",
              "value": pcr[1]['index']
            },
            "value": {
              "digests": pcr[1]['reference-values']
            }
          }
        ]
      }
    ]
  }
}
```

- `uuid` (String): A random UUID that will identify the endorsement.
- `class` (String): The class of devices that this endorsement describes. This identifier can then be used in per-platform endorsements to succintly define the expected platform state.
- `pcr`: An array of PCR descriptions covering each PCR index and reference values for at least one hashing algorithm.
    - `pcr[n]['index']` (int): The PCR index for the n'th PCR included in this endorsement.
    - `pcr[n]['reference-values']` (Array[String]): An array of reference values for the n'th PCR included in this endorsement, encoding the hash algorithm and the digest result for that algorithm, formatted as `hash_alg:digest`. Example: `sha-256:h0KPxSKAPTEGXnvOPPA/5HUJZjHl4Hu9eg/eYMTPJcc=`
