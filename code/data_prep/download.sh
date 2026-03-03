#!/usr/bin/env bash
# Downloads and unzips GHS_BUILT_S for 2020 and 2025
# Also downloads ADM2 boundaries
# Cleans up zips immediately after extraction

set -euo pipefail

BASE_URL="https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_BUILT_S_GLOBE_R2023A"
GEOBOUNDARIES_URL="https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/CGAZ/geoBoundariesCGAZ_ADM2.geojson"

mkdir -p raw-data/built_2020 \
         raw-data/built_2025 \
         raw-data/boundaries \
         data/interpolated-rasters \
         data/pop_data_by_adm2

#-------------------------------------------------------------------------------
download_built() {
  local year=$1
  local name="GHS_BUILT_S_E${year}_GLOBE_R2023A_4326_30ss_V1_0"
  local url="${BASE_URL}/GHS_BUILT_S_E${year}_GLOBE_R2023A_4326_30ss/V1-0/${name}.zip"
  local zip="raw-data/built_${year}.zip"
  local out="raw-data/built_${year}"

  if [ -d "$out" ] && [ -n "$(ls -A "$out")" ]; then
    echo "[skip] $year already extracted"
    return 0
  fi

  echo "[download] GHS_BUILT_S ${year}..."
  curl -fsSL --retry 3 --retry-delay 10 \
    --progress-bar \
    -o "$zip" \
    "$url"

  echo "[unzip] $year..."
  unzip -q "$zip" -d "$out"

  echo "[cleanup] removing zip for $year"
  rm -f "$zip"

  # print size of what we kept
  du -sh "$out"
}

#-------------------------------------------------------------------------------
download_boundaries() {
  local out="raw-data/boundaries/geoBoundariesCGAZ_ADM2.geojson"

  if [ -f "$out" ]; then
    echo "[skip] ADM2 boundaries already downloaded"
    return 0
  fi

  echo "[download] ADM2 boundaries..."
  curl -fsSL --retry 3 --retry-delay 10 \
    --progress-bar \
    -L \
    -o "$out" \
    "$GEOBOUNDARIES_URL"

  du -sh "$out"
}

#-------------------------------------------------------------------------------
download_built 2020
download_built 2025
download_boundaries

echo ""
echo "All downloads complete. Raw data:"
du -sh raw-data/*/