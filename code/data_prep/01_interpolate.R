# 01_interpolate.R
# Usage: Rscript 01_interpolate.R <tif_2020> <tif_2025> <out_dir>
# Pure compute — bash handles everything else

suppressPackageStartupMessages(library(terra))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
  stop("Usage: Rscript 01_interpolate.R <tif_2020> <tif_2025> <out_dir>")
}

tif_2020 <- args[1]
tif_2025 <- args[2]
out_dir  <- args[3]

#-------------------------------------------------------------------------------
interpolate_rast <- function(r1, r2, t) {
  r1 + (((r2 - r1) / 5) * t)
}

out_path <- function(year) {
  file.path(out_dir, paste0("built_", year, ".tif"))
}

#-------------------------------------------------------------------------------
message("Reading anchor rasters...")
r2020 <- terra::rast(tif_2020)
r2025 <- terra::rast(tif_2025)

# Write anchor years
message("Writing 2020...")
terra::writeRaster(r2020, out_path(2020), overwrite = TRUE)

message("Writing 2025...")
terra::writeRaster(r2025, out_path(2025), overwrite = TRUE)

# Interpolate 2021-2024
for (t in 1:4) {
  yr <- 2020 + t
  message("Interpolating ", yr, "...")
  r <- interpolate_rast(r2020, r2025, t)
  terra::writeRaster(r, out_path(yr), overwrite = TRUE)
  message("  -> ", out_path(yr))
}

message("Interpolation complete.")
