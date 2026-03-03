# 01_interpolate.R
#
# Usage:
#   Rscript 01_interpolate.R <tif_start> <tif_end> <year_start> <year_end> <out_dir> [year ...]
#
# Pure computation — no network calls, no git ops.
#
# Reads the two anchor rasters (<tif_start> for year_start, <tif_end> for year_end)
# and writes one TIF per requested year into <out_dir>.
#
# If no explicit years are supplied, writes all years in [year_start, year_end].
# Interpolation is linear: r(t) = r_start + ((r_end - r_start) / span) * t
# where t = year - year_start.  Anchor years (t=0 and t=span) are written as-is.

suppressPackageStartupMessages(library(terra))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 5) {
  stop(paste(
    "Usage: Rscript 01_interpolate.R",
    "<tif_start> <tif_end> <year_start> <year_end> <out_dir> [year ...]"
  ))
}

tif_start  <- args[1]
tif_end    <- args[2]
year_start <- as.integer(args[3])
year_end   <- as.integer(args[4])
out_dir    <- args[5]

# Years to write: explicit list if provided, otherwise the full range
target_years <- if (length(args) >= 6) {
  as.integer(args[-(1:5)])   # drop the first 5 positional args
} else {
  seq(year_start, year_end)
}

span <- year_end - year_start
if (span <= 0) stop("year_end must be greater than year_start")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

message("Reading anchor rasters ...")
r_start <- terra::rast(tif_start)
r_end   <- terra::rast(tif_end)

for (yr in target_years) {
  t        <- yr - year_start
  out_path <- file.path(out_dir, paste0("built_", yr, ".tif"))
  message("  Writing ", yr, "  (t = ", t, " / ", span, ") -> ", out_path)

  r <- if (t == 0) {
    r_start
  } else if (t == span) {
    r_end
  } else {
    r_start + (((r_end - r_start) / span) * t)
  }

  terra::writeRaster(r, out_path, overwrite = TRUE)
}

message("Interpolation complete for years: ", paste(target_years, collapse = " "))
