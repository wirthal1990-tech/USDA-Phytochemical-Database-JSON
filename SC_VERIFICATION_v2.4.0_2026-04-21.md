# SC Verification v2.4.0 (2026-04-21)

## Metadata
- Timestamp (UTC): 2026-04-21T12:33:25Z
- Scope:
  - /opt/ethno-api/ethno-enrichment/USDA-Phytochemical-Database-JSON v2
  - /opt/ethno-api/nexus_api/pseo
- Live URLs:
  - https://ethno-api.com/
  - https://ethno-api.com/enterprise.html
- Constraints honored:
  - no force push
  - no reset --hard
  - additive/corrective commits only

## Checkpoint 0 - Soll/Ist before correction

| Topic | Soll | Ist before correction | Evidence |
|---|---|---|---|
| Remote heads | origin/main == hf/main (or explicit divergence) | origin/main=dea08aebe0e7381d108ebd452c456f102693770c, hf/main=ab3a21ced9f43637054b7d71fbe4f97d22e319ec | `git ls-remote origin refs/heads/main`, `git ls-remote hf refs/heads/main` |
| Merge relation | deterministic relation known | merge-base=dea08aebe0e7381d108ebd452c456f102693770c, origin ancestor of hf | `git merge-base`, `git merge-base --is-ancestor` |
| Canonical local landing source | should match live markers | /opt/ethno-api/nexus_api/pseo/enterprise.html had DOI_NEW=0, DOI_OLD=4, V240=0, V231=11, field markers=0 | `grep -o ... | wc -l` |
| Version authority | current version should reflect active release | `Current version: v2.3.1 (April 2026)` while v2.4.0 changelog present | `grep -n 'Current version:' UPDATE_POLICY.md` |

## Actions executed

1. Deterministic baseline measurement (git + live + local markers).
2. Remote divergence handling without rewrite:
   - fast-forward local main to hf/main: `git merge --ff-only hf/main`
   - result local head: `ab3a21ced9f43637054b7d71fbe4f97d22e319ec`
3. Version authority correction:
   - file: UPDATE_POLICY.md
   - change: `Current version: v2.3.1` -> `Current version: v2.4.0`
   - commit: `dba76475dd07e3c4703b142000a757d5f991d340`
4. Source-of-truth correction for landing page:
   - canonical file set to: /opt/ethno-api/nexus_api/pseo/enterprise.html
   - updated from live enterprise response and re-verified with marker counts.
5. Pushes (non-destructive):
   - `git push origin main`
   - `git push hf main`

## Checkpoint 1 - Remote status after correction

Commands:

```bash
git rev-parse HEAD
GIT_TERMINAL_PROMPT=0 git ls-remote origin refs/heads/main
GIT_TERMINAL_PROMPT=0 git ls-remote hf refs/heads/main
```

Measured:
- HEAD: dba76475dd07e3c4703b142000a757d5f991d340
- origin/main: dba76475dd07e3c4703b142000a757d5f991d340
- hf/main: dba76475dd07e3c4703b142000a757d5f991d340

Result:
- Sync achieved, same head on both remotes.

## Checkpoint 2 - Landing source-of-truth vs live

Canonical local file:
- /opt/ethno-api/nexus_api/pseo/enterprise.html

Measured local canonical markers:
- BYTES=89560
- DOI_NEW=4
- DOI_OLD=0
- V240=11
- V231=0
- partner_cid=2
- inchi_key=2
- iupac_verified=2
- partner_match_method=2

Measured live markers:
- https://ethno-api.com/
  - BYTES=89560
  - DOI_NEW=4, DOI_OLD=0, V240=11, V231=0
  - partner_cid=2, inchi_key=2, iupac_verified=2, partner_match_method=2
- https://ethno-api.com/enterprise.html
  - BYTES=89560
  - DOI_NEW=4, DOI_OLD=0, V240=11, V231=0
  - partner_cid=2, inchi_key=2, iupac_verified=2, partner_match_method=2

Note on SHA drift:
- Marker and byte-size alignment is exact.
- Full-file SHA differs between requests due Cloudflare dynamic challenge token injection in response body tail.
- This was validated by `cmp -l` with only 14 differing bytes near the CF token segment.

## Checkpoint 3 - Version and policy consistency

Command:

```bash
grep -n 'Current version:' UPDATE_POLICY.md
```

Measured:
- `15:Current version: v2.4.0 (April 2026)`

Result:
- Version authority now consistent with v2.4.0 release state.

## SC1-SC6 claim matrix

| SC | Soll | Measurement command(s) | Ist | Result |
|---|---|---|---|---|
| SC1 | HF Dataset Viewer available | `curl -4 -s "https://datasets-server.huggingface.co/is-valid?dataset=wirthal1990-tech/USDA-Phytochemical-Database-JSON"` | `{... "viewer":true, "search":true, "filter":true ...}` | PASS |
| SC2 | 16-field marker presence on live (new 4 fields each x2) | `grep -o 'partner_cid\|inchi_key\|iupac_verified\|partner_match_method'` on live body | each marker count = 2 | PASS |
| SC3 | New DOI present, old DOI absent | `grep -o '19660107'` and `grep -o '19265853'` on live + repo files | live: 4/0, README: 6/0, llms: 3/0, UPDATE_POLICY: 3/0, noise list: 1/0 | PASS |
| SC4 | Build vs Buy EUR values present | `grep -o '16,900'`, `grep -o '11,300'` on live; `grep -n '16,900\|11,300' README.md` | live: 1 and 1, README line 168 shows `~€16,900 / ~€11,300` | PASS |
| SC5 | Repo update consistency | marker counts in README/llms/UPDATE_POLICY/noise_exclusion/METHODOLOGY + unified remote head | counts consistent and both remotes on same head | PASS |
| SC6 | No v2.3.1 on live landing | `grep -o 'v2\.3\.1'` on live URLs | 0 | PASS |

## Triple-SC protocol status

### SC1 Structural
- Required files present in dataset repo.
- Canonical landing source named and present: /opt/ethno-api/nexus_api/pseo/enterprise.html.
- Persistent report created: SC_VERIFICATION_v2.4.0_2026-04-21.md.
- Status: PASS.

### SC2 Numerical
- Remote hashes measured and equal post-correction.
- DOI/version/field counts documented with command method.
- Live byte sizes measured for both production URLs.
- Status: PASS.

### SC3 Live
- Production URLs verified directly via curl.
- HF datasets-server endpoint verified live.
- Status: PASS.

## Open risks
- LOW: Full-file SHA comparison against live is unstable because Cloudflare injects per-request challenge token bytes into HTML tail. Marker-level and byte-size checks remain reproducible.

## Final state summary
- GitHub main and HF main synchronized at: dba76475dd07e3c4703b142000a757d5f991d340
- Canonical local landing source aligned to live markers and byte size.
- SC1-SC6 all PASS with numeric evidence.
