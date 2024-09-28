
provincia <- "Islas Georgias del Sur"
zoom <- 7

# dem <- rast("dem/modelos_alos_30m_islas_georgias_sur.img") |>
#   project("EPSG:5346")
# dem2 <- terra::focal(dem, w = 5, fun = median, na.rm = TRUE)
# dem3 <- terra::aggregate(dem2, 2)
# writeRaster(dem3, "dem/Islas Georgias del Sur.tif", overwrite = TRUE)

dem <- rast("dem/Islas Georgias del Sur.tif")
mat <- raster_to_matrix(dem)

dem_bb <- ext(dem)

asp <- (dem_bb[4] - dem_bb[3])/(dem_bb[2] - dem_bb[1])
names(asp) <- NULL

# ventana para previsualizar
mat |>
  height_shade(
    texture = colorRampPalette(
      c(
        "#DBB3C0", "#BC7F91", "#3E7E78", "#C2CE9D"
      ), bias = 3
    )(1024)
  ) |>
  # mapa
  plot_3d(
    heightmap = mat,
    background = "white",
    windowsize = c(600, 600*asp),
    zscale = 5,
    solid = FALSE,
    shadow = TRUE,
    shadow_darkness = 1
  )

# cámara
render_camera(
  theta = 0,
  phi = 89,
  zoom = .7
)

file_name <- f_nombre(provincia, zoom)
file_ancho <- 5000
file_alto <- round(file_ancho*asp)

{
  t1 <- now()
  render_highquality(
    filename = file_name,
    preview = TRUE,
    light = FALSE,
    environment_light = hdri_file(),
    intensity_env = 1,
    interactive = FALSE,
    width = file_ancho,
    height = file_alto,
    samples = 256 # 50
  )
  t2 <- now()
  d <- t2 - t1
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
}

# 52m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#3E7E78", # vhgauto
  color2 = "#BC7F91", # RR.SS.
  provincia = "Tierra del Fuego, Antártida e Islas del Atlántico Sur"
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Islas Georgias del Sur",
    color = "#004C4C",
    location = "+200+50",
    size = 400,
    font = "Cambria",
    gravity = "northeast"
  ) |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x600"),
    gravity = "northeast",
    offset = "+220+600"
  ) |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "1000x"),
    gravity = "southwest",
    offset = "+200+200"
  ) |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "southeast",
    offset = "+97+150"
  ) |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom)
  )

# reduzco tamaño
f_imagen(provincia)
