
# paquetes ----------------------------------------------------------------

library(elevatr)
library(terra)
library(rayshader)
library(sf)
library(glue)
library(tidyverse)

# datos -------------------------------------------------------------------

# leo dptos de Argentina
dptos <- st_read("extras/dptos_pcias_continental.gpkg")
dptos_chaco <- dptos[dptos$provincia == "Chaco", ] |>
  st_cast("MULTILINESTRING")

# provincia del Chaco
pcia_chaco <- st_cast(dptos_chaco, "POLYGON") |>
  st_union()

# departamentos únicamente líneas internas
dptos_chaco_int <- st_difference(
  dptos_chaco, st_cast(pcia_chaco, "MULTILINESTRING")) |>
  st_geometry() |>
  st_union()

# extensión de la pcia
# bb_chaco <- st_transform(pcia_chaco, crs = 4326) |>
#   st_bbox() |>
#   as.numeric()

plot(st_geometry(pcia_chaco))
plot(st_geometry(dptos_chaco_int), add = TRUE, col = "darkblue")

# rayshader ---------------------------------------------------------------

# descargo relieve de la pcia
dem <- get_elev_raster(
  locations = st_as_sf(pcia_chaco),
  z = 9,
  clip = "locations"
) |>
  terra::rast() |>
  terra::project("EPSG:5346")

# convierto dem a matriz
dem_matriz <- raster_to_matrix(dem)

# extensión y relación de aspecto, para la imagen .png final
dem_bb <- ext(dem)
asp <- (dem_bb$ymax - dem_bb$ymin)/(dem_bb$xmax - dem_bb$xmin)

# ventana para previsualizar
dem_matriz |>
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
      geometry = dptos_chaco_int,
      extent = dem,
      heightmap = dem_matriz,
      color = "white",
      linewidth = 6,
      lty = 1
    ),
    alphalayer = .9
  ) |>
  add_overlay(
    generate_line_overlay(
      geometry = dptos_chaco_int,
      extent = dem,
      heightmap = dem_matriz,
      color = "black",
      linewidth = 6,
      lty = "11"
    ),
    alphalayer = .9
  ) |>
  # mapa
  plot_3d(
    dem_matriz,
    zscale = 5,
    solid = FALSE,
    shadow = TRUE,
    shadow_darkness = 1,
    background = "white",
    windowsize = c(600, 600*asp),
    zoom = .7,
    theta = 0,
    phi = 89
  )

file_name <- "osmdata/viz16.png"
hdri_file <- "osmdata/photo_studio_loft_hall_4k.hdr"

file_ancho <- 5000
file_alto <- round(file_ancho*asp)

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
    samples = 256
  )
  t2 <- now()
  d <- t2 - t1
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
  Sys.sleep(1)
  beepr::beep(sound = 2)
}

# 38 minutos

# cierro ventana con mapa
rgl::close3d()

# abro mapa
browseURL(file_name)

# edición de mapa ---------------------------------------------------------

library(magick)

# leo la imagen generada
img <- image_read(file_name)

# escudo y bandera
escudo <- image_read("osmdata/escudo.png")
bandera <- image_read("osmdata/bandera.png")

# leo autor
img_autor <- image_read("osmdata/caption.png")

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
    offset = "+200+300") |>
  # autor
  image_composite(
    composite_image = image_scale(img_autor, "1500x"),
    gravity = "south",
    offset = "+0+100") |>
  # guardo
  image_write(
    path = "osmdata/viz16_1.png"); browseURL("osmdata/viz16_1.png")

magick_fonts() |>
  tidyr::as_tibble() |>
  # select(glyphs) |>
  print(n = 200)











