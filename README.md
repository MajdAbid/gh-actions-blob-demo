# gh-actions-blob-demo

Automated pipeline to interpolate GHS Built-S rasters (2020–2025) and extract population-weighted built-up area per ADM2 boundary using GitHub Actions.

## Structure

```
code/
  data_prep/    # R scripts and bash helpers for the pipeline
  functions/    # Reusable R functions
  packages/     # Custom package code
data/
  pop_data_by_adm2/   # Output CSVs committed by the pipeline
```

## Workflow

The pipeline runs weekly (`0 6 * * 1`) via `.github/workflows/interpolate.yml` and processes one year per run until all six years (2020–2025) are committed.
