
# paquetes ----------------------------------------------------------------

library(elevatr)
library(terra)
library(rayshader)
library(sf)
library(glue)
library(tidyverse)

mensaje <- function(x) {

  glue("\n\n-- {x} --\n\n")

}

# datos -------------------------------------------------------------------

departamentos <- st_read("vectores/dptos_pcias_continental.gpkg")

# funciones ---------------------------------------------------------------

f_provincia <- function(provincia) {

  pcia <- departamentos[departamentos$provincia == provincia, ] |>
    st_cast("MULTILINESTRING") |>
    st_cast("POLYGON") |>
    st_union()

  return(pcia)
}

f_departamento <- function(provincia) {

  dptos <- departamentos[departamentos$provincia == provincia, ] |>
    st_cast("MULTILINESTRING")

  dptos_int <- st_difference(
    dptos, st_cast(f_provincia(provincia), "MULTILINESTRING")) |>
    st_geometry() |>
    st_union()

  return(dptos_int)
}

f_dem <- function(provincia, zoom = 5) {

  # archivo que contiene el dem
  dem_file <- glue("{getwd()}/dem/{provincia}_{zoom}.tif")

  # provincia, la región de interés
  pcia <- departamentos[departamentos$provincia == provincia, ] |>
    st_cast("MULTILINESTRING") |>
    st_cast("POLYGON") |>
    st_union()

  # si el dem SÍ está descargado, lo leo
  # si el dem NO está descargado, lo descargo
  if (file.exists(dem_file)) {
    dem <- rast(dem_file)
  } else {
    dem <- get_elev_raster(
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

dem <- f_dem(provincia = "Neuquén", zoom = 9)
dem_matriz <- raster_to_matrix(dem)

# extensión y relación de aspecto, para la imagen .png final
dem_bb <- ext(dem)
asp <- (dem_bb$ymax - dem_bb$ymin)/(dem_bb$xmax - dem_bb$xmin)

f_rayshader <- function(provincia, zoom) {

  pcia_sf <- f_provincia(provincia)

  dpto_sf <- f_departamento(provincia)

  dem <- f_dem(provincia, zoom)

  dem_matriz <- raster_to_matrix(dem)

  dem_bb <- ext(dem)

  asp <- (dem_bb[4] - dem_bb[3])/(dem_bb[2] - dem_bb[1])
  names(asp) <- NULL

  l <- list(
    # pcia = pcia_sf,
    dpto = dpto_sf,
    # dem = dem,
    matrix = dem_matriz,
    bb = dem_bb,
    asp = asp
  )

  return(l)
}


y <- f_rayshader("Chaco", 5)
plot(y$dpto)


# ventana para previsualizar
dem_matriz |>
  height_shade(
    texture = colorRampPalette(
      c(
        MetBrewer::met.brewer("Ingres")
      )
    )(128)
  ) |>
  # departamentos
  add_overlay(
    generate_line_overlay(
      geometry = y$dpto,
      extent = dem,
      heightmap = y$matrix,
      color = "white",
      linewidth = 5,
      lty = 1
    ),
    alphalayer = .9
  ) |>
  add_overlay(
    generate_line_overlay(
      geometry = y$dpto,
      extent = dem,
      heightmap = y$matrix,
      color = "black",
      linewidth = 5,
      lty = "66"
    ),
    alphalayer = .9
  )|>
  # mapa
  plot_3d(
    dem_matriz,
    background = "white",
    windowsize = c(600, 600*y$asp),
    zscale = 50,
    solid = FALSE,
    shadow = TRUE,
    shadow_darkness = 1
    # zoom = .5,
    # theta = 0,
    # phi = 70
  )

render_camera(
  theta = 0,
  phi = 70,
  zoom = .85
)


file_name <- "figuras/Neuquén_4.png"
hdri_file <- "hdri/photo_studio_loft_hall_4k.hdr"
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

browseURL(file_name)

rgl::close3d()
