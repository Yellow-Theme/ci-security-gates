# ci-security-gates

Synthetic reference. Not a client repository, not an audit conclusion, and not a certification.

One GitHub Actions workflow a Series A team can copy. It fails closed on three checks. Comments name the control. The evidence an assessor opens is the run URL plus the uploaded artifact, not a screenshot.

License: MIT. See [LICENSE](LICENSE).

## Observed enforcement

These runs are the evidence. Do not screenshot the checks column.

**Red — deliberate demo (do not merge).** [PR #6](https://github.com/Yellow-Theme/ci-security-gates/pull/6) added `minimist@1.2.5` to `app/`. Required `deps` failed at `npm audit --omit=dev --audit-level=high`. Artifact: `npm-audit`. Run: https://github.com/Yellow-Theme/ci-security-gates/actions/runs/34777787760

**Green — happy path on `main`.** Semgrep on `app/`, gitleaks on `app/`, no deps in `app/`. Artifacts: `semgrep-sarif`, `npm-audit`, `gitleaks-sarif`. Run: https://github.com/Yellow-Theme/ci-security-gates/actions/runs/34777643696

## What this is

[`.github/workflows/security-gates.yml`](.github/workflows/security-gates.yml) runs on `pull_request` and `push`. Three jobs:

| Job | Check | Control comment | Artifact |
| --- | --- | --- | --- |
| `sast` | `semgrep scan --config p/ci` on `app/` | change management / secure SDLC | `semgrep-sarif` |
| `deps` | `npm audit --omit=dev --audit-level=high` in `app/` | vulnerability management | `npm-audit` |
| `secrets` | gitleaks on `app/` only | secrets management hygiene | `gitleaks-sarif` |

`app/` is a tiny Node package with no dependencies, so the happy path stays green without a registry token and without `SEMGREP_APP_TOKEN`.

On this repository, `sast`, `deps`, and `secrets` are required to merge into `main`. Repository admins can bypass the ruleset to ship a reference fix. Secret scanning is enabled; push protection is off so the documented example key in `fixtures/` can stay. If scanning opens an alert on that string, dismiss it as the documented example.

## What this is not

- Not CodeQL. CodeQL on a private customer repo needs extra GitHub code-scanning setup. This sample uses Semgrep public rules so the job needs no app token.
- Not Semgrep Cloud. `semgrep ci` is optional and needs `SEMGREP_APP_TOKEN`. Do not require that token for the happy path.
- Not a passing SOC 2 report, a client system, or a screenshot pack. A green run on this repo does not mean a customer criterion is met.
- Not a scan of `fixtures/`. That directory is the documented fail path. The required jobs do not scan it, so `main` stays green.
- Image scanning (for example Trivy) is a later add. It is not a required job here.

## Copy the workflow

1. Copy `.github/workflows/security-gates.yml`. Point the Semgrep and gitleaks steps at your application directory, not this sample's `app/`.
2. This repo pins third-party actions to commit SHAs with a tag comment, for example `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # actions/checkout@v7 (pinned 2026-09-13)` and `gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # gitleaks/gitleaks-action@v3 (pinned 2026-09-13)`. Dependabot refreshes the pins weekly.
3. In branch protection for `main`, require the checks `sast`, `deps`, and `secrets`. A failed job blocks merge only after those checks are required. This workflow cannot mark itself required.
4. Keep the jobs fail closed. Do not set `continue-on-error`.

The required secrets check is the open-source gitleaks CLI, pinned at 8.30.1 with a checksum. The optional `gitleaks/gitleaks-action` step is SHA-pinned in the workflow and runs only when `GITLEAKS_LICENSE` is set. Organization accounts need a free license for that action; personal accounts do not. The CLI does not need it.

## Evidence an assessor should open

Open the workflow run for the change. Download `semgrep-sarif`, `npm-audit`, and `gitleaks-sarif`. The job summary names the control, states that a required check blocks merge, and says the run URL plus the artifact is the evidence.

A screenshot of a green check is not the artifact.

## Fixture that should fail

`fixtures/` is not on the required path. `fixtures/config.env` holds the AWS documentation example key `AKIAIOSFODNN7EXAMPLE`. It is not a credential. `fixtures/eval.js` is one `eval` call. A local Semgrep rule flags it.

Default gitleaks rules ignore `AKIAIOSFODNN7EXAMPLE`, so the fail command uses `fixtures/gitleaks-fail.toml`, a local rule for that documented example. The required job does not use that file.

These commands are supposed to exit non-zero:

```bash
semgrep scan --config fixtures/rules --error fixtures --metrics=off
gitleaks detect --no-git --source fixtures --config fixtures/gitleaks-fail.toml --verbose
```

`bash scripts/expect-fixture-fail.sh` runs both and exits 0 only if each tool fails the fixture. It exits 2 if a tool is not installed.

The required jobs scan `app/` only. Do not point them at `fixtures/` if you want `main` to stay green.

Local happy path, from this repo:

```bash
semgrep scan --config p/ci --metrics=off --error app
cd app && npm audit --omit=dev --audit-level=high
gitleaks detect --no-git --source app --config .gitleaks.toml --redact
```

## How this maps to Guardrails

This is the shape of the Guardrails “CI security gates” deliverable: a PR check that fails closed, a control comment an assessor can read, and a run URL plus artifact instead of a slide. It is a reference, not a client install. It does not by itself satisfy a Trust Services Criterion.

The companion index traces a control id to this workflow. The companion policies are the git rules, not a PDF pack.

- [ci-security-gates](https://github.com/yellow-theme/ci-security-gates)
- [policy-as-code](https://github.com/yellow-theme/policy-as-code)
- [evidence-index](https://github.com/yellow-theme/evidence-index)
