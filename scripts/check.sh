#!/usr/bin/env bash
# Checks which years are missing outputs, sets flags for the workflow

set -euo pipefail

RASTERS_DONE=true # Assumes it's done at first
CSV_DONE=true # Assumes it's done at first

for yr in 2020 2021 2022 2023 2024 2025; do
  if [ ! -f "process-data/interpolated-rasters/built_${yr}.tif" ]; then
    echo "Missing raster: built_${yr}.tif"
    RASTERS_DONE=false
  fi
    if [ ! -f "process-data/built_by_adm2/built_${yr}_by_adm2.csv" ]; then
    echo "Missing CSV: built_${yr}_by_adm2.csv"
    CSV_DONE=false
  fi
done

echo "rasters_done=$RASTERS_DONE" >> "${GITHUB_OUTPUT:-/dev/stdout}"
echo "csv_done=$CSV_DONE"         >> "${GITHUB_OUTPUT:-/dev/stdout}"

echo "Check complete — rasters_done=$RASTERS_DONE csv_done=$CSV_DONE"