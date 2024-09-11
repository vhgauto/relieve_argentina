
dem <- obj$dem
mat <- obj$matrix

format(object.size(mat), units = "Mb")

terra::plot(dem, axes = FALSE, legend = FALSE)

terra::plot(dem, axes = FALSE, legend = FALSE, col = colorRampPalette(
  c(
    scales::muted("#74ACDF"), "white", "#F6B40E", "#F6B40E"
  ), bias = 1
)(1024)
)

colorRampPalette(
  c(
    scales::muted("#74ACDF"), "white", "#F6B40E", "#F6B40E", "#F6B40E"
  ), bias = 1
)(1024) |>
  scales::show_col(labels = FALSE, borders = FALSE)

dem_tbl <- as.data.frame(dem) |>
  as_tibble()

ggplot(dem_tbl, aes(focal_median)) +
  geom_histogram(binwidth = 10) +
  geom_vline(xintercept = -100, color = "red") +
  scale_y_log10() +
  theme_bw(base_size = 3) +
  theme(aspect.ratio = .4)

dem <- obj$dem
mat <- obj$matrix

dem[dem$focal_median < -100] <- -100

obj$dem <- dem
obj$matrix <- raster_to_matrix(dem)
