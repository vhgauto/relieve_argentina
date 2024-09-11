
provincia <- "Islas del Atlántico Sur"
zoom <- 9

obj <- f_rayshader(provincia, zoom)

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        "PALETA DE COLORES"
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
file_ancho <- 2000
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
    samples = 50 # 256
  )
  t2 <- now()
  d <- t2 - t1
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
}

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#000000", # vhgauto
  color2 = "#000000", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Islas del Atlántico Sur",
    color = "#000000",
    location = "+200+150",
    size = 450,
    font = "Cambria",
    gravity = "northeast") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x600"),
    gravity = "northeast",
    offset = "+1350+220") |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "600x"),
    gravity = "southwest",
    offset = "+200+200") |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "south",
    offset = "+97+150") |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom))
