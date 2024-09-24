
provincia <- "San Luis"
zoom <- 9

obj <- f_rayshader(provincia, zoom)

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        "#FDE333", "#F6B409", "#DA7900", "#633372", "#829EB5"
      ), bias = 4
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

# 1h 22m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#633372", # vhgauto
  color2 = "#829EB5", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# contorno en la bandera
bandera <- bandera |>
  image_border("grey60", "30x30")

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "San Luis",
    color = "#A86409",
    location = "+200+150",
    size = 600,
    font = "Cambria",
    gravity = "northwest"
  ) |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x700"),
    gravity = "northwest",
    offset = "+2700+170"
  ) |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "1330x"),
    gravity = "southwest",
    offset = "+200+200"
  ) |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2500x"),
    gravity = "southeast",
    offset = "+97+150"
  ) |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom)
  )

# reduzco tamaño
f_imagen(provincia)
