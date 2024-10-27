
source("_soporte.R")

# vector de la Antártida
# ant <- vect("vectores/dptos_antartida.gpkg")

# DEM
# dem <- elevatr::get_elev_raster(
#   locations = sf::st_as_sf(ant),
#   z = 5,
#   clip = "locations"
# ) |>
#   rast()

# dem2 <- terra::focal(dem, w = 5, fun = median, na.rm = TRUE)

# names(dem) <- "focal_median"

# writeRaster(dem2, "dem/Antártida Argentina_5.tif", overwrite = TRUE)
dem <- rast("dem/Antártida Argentina_5.tif")

# matriz y relación de aspecto
mat <- raster_to_matrix(dem)

e <- ext(dem)
asp <- (e$ymax - e$ymin)/(e$xmax - e$xmin)

# ventana para previsualizar
mat |>
  height_shade(
    texture = colorRampPalette(
      c(
        tidyterra::hypso.colors(palette = "colombia", n = 1024)
      ), bias = 1
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
  zoom = .6
)

provincia <- "Antártida"
zoom <- 5

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

# 2h 13m

# abro figura
browseURL(file_name)

# cierro ventana interactiva
rgl::close3d()

# anotaciones -------------------------------------------------------------

# leo la imagen generada
img <- image_read(f_actual(provincia, zoom))

# genero caption
f_caption(
  color1 = "#80146E", # vhgauto
  color2 = "#006E37", # RR.SS.
  provincia = "Antártida Argentina"
)

# escudo, bandera y caption
f_simbolos("Tierra del Fuego")

# caption
autor <- image_read("captions/Antártida Argentina.png")

# agrego título y autor
img |>
  # título
  image_annotate(
    text = "Antártida Argentina",
    color = "#009B9F",
    location = "+200+150",
    size = 470,
    font = "Cambria",
    gravity = "northeast"
  ) |>
  # escudo
  image_composite(
    composite_image = image_scale(escudo, "x1100"),
    gravity = "northeast",
    offset = "+213+800"
  ) |>
  # bandera
  image_composite(
    composite_image = image_scale(bandera, "1500x"),
    gravity = "southwest",
    offset = "+200+200"
  ) |>
  # autor
  image_composite(
    composite_image = image_scale(autor, "2500x"),
    gravity = "southeast",
    offset = "+200+160"
  ) |>
  # guardo
  image_write(
    path = f_nombre(provincia, zoom)
  )

# reduzco tamaño
f_imagen(provincia)
