
# paquetes ----------------------------------------------------------------

library(terra)
library(rayshader)
library(sf)
library(glue)
library(showtext)
library(ggtext)
library(tidyverse)

# datos -------------------------------------------------------------------

departamentos <- st_read("vectores/dptos_pcias_continental.gpkg")

# funciones ---------------------------------------------------------------

# mensajes en consola
mensaje <- function(x) print(glue::glue("\n\n-- {x} --\n\n"))

# obtengo la provincia
f_provincia <- function(provincia) {

  pcia <- departamentos[departamentos$provincia == provincia, ] |>
    st_cast("MULTILINESTRING") |>
    st_cast("POLYGON")

  return(pcia)
}

# obtengo los límites internos de los departamentos
f_departamento <- function(provincia) {

  dptos <- departamentos[departamentos$provincia == provincia, ] |>
    st_cast("MULTILINESTRING")

  dptos_int <- st_difference(
    dptos, st_cast(st_union(f_provincia(provincia)), "MULTILINESTRING")) |>
    st_geometry()

  return(dptos_int)
}

# modelo digital de elevación de la provincia
f_dem <- function(provincia, zoom = 5) {

  # archivo que contiene el dem
  dem_file <- glue("{getwd()}/dem/{provincia}_{zoom}.tif")

  # provincia, la región de interés
  pcia <- f_provincia(provincia)

  # si el dem SÍ está descargado, lo leo
  # si el dem NO está descargado, lo descargo
  if (file.exists(dem_file)) {
    dem <- rast(dem_file)
  } else {
    dem <- elevatr::get_elev_raster(
      locations = st_as_sf(pcia),
      z = zoom,
      clip = "locations"
    ) |>
      terra::rast() |>
      terra::project("EPSG:5346")
  }

  # si el dem NO existe, lo guardo
  if (!file.exists(dem_file)) {
    writeRaster(dem, glue("dem/{provincia}_{zoom}.tif"))
  }

  return(dem)
}

# genero los objetos
f_rayshader <- function(provincia, zoom) {

  # pcia_sf <- f_provincia(provincia)

  # mensaje("Provincia")

  dpto_sf <- f_departamento(provincia)

  mensaje("Departamento")

  dem <- f_dem(provincia, zoom)

  mensaje("DEM")

  dem_matriz <- raster_to_matrix(dem)

  mensaje("Matriz")

  dem_bb <- ext(dem)

  asp <- (dem_bb[4] - dem_bb[3])/(dem_bb[2] - dem_bb[1])
  names(asp) <- NULL

  l <- list(
    dpto = dpto_sf,
    dem = dem,
    matrix = dem_matriz,
    bb = dem_bb,
    asp = asp
  )

  return(l)
}

x_provincia <- "Chaco"
x_zoom <- 9

y <- f_rayshader(x_provincia, x_zoom)

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

file_name <- glue("figuras/{x_provincia}_{x_zoom}_4.png")
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


# caption -----------------------------------------------------------------

f_caption(
  color1 = "#1C783E", # vhgauto
  color2 = "#AB8A1A", # RR.SS.
  provincia = "Chaco"
); browseURL("captions/Chaco.png")

# imagen ------------------------------------------------------------------

library(magick)

# leo la imagen generada
img <- image_read(file_name)

# escudo, bandera y caption

f_simbolos("Chaco")

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
