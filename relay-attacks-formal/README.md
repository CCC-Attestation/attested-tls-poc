<div align="center">

# High-severity Relay Attacks on Attested TLS Proof-of-Concept

[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

</div>

## Overview

This folder contains the artifacts for formal specification and analysis of the attested TLS proof-of-concept in this repo. 

We identified seven candidate binding mechanisms for binding in **intra-handshake attestation** for standardization of attested TLS protocols:
<!---
TODO: Present as table: Binder # and Meaning
--->
1. Client’s TLS nonce
2. Client’s attestation nonce
3. Early exporter
4. Server’s public key
5. Combination of #2 and #3
6. Combination of #2 and #4
7. Combination of #2, #3, and #4

Attested TLS proof-of-concept in this repo uses mechanism #6.

> [!NOTE]
> We provide a proof of **insecurity** of attested TLS proof-of-concept implementation in this repo using the state-of-the-art tool [ProVerif](https://ieeexplore.ieee.org/document/9833653).

## Binding Levels
1. DH shared secret
2. Handshake traffic key
3. Application traffic key

## Correlation Goals
We consider TLS Server as RATS Attester, which is typical in confidential computing.

1. Correlation of Evidence to a DH Shared Secret (G1)
2. Correlation of Evidence to Client’s Handshake Traffic Key (G2)
3. Correlation of Evidence to Client’s Application Traffic Key (G3)

## Main result

- The implementation of attested TLS proof-of-concept does not satisfy any of the correlation properties and is thus vulnerable to relay attacks.

| Property                   	        | Mechanism #6 |
| :--                		              | :--    |
| G1 : Correlation of Evidence to gxy | ❌     |
| G2 : Correlation of Evidence to kch | ❌     |
| G3 : Correlation of Evidence to kc  | ❌     |


> [!NOTE]
> Because of high-severity vulnerabilities, we very strongly recommend the developers and maintainers NOT to use this proof-of-concept.
 
<!---
#❓
--->

## Artifacts author
Muhammad Usama Sardar (contact: muhammad_usama.sardar at tu-dresden.de)

## Paper authors
Muhammad Usama Sardar, Viacheslav Dubeyko, and Jean-Marie Jacquet

## Pre-print
Preprint is available [here](https://www.researchgate.net/publication/408219182_Intra-handshakefail_CVE-2026-33697_High-severity_CVE_in_Attested_TLS).

## Scientific Publication
The formal analysis in this repo is part of the work accepted for publication at ESORICS and should be cited as follows: 

> Muhammad Usama Sardar, Viacheslav Dubeyko, and Jean-Marie Jacquet. 2026.
Intra-handshake.fail (CVE-2026-33697): High-severity CVE in Attested TLS.
In 31st European Symposium on Research in Computer Security (ESORICS) 2026,
September 14-18, 2026, Rome, Italy. LNCS,
20 pages.

BibTeX:
```
@inproceedings{Sardar2026IntraFail,
author = {Sardar, Muhammad Usama and Dubeyko, Viacheslav and Jacquet, Jean-Marie},
booktitle = {Proceedings of the 31st European Symposium on Research in Computer Security (ESORICS) 2026},
publisher = {LNCS},
title = {{Intra-handshake.fail (CVE-2026-33697): High-severity CVE in Attested TLS}},
year = {2026}
}
```

For Internet-Drafts:
```
  Intra-handshake.fail:
    title: "Intra-handshake.fail (CVE-2026-33697): High-severity CVE in Attested TLS"
    date: June 2026,
    target: https://www.researchgate.net/publication/408219182_Intra-handshakefail_CVE-2026-33697_High-severity_CVE_in_Attested_TLS
    author:
      - ins: M. U. Sardar
      - ins: V. Dubeyko
      - ins: J-M. Jacquet
```

and then use as ``{{Intra-handshake.fail}}``

For citing the corresponding repo with complete artifacts:
```
  Intra-handshake.fail-repo:
    title: "Intra-handshake.fail (CVE-2026-33697): High-severity CVE in Attested TLS"
    date: July 2026,
    target: https://github.com/muhammad-usama-sardar/intra-handshake.fail
    author:
      - ins: M. U. Sardar
      - ins: V. Dubeyko
      - ins: J-M. Jacquet
```

and then use as ``{{Intra-handshake.fail-repo}}``

## Acknowledgments
We gratefully acknowledge the following for insightful discussions on this work:

- Eric Rescorla
- Juho Forsén
- Markus Rudy
- Mariam Moustafa
- Bruno Blanchet
- Steve Kremer
- Tjaden Hess
- Martin Thomson
- Yuning Jiang
- Pavel Nikonorov
- Casey Wilson
- Danko Miladinovic
- Songbo Bu
- Nathanael Ritz

We also gratefully acknowledge the following who gave feedback on [previous state-of-the-art](https://github.com/CCC-Attestation/formal-spec-id-crisis) that we utilize as the basis:

- Tuomas Aura
- Ionut Mihalcea
- Thomas Fossati
- Hannes Tschofenig
- Yaron Sheffer
- Laurence Lundblade
- Giridhar Mandyam
- Christopher Patton
- Jonathan Hoyland
- Richard Barnes

Several others at the IETF, IRTF, CCC, and GA4GH have contributed by providing feedback.

We sincerely thank Karthikeyan Bhargavan, Bruno Blanchet, and Nadim Kobeissi for the foundational formal model of draft 20 of TLS 1.3 in their [work](https://ieeexplore.ieee.org/document/7958594).

## Tool 
We use state-of-the-art symbolic security analysis tool [ProVerif](https://ieeexplore.ieee.org/document/9833653) for the specification of the protocols. 
### Installing ProVerif
Install the latest version (2.05 at the moment) of ProVerif: see https://bblanche.gitlabpages.inria.fr/proverif/ for details.
See Section 1.4 of [manual](https://bblanche.gitlabpages.inria.fr/proverif/manual.pdf) for installation options:
- via OPAM: Section 1.4.1
- from sources: Section 1.4.2 or simply try the [script](https://github.com/CCC-Attestation/formal-spec-TEE/blob/main/installProVerif.sh) by replacing 2.04 by 2.05
- from binaries: Section 1.4.3 

## Modeling

The formal model uses the [fixed version of diversion attacks in intra-handshake attestation](https://github.com/CCC-Attestation/formal-spec-id-crisis/tree/main/TLS-a/fix) from our previous work as the starting point to focus on relay attacks in intra-handshake attestation in this work.
The rationale is that we consider it more useful to show the added value of this contribution to the community by using the [fixed version of diversion attacks in intra-handshake attestation](https://github.com/CCC-Attestation/formal-spec-id-crisis/tree/main/TLS-a/fix) as the baseline, rather than showing the same diversion attacks from [ID-Crisis paper](https://dl.acm.org/doi/10.1145/3779208.3785387), and the discovered CVE (CVE-2026-33697) -- which the previous analysis could not find -- practically demonstrates the added value.

## Artifacts organization
<details>
<summary>Click to expand folder details</summary>

- Folder `binder6` contains code for binding mechanism #6.

</details>

```text
relay-attacks-formal/
│
├── README.md                        # README file
│
└── binder6/                         # Analysis for binding mechanism #6
      ├── tls-lib-simple.pvl         # ProVerif library file for correlation properties
      ├── other-props.pvl            # (Optional) ProVerif library file for other properties
      ├── tls13-multiagent.pv        # ProVerif main file
      └── log.txt                    # log of ProVerif execution
```


## Running automatic proofs 

For completeness, optional commands for running other properties are also provided for each.

### Basic Execution
Run as follows: 

```bash 
proverif -lib tls-lib-simple.pvl tls13-multiagent.pv
```

#### With other properties
```bash 
proverif -lib tls-lib-simple.pvl -lib other-props.pvl tls13-multiagent.pv
```


### Generation of traces for failing properties
In order to additionally generate a trace for each property which results in "false", create a subfolder (e.g., `traces` in the following command) for results before executing.

```bash 
mkdir traces
```

Then to execute: run as follows:
```bash 
proverif -lib tls-lib-simple.pvl -graph traces tls13-multiagent.pv
```

OR 
```bash 
proverif -lib tls-lib-simple.pvl -html traces tls13-multiagent.pv
```

Subfolder `traces` will contain the traces in .dot as well as .PDF.

#### With other properties
```bash 
proverif -lib tls-lib-simple.pvl -lib other-props.pvl -graph traces tls13-multiagent.pv
```

OR 
```bash 
proverif -lib tls-lib-simple.pvl -lib other-props.pvl -html traces tls13-multiagent.pv
```

### Saving log
To additionally save in log file together with display:
```bash
proverif -lib tls-lib-simple.pvl -html traces tls13-multiagent.pv 2>&1 | tee log.txt
```

#### With other properties
```bash
proverif -lib tls-lib-simple.pvl -lib other-props.pvl -html traces tls13-multiagent.pv 2>&1 | tee log.txt
```

### Horn clauses
To additionally see the Horn clauses generated in ProVerif: 

a. use command-line option `-test` as follows: 
```bash
proverif -lib tls-lib-simple.pvl tls13-multiagent.pv -test
```

OR 

b. add one of the following two settings inside the input (*.pv) file:

- `set verboseClauses = short.` to display the Horn clauses

- `set verboseClauses = explained.` to additionally display a sentence after each clause it generates to explain where this clause comes from.

#### With other properties
a. use command-line option `-test` as follows: 
```bash
proverif -lib tls-lib-simple.pvl -lib other-props.pvl tls13-multiagent.pv -test
```

OR 

b. as above

### Interactive mode
To run in interactive mode:
```bash
proverif_interact -lib tls-lib-simple.pvl tls13-multiagent.pv
```

#### With other properties
```bash
proverif_interact -lib tls-lib-simple.pvl -lib other-props.pvl tls13-multiagent.pv
```

## Upcoming and Recent Talks and Research Visits

If you are around on any of the following venues of upcoming talks (in reverse chronological order) on topics related to the project, you are very welcome to join/meet. 

| Event/Host | Venue | Date(s) | Funding | Material |
| --- | --- | --- | --- | --- |
| [GA4GH 14th Plenary Meeting](https://www.ga4gh.org/event/14th-plenary/) | Singapore | 28 Sept-2 Oct, 2026 | Sponsors are invited | slides, video |
| [ESORICS 2026](https://sites.google.com/di.uniroma1.it/esorics2026/) | Rome, Italy | 14-18 Sept, 2026 | Sponsors are invited | slides |
| [IETF 126](https://www.ietf.org/meeting/126/) | Vienna, Austria | 18-24 July, 2026 | Sponsors are invited | slides, video |
| [IETF 126 Hackathon](https://www.ietf.org/meeting/hackathons/126-hackathon/) | Vienna, Austria | 18-24 July, 2026 | Sponsors are invited | [Hackathon project](https://wiki.ietf.org/en/meeting/126/hackathon#cve-2026-33697-cvss-75-intra-handshakefail), slides, video |
| [Workshop](https://www.wissenschaftsnacht-dresden.de/programm/detailansicht/confidential-computing-15585) @ [Dresden Science Night 2026](https://www.wissenschaftsnacht-dresden.de/en/) | Dresden | 26 June, 2026 | - | [demo](https://www.wissenschaftsnacht-dresden.de/programm/detailansicht/confidential-computing-15585) |
| [Output 2026](https://output-dd.de/) | Dresden | 25 June, 2026 | - | [demo](https://output-dd.de/projekte/relay-attacks-in-intra-handshake-attestation-for-confidential-agentic-ai-systems/) |
| [Confidential Computing Summit 2026](https://events.linuxfoundation.org/confidential-computing-summit/) (presented by Jens Albers) | San Francisco, USA | 23-24 June, 2026 | - | poster, video |
| [Workshop for the 25 years of ProVerif](https://bblanche.gitlabpages.inria.fr/proverif//25years.html) | Paris, France | 3 June, 2026 | Sponsors are invited | - |
| Confidential Containers @ [Cloud Native Computing Foundation](https://www.cncf.io/) | Virtual | 30 April, 2026 | - | slides, video |
| GIF Project showcase @ [GA4GH April Connect 2026](https://www.ga4gh.org/event/april-connect-2026/) | Montreal, Canada (virtual) | 17 April, 2026 | - | slides, [video](https://youtu.be/Kr9oxp1fdn0?t=1083), [report](https://www.ga4gh.org/document/arpril-connect-2026-meeting-report/) |
| [NSA Symposium on Hot Topics in the Science of Security (HotSoS) 2026](https://sos-vo.org/group/hotsos/) | Virtual | 16 April, 2026 | - | [abstract](https://sos-vo.org/group/hotsos/2026/sardar), [slides](https://sos-vo.org/system/files/2026-04/20260416_HotSoS%20%281%29.pdf), [video](https://sos-vo.org/group/hotsos/2026/sardar) |
| [PET-CON 2026.1: 15th Privacy Enhancing Techniques Convention](https://fg-pet.gi.de/veranstaltung/15th-privacy-enhancing-techniques-convention) | Karlsruhe, Germany | 16-17 April, 2026 | Sponsors are invited | slides |
| [GTMFS 2026: Annual Meeting of the WG "Formal Methods in Security"](https://gtmfs2026.sciencesconf.org/program?lang=en) | Luz-Saint-Sauveur, France | 24-26 Mar, 2026 | Sponsors are invited | slides |
| TLS @ [IETF 125](https://www.ietf.org/meeting/125/) | Shenzhen, China (virtual) | 20 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-tls-tls-fatt-extensions-00), [video](https://youtu.be/2GkmQmRlkto?t=3988) |
| CFRG @ [IETF 125](https://www.ietf.org/meeting/125/) | Shenzhen, China (virtual) | 19 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-cfrg-relay-attacks-00), [video](https://youtu.be/IfKgbO74Lt4?t=6054) |
| SEAT @ [IETF 125](https://www.ietf.org/meeting/125/) (expat) | Shenzhen, China (virtual) | 17 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-seat-seat-expat-00), [video](https://youtu.be/hX7genEkN7w?t=3169) |
| SEAT @ [IETF 125](https://www.ietf.org/meeting/125/) (relay) | Shenzhen, China (virtual) | 17 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-seat-security-analysis-00), [video](https://youtu.be/hX7genEkN7w?t=676) |
| Side meeting @ [IETF 125](https://www.ietf.org/meeting/125/) | Shenzhen, China (virtual) | 16 Mar, 2026 | - | [slides](https://www.researchgate.net/publication/403474373_Proposed_RG_Confidential_AI) |
| LAKE @ [IETF 125](https://www.ietf.org/meeting/125/) | Shenzhen, China (virtual) | 16 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-lake-formal-analysis-of-attested-edhoc-00), [video](https://youtu.be/JzfLpbnhl0A?t=3117) |
| HotRFC @ [IETF 125](https://www.ietf.org/meeting/125/) | Shenzhen, China (virtual) | 15 Mar, 2026 | - | [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-hotrfc-sessa-formal-proof-of-insecurity-of-intra-handshake-attestation-00), [video](https://youtu.be/OtOo7Nogisw?t=3514) |
| [IETF 125 Hackathon](https://www.ietf.org/meeting/hackathons/125-hackathon/) | Shenzhen, China (virtual) | 14-15 Mar, 2026 | - | [Hackathon project](https://wiki.ietf.org/en/meeting/125/hackathon#relay-attacks-in-intra-handshake-attestation-for-confidential-agentic-ai-systems), [slides](https://datatracker.ietf.org/meeting/125/materials/slides-125-hackathon-sessd-relay-attacks-in-intra-handshake-attestation-00), [video](https://youtu.be/62A58qH19MI?t=2270) |
| [Open Confidential Computing Conference (OC3)](https://www.oc3.dev/) | Berlin  | 12 Mar, 2026 | - | - |
| CCC Attestation SIG | Virtual | 10 Feb, 2026 | - | slides; [video](https://www.youtube.com/watch?v=idqwb0hFlhs&list=PLmfkUJc39uMhZsNGmpx-qD-uCoQyMglIp&t=1061s) |
| [IETF RATS Interim meeting](https://datatracker.ietf.org/meeting/interim-2026-rats-01/session/rats) | Virtual | 9 Feb, 2026 | - | [slides](https://datatracker.ietf.org/meeting/interim-2026-rats-01/materials/slides-interim-2026-rats-01-sessa-relayattacks-00.pdf), [video](https://youtu.be/gURY61dViPw?t=1474)  |
| [Confidential Computing](https://fosdem.org/2026/schedule/track/confidential-computing/) devroom at [FOSDEM 2026](https://fosdem.org/2026/) | Brussels, Belgium | 31 Jan-1 Feb, 2026 | [CCC](https://confidentialcomputing.io/) | [abstract](https://fosdem.org/2026/schedule/event/GHGFBM-attestedtls/), [slides](https://fosdem.org/2026/events/attachments/GHGFBM-attestedtls/slides/267432/20260201_60u9e0n.pdf), [video](https://video.fosdem.org/2026/ud6215/GHGFBM-attestedtls.av1.webm) |
| CCC Attestation SIG | Virtual | 27 Jan, 2026 | - | slides; [video](https://youtu.be/P04tLJcSxfM?list=PLmfkUJc39uMhZsNGmpx-qD-uCoQyMglIp&t=434) |
| CCC Attestation SIG | Virtual | 13 Jan, 2026 | - | slides; [video](https://youtu.be/cSrCZNyo7_g?list=PLmfkUJc39uMhZsNGmpx-qD-uCoQyMglIp&t=1083) |
| CCC Attestation SIG | Virtual | 2 Dec, 2025 | - | slides; [video](https://youtu.be/16aGZ-oZidg?list=PLmfkUJc39uMhZsNGmpx-qD-uCoQyMglIp&t=2920) |

## Feedback/Comments/Critique/Contributions
We would love to have your contributions and feedback (especially critique! yes, this is how the science progresses, but please be genuine!). Contact Muhammad Usama Sardar on CCC Slack Workspace, by [email](https://tu-dresden.de/ing/informatik/sya/se/die-professur/beschaeftigte/muhammad-usama-sardar), submit a minimal PR, or open an issue. 
