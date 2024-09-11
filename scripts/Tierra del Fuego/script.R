
provincia <- "Tierra del Fuego"
zoom <- 9

obj <- f_rayshader(provincia, zoom)

# corrijo valores MUY bajos
# dem[dem$focal_median < -70] <- -70
# obj$dem <- dem
# obj$matrix <- raster_to_matrix(dem)
# writeRaster(dem, "dem/Tierra del Fuego_9.tif", overwrite = TRUE)

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        "#FFCD11", "#FFCD11", "#0B7156", "#8D1C06", "#C9C9DD"
      ), bias = 2.3
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

# 50m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#1983DD", # vhgauto
  color2 = "#1F1A17", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Tierra del Fuego",
    color = "#FD9730",
    location = "+200+150",
    size = 450,
    font = "Cambria",
    gravity = "northeast") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x500"),
    gravity = "northeast",
    offset = "+220+800") |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "600x"),
    gravity = "southeast",
    offset = "+100+100") |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "southwest",
    offset = "-20+60") |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom))
