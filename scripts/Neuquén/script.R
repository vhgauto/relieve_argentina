
provincia <- "Neuquén"
zoom <- 9

obj <- f_rayshader(provincia, zoom)

linewidth1 <- 10
linewidth2 <- 4
x_lty <- 1

# ventana para previsualizar
obj$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        MetBrewer::met.brewer("Ingres")
      ), bias = 2
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
    zscale = 5,
    solid = FALSE,
    shadow = TRUE,
    shadow_darkness = 1
  )

# cámara
render_camera(
  theta = 0,
  phi = 89,
  zoom = .5
)

file_name <- f_nombre(provincia, zoom)
file_ancho <- 5000
file_alto <- round(file_ancho*obj$asp)

# 5h 12m

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
img <- image_read(file_name)

f_caption(
  color1 = "#472C0B", # vhgauto
  color2 = "#18527E", # RR.SS.
  provincia = provincia
)

# escudo, bandera y caption
f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = provincia,
    color = "#DE2118",
    location = "+200+150",
    size = 450,
    font = "Cambria",
    gravity = "northeast") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x600"),
    gravity = "northeast",
    offset = "+2200+120") |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "1200x"),
    gravity = "southeast",
    offset = "+200+500") |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2700x"),
    gravity = "southwest",
    offset = "+50+100") |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom))
