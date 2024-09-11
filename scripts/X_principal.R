
provincia <- "Chaco"
zoom <- 9

y <- f_rayshader(provincia, zoom)

x_linewidth <- 6
x_lty <- 1

# m <- y$matrix
# m[!is.na(m)] <- 100

# ventana para previsualizar
y$matrix |>
  height_shade(
    texture = colorRampPalette(
      c(
        hcl.colors(10, palette = "Batlow")
      )
    )(128)
  ) |>
  # departamentos
  add_overlay(
    generate_line_overlay(
      geometry = y$dpto,
      extent = y$dem,
      heightmap = y$matrix,
      color = "black",
      linewidth = 10,
      lty = 1
    ),
    alphalayer = .9
  ) |>
  add_overlay(
    generate_line_overlay(
      geometry = y$dpto,
      extent = y$dem,
      heightmap = y$matrix,
      color = "white",
      linewidth = 4,
      lty = 1
    ),
    alphalayer = .9
  )|>
  # mapa
  plot_3d(
    heightmap = y$matrix,
    background = "white",
    windowsize = c(600, 600*y$asp),
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

file_name <- glue("figuras/{provincia}_{zoom}_6.png")
hdri_file <- "hdri/photo_studio_loft_hall_4k.hdr"
file_ancho <- 5000
file_alto <- round(file_ancho*y$asp)

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

f_caption(
  color1 = "#1C783E", # vhgauto
  color2 = "#AB8A1A", # RR.SS.
  provincia = provincia
)

# leo la imagen generada
img <- image_read(file_name)

# escudo, bandera y caption

f_simbolos(provincia)

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Provincia\ndel Chaco",
    color = "#1DB062",
    location = "+200+150",
    size = 250,
    font = "Cambria",
    gravity = "northeast") |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x466"),
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
    offset = "+0+100") |>
  # guardo
  image_write(
    path = "figuras/Chaco_9_6.png"); browseURL("figuras/Chaco_9_6.png")
