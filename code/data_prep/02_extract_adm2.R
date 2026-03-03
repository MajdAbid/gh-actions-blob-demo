# 02_extract_adm2.R
# Usage: Rscript 02_extract_adm2.R <raster_dir> <geojson_path> <out_dir>
# Pure compute — bash handles everything else

suppressPackageStartupMessages({
  library(terra)
  library(sf)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3 || length(args) > 4) {
  stop("Usage: Rscript 02_extract_adm2.R <raster_dir> <geojson_path> <out_dir> [year]")
}

raster_dir  <- args[1]
geojson     <- args[2]
out_dir     <- args[3]
target_year <- if (length(args) == 4) as.integer(args[4]) else NULL

#-------------------------------------------------------------------------------
message("Reading ADM2 boundaries...")
all_admin_borders <- sf::st_read(geojson, quiet = TRUE)
countries <- unique(all_admin_borders$shapeGroup)

#-------------------------------------------------------------------------------
extract_year <- function(year) {
  rast_path <- file.path(raster_dir, paste0("built_", year, ".tif"))
  out_csv   <- file.path(out_dir, paste0("built_", year, "_by_adm2.csv"))

  message("\n--- Year: ", year, " ---")
  pop_raster  <- terra::rast(rast_path)
  results_df  <- NULL
  layer_name  <- names(pop_raster)[1]

  for (raster_country in countries) {
    admin_borders <- all_admin_borders |> filter(shapeGroup == raster_country)

    tryCatch({
      pop <- terra::extract(pop_raster, admin_borders, weights = TRUE) |>
        group_by(ID) |>
        summarise(
          built_sum = sum(.data[[layer_name]] * weight, na.rm = TRUE),
          .groups = "drop"
        )

      results_df <- bind_rows(results_df, data.frame(
        year     = year,
        shapeID  = admin_borders$shapeID,
        country  = admin_borders$shapeGroup,
        adm2     = admin_borders$shapeName,
        built_m2 = pop$built_sum
      ))
    }, error = function(e) {
      message("  [skip] ", raster_country, ": ", e$message)
    })
  }

  write.csv(results_df, out_csv, row.names = FALSE)

  total    <- terra::global(pop_raster, fun = "sum", na.rm = TRUE)[[1]]
  kept     <- sum(results_df$built_m2, na.rm = TRUE)
  message("  Loss: ", round((1 - kept / total) * 100, 2), "%")
  message("  Saved: ", out_csv)
}

#-------------------------------------------------------------------------------
years_to_process <- if (!is.null(target_year)) target_year else 2020:2025
for (year in years_to_process) {
  extract_year(year)
}

message("\nDone: ", paste(years_to_process, collapse = ", "))