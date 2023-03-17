# Parsec TPM endorsement

This document covers the technical details of the metadata produced by the Parsec service for endorsing the platform to Veraison.

The endorsement will allow the Veraison-based verifier to trust and verify attestation tokens produced by this platform. Two endorsements are needed: one to identify the identity key used by the platform to sign attestation tokens, and another one to specify the reference values expected for a class of platforms. The identity key endorsement must be provided for each platform that needs to attest itself, while the platform endorsement is only needed once per class of platforms. A class of platforms is a group of devices expected to run identical software stacks, which would thus produce identical quotes as platform attestation tokens.

## TPM key endorsement format

Endorsements for a Veraison-based verifier are provided in a CoRIM format. In our use-case, the endorsements for platform identity keys are JSON encoded as shown in the example below.

```json
{
    "tag-identity": {
            "id": "E194FE9E-8E76-45C3-84F2-7923E7BFE1AE"
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
                      "id": {
                        "type": "uuid",
                        "value": "96E16ABC-39B1-42BA-9FBF-2336657F5D76"
                      }
                    },
                    "instance": {
                        "type": "ueid",
                        "value": "ASUILRBQqkJrl7AXDc4RbQ7RFyg2+NZNWIZ0F2W1np91"
                    }
                },
                "verification-keys": [
                    {
                        "key": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAETKRFE_RwSXooI8DdatPOYg_uiKm2XrtT_uEMEvqQZrwJHHcfw0c3WVzGoqL3Y_Q6xkHFfdUVqS2WWkPdKO03uw=="
                    }
                ]
            }
        ]
    }
}
```

## TPM platform class endorsement format

Endorsements for a Veraison-based verifier are provided in a CoRIM format. In our use-case, the endorsements for platform measurements for a given device class are JSON encoded as shown in the example below.

```json
{
  "tag-identity": {
    "id": "B397E0BA-1B0B-4F24-AFCA-0CF4F4167ED0"
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
            "id": {
              "type": "uuid",
              "value": "96E16ABC-39B1-42BA-9FBF-2336657F5D76"
            }
            
          }
        },
        "measurements": [
          {
            "key": {
              "type": "uint",
              "value": 0
            },
            "value": {
              "digests": [
                  "sha-256:h0KPxSKAPTEGXnvOPPA/5HUJZjHl4Hu9eg/eYMTPJcc=",
                  "sha-384:QoS1aUymwNLPR4mguVrIAlyBjeUjBDZL580pgbLS7caFsyInfsJYGZYkE9jJssH1"
                ]
            }
          },
          {
            "key": {
              "type": "uint",
              "value": 1
            },
            "value": {
              "digests": [
                "sha-256:+Fa5VtRzrPOmLEE7Azg3LzqyZf/GttRony4d99U1N4E=",
                "sha-384:opRHhgSPFrfbRdR/erchTOvz6yY40HCz7JvIvrktiI2qVPyeF87oK3uOOpNC+2ly"
              ]
            }
          }
        ]
      }
    ]
  }
}
```
