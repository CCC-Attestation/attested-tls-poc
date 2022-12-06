# Hardware-backed attestation in TLS

This repository holds miscellaneous materials related to a proof-of-concept of the "Using
Attestation in Transport Layer Security (TLS) and Datagram Transport Layer Security (DTLS)" internet
draft ([link](https://datatracker.ietf.org/doc/draft-fossati-tls-attestation/)).

## Motivation

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

To showcase the standardization effort, we are also developing an open-source an end-to-end
proof-of-concept implementation of one of the interaction models supported. The PoC builds on top of
two Linux Foundation projects – [Parsec](https://parsec.community/) to abstract the root of trust
attestation primitives, and [Veraison](https://github.com/veraison) to consume and verify the new
evidence formats – and modifies [mbedTLS](https://github.com/Mbed-TLS/mbedtls) to support a subset
of the newly defined TLS extensions. As a hardware root of trust, the proof of concept is currently
using a TPM2.0, with support for others being considered.

## Proof of Concept

As mentioned above, one of the core outcomes of this project is a PoC representing an end-to-end
system, from RoT to verifier. The code forming the various components is not hosted in this
repository - instead, instructions are provided for building each individual component and the
system as a whole. Steps for setting up the components are available for:

- [mbedTLS](mbedtls-build.md)
- [Parsec](parsec-build.md)
