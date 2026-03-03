#!/usr/bin/env bash
# Usage: download_raw.sh <year> <out_dir>
#
# Downloads and unzips the GHS_BUILT_S_R2023A raster for a single anchor year
# from the JRC FTP server. Removes the zip immediately after extraction.
# Skips silently if <out_dir> already contains files.
#
# Valid anchor years: 1975 1980 1985 1990 1995 2000 2005 2010 2015 2020 2025

set -euo pipefail

YEAR=${1:?year required}
OUT_DIR=${2:?out_dir required}

BASE_URL="https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_BUILT_S_GLOBE_R2023A"
NAME="GHS_BUILT_S_E${YEAR}_GLOBE_R2023A_4326_30ss_V1_0"
URL="${BASE_URL}/GHS_BUILT_S_E${YEAR}_GLOBE_R2023A_4326_30ss/V1-0/${NAME}.zip"

# Skip if already extracted
if [ -d "$OUT_DIR" ] && [ -n "$(ls -A "$OUT_DIR" 2>/dev/null)" ]; then
  echo "[skip] ${YEAR} already extracted in ${OUT_DIR}"
  exit 0
fi

mkdir -p "$OUT_DIR"
ZIP="$(dirname "$OUT_DIR")/built_${YEAR}.zip"

echo "[download] GHS_BUILT_S ${YEAR} ..."
curl -fsSL --retry 3 --retry-delay 10 --progress-bar -o "$ZIP" "$URL"

echo "[unzip] ${YEAR} ..."
unzip -q "$ZIP" -d "$OUT_DIR"

echo "[cleanup] removing zip"
rm -f "$ZIP"

echo "[done] $(du -sh "$OUT_DIR" | cut -f1) written to ${OUT_DIR}"
