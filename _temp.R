
dem <- obj$dem
mat <- obj$matrix

format(object.size(mat), units = "Mb")

dem2 <- dem + abs(dem_min)

terra::plot(
  dem2, axes = FALSE, legend = FALSE,
  # maxcell = length(cells(dem)),
  col = colorRampPalette(
  c(
    # MetBrewer::met.brewer(name = "Cassatt1", n = 20)
    # tidyterra::wiki.colors(10)
    tidyterra::hypso.colors(palette = "colombia", n = 100)
  ), bias = 1
)(1024)
)

terra::plot(dem, axes = FALSE, legend = FALSE)

dem2 <- terra::aggregate(dem, 2)

terra::plot(dem2, axes = FALSE, legend = FALSE, col = colorRampPalette(
  c(
    viridis::turbo(10)
  ), bias = 1
)(1024)
)

m <- raster_to_matrix(dem2)

terra::plot(dem, axes = FALSE, legend = FALSE)

dem_tbl <- as.data.frame(dem) |>
  as_tibble()

ggplot(dem_tbl, aes(focal_median)) +
  geom_histogram(binwidth = 10) +
  geom_vline(xintercept = -10, color = "red") +
  scale_y_log10() +
  theme_bw(base_size = 3) +
  theme(aspect.ratio = .4)

dem_min <- global(dem, "min", na.rm = TRUE)$min

dem_tbl |>
  mutate(focal_median = focal_median + abs(dem_min)) |>
  ggplot(aes(focal_median)) +
  geom_histogram(binwidth = 10) +
  geom_vline(xintercept = -10, color = "red") +
  scale_y_log10() +
  theme_bw(base_size = 3) +
  theme(aspect.ratio = .4)
