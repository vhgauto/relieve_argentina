
provincia <- "Islas Malvinas"
zoom <- 10

obj <- f_rayshader(provincia, zoom)

# corrijo valores MUY bajos
# dem[dem$focal_median < -100] <- -100
# obj$dem <- dem
# obj$matrix <- raster_to_matrix(dem)
# writeRaster(dem, "dem/Islas Malvinas_10.tif", overwrite = TRUE)

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        scales::muted("#74ACDF"), "white", "#F6B40E", "#F6B40E"
      ), bias = 1
    )(1024)
  ) |>
  # mapa
  plot_3d(
    heightmap = obj$matrix,
    background = "white",
    windowsize = c(600, 600*obj$asp),
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
file_alto <- round(file_ancho*obj$asp)

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
    samples = 256 # 256
  )
  t2 <- now()
  d <- t2 - t1
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
}

# 32m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#004F90", # vhgauto
  color2 = "#74ACDF", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Islas Malvinas",
    color = "#007E2E",
    location = "+56-30",
    size = 450,
    font = "Cambria",
    gravity = "northwest") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x500"),
    gravity = "northwest",
    offset = "+3130+40") |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "800x"),
    gravity = "southeast",
    offset = "+200+200") |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "southwest",
    offset = "+20+40") |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom))
