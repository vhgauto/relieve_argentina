
provincia <- "Chubut"
zoom <- 8

obj <- f_rayshader(provincia, zoom)

linewidth1 <- 10
linewidth2 <- 4
x_lty <- 1

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        MetBrewer::met.brewer("Troy", 50)
      ), bias = 1
    )(128)
  ) |>
  # departamentos
  add_overlay(
    generate_line_overlay(
      geometry = obj$dpto,
      extent = obj$dem,
      heightmap = obj$matrix,
      color = "black",
      linewidth = linewidth1,
      lty = 1
    ),
    alphalayer = .9
  ) |>
  add_overlay(
    generate_line_overlay(
      geometry = obj$dpto,
      extent = obj$dem,
      heightmap = obj$matrix,
      color = "white",
      linewidth = linewidth2,
      lty = 1
    ),
    alphalayer = .9
  )|>
  # mapa
  plot_3d(
    heightmap = obj$matrix,
    background = "white",
    windowsize = c(600, 600*obj$asp),
    zscale = 10, # 5
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
    environment_light = hdri_file,
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

browseURL(file_name)

rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#772C1D", # vhgauto
  color2 = "#60B2D5", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = provincia,
    color = "#19639B",
    location = "+100+40",
    size = 300,
    font = "Cambria",
    gravity = "northwest") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x400"),
    gravity = "northwest",
    offset = "+1300+40") |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "700x"),
    gravity = "southeast",
    offset = "+200+350") |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2000x"),
    gravity = "southwest",
    offset = "+0+100") |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom))
