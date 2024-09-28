
provincia <- "Islas Sandwich del Sur"
zoom <- 9

# dem <- elevatr::get_elev_raster(
#   locations = st_as_sf(is_sf),
#   z = 9,
#   clip = "locations"
# ) |>
#   terra::rast() |>
#   terra::project("EPSG:5346")
# dem2 <- terra::focal(dem, w = 5, fun = median, na.rm = TRUE)
# dem2_min <- abs(global(dem2, "min", na.rm = TRUE)$min)
# dem3 <- dem2 + dem2_min
# writeRaster(dem3, "dem/Islas Sandwich del Sur.tif", overwrite = TRUE)

dem <- rast("dem/Islas Sandwich del Sur.tif")
mat <- raster_to_matrix(dem)

dem_bb <- ext(dem)

asp <- (dem_bb[4] - dem_bb[3])/(dem_bb[2] - dem_bb[1])
names(asp) <- NULL

# ventana para previsualizar
mat |>
  height_shade(
    texture = colorRampPalette(
      c(
        viridis::rocket(20)
      ), bias = .5
    )(1024)
  ) |>
  # mapa
  plot_3d(
    heightmap = mat,
    background = "white",
    windowsize = c(600, 600*asp),
    zscale = 20,
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

# 1h 6m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#661F54", # vhgauto
  color2 = "#E33541", # RR.SS.
  provincia = "Islas Sandwich del Sur"
)

# escudo, bandera y caption
f_simbolos("Tierra del Fuego, Antártida e Islas del Atlántico Sur")
autor <- image_read("captions/Islas Sandwich del Sur.png")

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Islas Sandwich\ndel Sur",
    color = "#3941AF",
    location = "+200+150",
    size = 500,
    font = "Cambria",
    gravity = "northwest"
  ) |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x800"),
    gravity = "northwest",
    offset = "+200+1460"
  ) |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "1300x"),
    gravity = "southeast",
    offset = "+200+400"
  ) |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2500x"),
    gravity = "southwest",
    offset = "+97+150"
  ) |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom)
  )

# reduzco tamaño
f_imagen(provincia)
