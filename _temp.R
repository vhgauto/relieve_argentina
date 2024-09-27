
dem <- obj$dem
mat <- obj$matrix

format(object.size(mat), units = "Mb")

terra::plot(
  dem, axes = FALSE, legend = FALSE,
  # maxcell = length(cells(dem)),
  col = colorRampPalette(
  c(
    # "#FDA841", "#D0929C", "#A9E2D9", "#FFE98C"
    # scico::scico(palette = "bamako", n = 50, direction = 1)
    # rev(RColorBrewer::brewer.pal(name = "YlGnBu", n = 9))[3:9]
    # "#AC5C05", "#D6BB3B", "#DE7A00", "#F9C22E", "#F2DD78"
    PrettyCols::prettycols("TealGreens")
    # as.character(PrettyCols::prettycols("TealGreens"))[c(4:1, 9:6)]
    # "#FCAADE", "#BE5151", "#FFB04F", "#F0E066"
  ), bias = 4
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
