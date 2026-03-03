#!/usr/bin/env bash
# Usage: check_csvs.sh <year_start> <year_end>
#
# Scans the checked-out repo for committed CSVs in the range [year_start, year_end].
# Prints a space-separated list of years whose CSV is absent.
# Prints nothing (empty string) if all CSVs are present.

set -euo pipefail

YEAR_START=${1:?year_start required}
YEAR_END=${2:?year_end required}

MISSING=()

for yr in $(seq "$YEAR_START" "$YEAR_END"); do
  if [ ! -f "data/built_by_adm2/built_${yr}_by_adm2.csv" ]; then
    MISSING+=("$yr")
  fi
done

echo "${MISSING[*]-}"   # empty string when array is empty
