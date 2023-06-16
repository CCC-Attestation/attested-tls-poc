# How to synthesise attestation results produced by Veraison

## Prerequisite

### Step CLI

The [`step` CLI](https://smallstep.com/cli/) has an awesome `crypto jwt` subcommand to deal with JWTs (of which EAR is an instance).

See [installation instructions](https://smallstep.com/docs/step-cli/installation) for the most common platforms.

(TL;DR -- On MacOSX, do `brew install step`.)

### Obtain the `veraison/ear` examples

* Clone Veraison's EAR repo:
```sh
git clone https://github.com/veraison/ear
```

* Go to the "example claims-sets" folder:
```sh
cd ear/arc/data
```

## Create (and verify) a "successful" EAR

* Create:
```sh
step crypto jwt sign --subtle --alg=ES256 --key=skey.json ear-claims-key-attestation-ok.json > ear-ok.jwt
```

* Verify:
```sh
cat ear-ok.jwt | step crypto jwt verify --key=pkey.json --subtle
```

Note the presence of the `"ear.veraison.key-attestation"` claim.

## Create (and verify) an "unsuccessful" EAR

* Create:
```sh
step crypto jwt sign --subtle --alg=ES256 --key=skey.json ear-claims-key-attestation-ko.json > ear-ko.jwt
```

* Verify:
```sh
cat ear-ko.jwt | step crypto jwt verify --key=pkey.json --subtle
```

Note the absence of the `"ear.veraison.key-attestation"` claim.
