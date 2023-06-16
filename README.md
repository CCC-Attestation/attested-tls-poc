# Hardware-Backed Attestation in TLS

## Welcome!

This repository holds miscellaneous materials related to a proof-of-concept of the "Using
Attestation in Transport Layer Security (TLS) and Datagram Transport Layer Security (DTLS)" internet
draft ([link](https://datatracker.ietf.org/doc/draft-fossati-tls-attestation/)).

## What's Here?

This repository is a central space for open collaboration on the proof-of-concept.

There isn't very much source code held directly in this repository. Code for the contributing
components is pulled from other GitHub repositories, some of which have been branched or forked in
order to develop the code for this specific proof-of-concept. What you'll find here are the Docker
recipes and build scripts that pull all of the strands together into a complete, end-to-end demo
that is easy to build and execute. There is also a body of design documents that have been used to
establish the interfaces between individual components for those behaviours that are not otherwise
governed by the above internet draft and related standards.

## How Can I Run the Demo?

Everything that you need is here. Simply [install Docker](https://docs.docker.com/get-docker/) and
follow this simple sequence of [steps](demo/README.md).

## The Background: Why Are We Doing This?

Authentication of remote workloads and services is a difficult process with high security stakes.
Software-based solutions (such as those leveraging PKI) which are currently the norm fail to
reliably convey the security state of the workload in the face of impersonation and persistent
attackers. This is most apparent in cases where the underlying platform is particularly exposed and
out of the control of the owner, such as in cloud computing and IoT. Hardware features have thus
been introduced to enable remotely verifiable “trust metrics” using attestation. Such
hardware-backed features provide a cryptographic proof of the software stack, and strong guarantees
that the cryptographic keys used by the workload are properly protected from exfiltration.

However, remote attestation comes with its own need to share and verify metadata, which must be
engineered into existing software. While the protocol used to exchange this metadata is largely
irrelevant to the actual attestation procedure, its positioning in the networking stack can enable
specific use-cases and enhance the performance of the entire system. An appealing approach is to
allow the creation of secure channels (such as TLS connections) using attestation metadata as the
authentication mechanism. Current designs either rely on running an attestation protocol on top of
an existing secure channel, or modify the semantics of certificates to convey attestation
information when establishing the secure channel.

Our work focuses on standardizing attestation metadata as first-class credentials in TLS. This new
approach allows native, opaque metadata to be conveyed for authentication during the TLS handshake
instead of (or together with) x509 certificates. Supporting flexibility in deployments without
compromising on security has been a prime goal. Thus, we aim to cater to interaction models in which
either the client, the server, or both can attest themselves, leveraging any hardware backend, and
using different verification topologies.

To showcase the standardization effort, we are also developing this open-source and end-to-end
proof-of-concept implementation of one of the interaction models supported. The PoC builds on top of
two Linux Foundation projects – [Parsec](https://parsec.community/) to abstract the root of trust
attestation primitives, and [Veraison](https://github.com/veraison) to consume and verify the new
evidence formats. It also enhances [mbedTLS](https://github.com/Mbed-TLS/mbedtls) to support a
subset of the newly defined TLS extensions. As a hardware root of trust, the proof of concept is
currently using a TPM2.0, with support for others being considered.

## Additional Documentation

This repository maintains the following additional documents that relate to some internal details of
the proof-of-concept. These documents are collaborative resources that are intended to be useful for
the individuals and teams who are working on the implementation. They are not required reading if
you only want to run the demo.

- [Getting the mbedTLS prototype installed on MacOSX](doc/mbedtls-build.md)
- [Getting the Parsec prototype installed](doc/parsec-build.md)
- [TPM Parsec Evidence](doc/parsec-evidence-tpm.md)
- [CCA Parsec Evidence](doc/parsec-evidence-cca.md)
- [How to synthesise attestation results produced by Veraison](doc/play-by-ear.md)
