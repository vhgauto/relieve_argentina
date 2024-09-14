
provincia <- "Ciudad Autónoma de Buenos Aires"
zoom <- 9

obj <- f_rayshader(provincia, zoom)

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        "#26185F", "#005D67", "#FCFFDD", "#F5191C"
      ), bias = 3
    )(1024)
  ) |>
  # mapa
  plot_3d(
    heightmap = obj$matrix,
    background = "white",
    windowsize = c(600, 600*obj$asp),
    zscale = 1,
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

# 1h 28m

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
  color2 = "#005D67", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego un contorno a la bandera
bandera <- bandera |>
  image_border("grey40", "50x50")

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Ciudad Autónoma\nde Buenos Aires",
    color = "#F5191C",
    location = "+200+50",
    size = 300,
    font = "Cambria",
    gravity = "northeast"
  ) |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x600"),
    gravity = "northwest",
    offset = "+200+200"
  ) |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "850x"),
    gravity = "southeast",
    offset = "+200+400"
  ) |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "southwest",
    offset = "+97+100"
  ) |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom)
  )

# reduzco tamaño
f_imagen(provincia)
