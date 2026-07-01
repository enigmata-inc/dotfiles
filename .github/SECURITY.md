# Security Policy

Enigmata, Inc. builds confidential-data infrastructure, so we treat security issues as a top
priority. This policy applies to this repository: it describes how to report a vulnerability and
what to expect in return.

## Reporting a vulnerability

Please report suspected vulnerabilities privately. Do not open a public issue or pull request, and
do not include live secrets, real customer data, or production values in a report.

Report privately through our contact form at https://www.enigmata.xyz/contact. You will receive an
acknowledgement, and we will coordinate a fix and a disclosure timeline with you.

When you report, please include where you can:

- a description of the issue and its impact,
- the affected component or repository,
- steps to reproduce or a proof of concept (synthetic data only, never real sensitive values),
- any relevant logs, requests, or configuration, with secrets redacted.

## What to expect

- Acknowledgement within 3 business days.
- An initial assessment (severity, affected versions, planned remediation) within 10 business days.
- Coordinated disclosure: we will agree a disclosure timeline with you and credit you if you wish.
  Please give us a reasonable window to remediate before any public disclosure.

## Supported versions

Security fixes land on the default branch (`main`) and the current released or deployed version.
Older versions do not receive security fixes; consumers should track the latest release.

## Scope

In scope: the code and deployment configuration in this repository. Out of scope: findings that
require a compromised operator workstation or stolen privileged credentials (AWS, GitHub, WorkOS),
social engineering, volumetric denial-of-service, and reports generated solely by automated scanners
without a demonstrated, reproducible impact.

## Safe harbor

We will not pursue or support legal action against researchers who, in good faith, follow this
policy: who avoid privacy violations, data destruction, and service degradation, who only interact
with accounts they own or have explicit permission to test, and who give us a reasonable time to
remediate before disclosure.
