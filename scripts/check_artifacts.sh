#!/usr/bin/env bash
# Usage: check_artifacts.sh <artifact_prefix> <year1> [year2 ...]
#
# For each year, queries the GitHub Actions API for a non-expired artifact
# named "{artifact_prefix}-{year}".
# Prints a space-separated list of years with no valid artifact.
# Prints nothing (empty string) if all years have valid artifacts.
#
# Requires: GH_TOKEN and GITHUB_REPOSITORY env vars (both set automatically
# in GitHub Actions; set manually for local testing).

set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN must be set}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"

PREFIX=${1:?artifact_prefix required}
shift
YEARS=("$@")

if [ ${#YEARS[@]} -eq 0 ]; then
  exit 0
fi

MISSING=()

for yr in "${YEARS[@]}"; do
  NAME="${PREFIX}-${yr}"
  INFO=$(gh api \
    "repos/${GITHUB_REPOSITORY}/actions/artifacts?name=${NAME}&per_page=5" \
    --jq '[.artifacts[] | select(.expired == false)] | last // empty')

  if [ -z "$INFO" ] || [ "$INFO" = "null" ]; then
    MISSING+=("$yr")
  fi
done

echo "${MISSING[*]-}"   # empty string when array is empty
