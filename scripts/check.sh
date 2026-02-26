#!/usr/bin/env bash
# Inspects the repo checkout to decide what still needs to be done.

set -euo pipefail

CSV_DONE=true
REMAINING_YEARS=()

for yr in 2020 2021 2022 2023 2024 2025; do
  if [ ! -f "process-data/built_by_adm2/built_${yr}_by_adm2.csv" ]; then
    CSV_DONE=false
    REMAINING_YEARS+=("$yr")
    echo "csv_done_${yr}=false" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  else
    echo "csv_done_${yr}=true" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  fi
done

echo "csv_done=$CSV_DONE" >> "${GITHUB_OUTPUT:-/dev/stdout}"
echo "remaining_count=${#REMAINING_YEARS[@]}" >> "${GITHUB_OUTPUT:-/dev/stdout}"

echo "Check complete — csv_done=$CSV_DONE remaining=${REMAINING_YEARS[*]:-none}"
