# 02_extract_adm2.R
#
# Usage:
#   Rscript 02_extract_adm2.R <tif_path> <geojson_path> <out_csv>
#
# Pure computation — no network calls, no git ops.
#
# Reads a single built-up raster and the global ADM2 boundary file, then
# produces a CSV with one row per ADM2 unit containing the population-weighted
# sum of built-up area in m².
#
# The year is parsed from the TIF filename (expected pattern: built_YYYY.tif).
#
# Output columns: year, shapeID, country, adm2, built_m2

suppressPackageStartupMessages({
  library(terra)
  library(sf)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
  stop("Usage: Rscript 02_extract_adm2.R <tif_path> <geojson_path> <out_csv>")
}

tif_path <- args[1]
geojson  <- args[2]
out_csv  <- args[3]

# Parse year from filename (e.g. "built_2020.tif" -> 2020)
year <- as.integer(regmatches(basename(tif_path),
                               regexpr("\\d{4}", basename(tif_path))))
if (is.na(year)) stop("Cannot parse year from TIF filename: ", basename(tif_path))

message("Year: ", year)
message("Reading ADM2 boundaries ...")
all_borders <- sf::st_read(geojson, quiet = TRUE)
countries   <- unique(all_borders$shapeGroup)
message("  ", length(countries), " countries, ", nrow(all_borders), " ADM2 units")

message("Reading raster ...")
pop_raster <- terra::rast(tif_path)
layer_name <- names(pop_raster)[1]

results_df <- NULL

for (ctry in countries) {
  borders <- all_borders |> dplyr::filter(shapeGroup == ctry)

  tryCatch({
    pop <- terra::extract(pop_raster, borders, weights = TRUE) |>
      dplyr::group_by(ID) |>
      dplyr::summarise(
        built_sum = sum(.data[[layer_name]] * weight, na.rm = TRUE),
        .groups   = "drop"
      )

    results_df <- dplyr::bind_rows(results_df, data.frame(
      year     = year,
      shapeID  = borders$shapeID,
      country  = borders$shapeGroup,
      adm2     = borders$shapeName,
      built_m2 = pop$built_sum
    ))
  }, error = function(e) {
    message("  [skip] ", ctry, ": ", conditionMessage(e))
  })
}

dir.create(dirname(out_csv), recursive = TRUE, showWarnings = FALSE)
write.csv(results_df, out_csv, row.names = FALSE)

total <- terra::global(pop_raster, fun = "sum", na.rm = TRUE)[[1]]
kept  <- sum(results_df$built_m2, na.rm = TRUE)
message("Loss: ", round((1 - kept / total) * 100, 2), "%  (NA/gap pixels not captured by ADM2)")
message("Saved: ", out_csv, "  (", nrow(results_df), " rows)")
