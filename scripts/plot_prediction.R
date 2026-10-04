# Visualization only. Run from the repository root.
# Select Scytodes_panamensis_fc.LQ_rm.1.5_cloglog.tif exported by Wallace.
if (!requireNamespace("terra", quietly = TRUE)) {
  stop("Install terra before running this script.")
}
prediction_path <- file.choose()
pred <- terra::rast(prediction_path)
stopifnot(terra::nlyr(pred) == 1)
print(pred)
print(terra::global(pred, c("min", "max"), na.rm = TRUE))
terra::plot(pred,
  main = "Scytodes panamensis: exploratory climatic suitability",
  col = grDevices::hcl.colors(30, "YlOrRd", rev = TRUE)
)
# This script does not rerun Wallace, select a model or validate predictions.
