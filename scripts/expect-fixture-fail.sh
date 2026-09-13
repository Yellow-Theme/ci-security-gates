#!/usr/bin/env bash
# Run the documented fail fixtures. Exit 0 only if both tools fail the fixture.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
missing=0

if ! command -v semgrep >/dev/null 2>&1; then
  echo "semgrep is not installed; cannot prove the eval fixture fails"
  missing=1
else
  set +e
  semgrep scan --config "$root/fixtures/rules" --error "$root/fixtures" --metrics=off
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    echo "expected semgrep to exit non-zero on fixtures/eval.js"
    exit 1
  fi
  echo "semgrep fixture exited ${status} (expected non-zero)"
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "gitleaks is not installed; cannot prove the example-key fixture fails"
  missing=1
else
  set +e
  gitleaks detect --no-git --source "$root/fixtures" --config "$root/fixtures/gitleaks-fail.toml" --verbose
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    echo "expected gitleaks to exit non-zero on fixtures/config.env"
    exit 1
  fi
  echo "gitleaks fixture exited ${status} (expected non-zero)"
fi

if [ "$missing" -ne 0 ]; then
  exit 2
fi
