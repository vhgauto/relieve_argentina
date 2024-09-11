
# mensajes en consola
mensaje <- function(x) print(glue::glue("\n\n-- {x} --\n\n"))

# paquetes ----------------------------------------------------------------

# library(terra)
# library(rayshader)
# library(sf)
# library(glue)
# library(showtext)
# library(ggtext)
# library(magick)
# library(tidyverse)


f_library <- function(x) {
  suppressWarnings(suppressMessages(library(x, character.only = TRUE)))
}

paq <- c(
  "terra", "rayshader", "sf", "glue", "showtext", "ggtext", "magick",
  "tidyverse")

purrr::map(paq, f_library)

mensaje("Paquetes cargados")

# fuentes -----------------------------------------------------------------

font_add_google(name = "Ubuntu", family = "ubuntu")

# íconos
font_add("jet", "fuentes/JetBrainsMonoNLNerdFontMono-Regular.ttf")

showtext_auto()
showtext_opts(dpi = 300)

mensaje("Fuentes cargadas")

# datos -------------------------------------------------------------------

departamentos <- st_read("vectores/dptos_pcias_continental.gpkg", quiet = TRUE)

mensaje("Datos leídos")

# funciones ---------------------------------------------------------------

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

# caption -----------------------------------------------------------------

f_caption <- function(color1, color2, provincia, ancho = 2000) {

  autor <- glue("<span style='color:{color1};'>**Víctor Gauto**</span>")
  icon_twitter <- glue("<span style='font-family:jet;'>&#xf099;</span>")
  icon_instagram <- glue("<span style='font-family:jet;'>&#xf16d;</span>")
  icon_github <- glue("<span style='font-family:jet;'>&#xf09b;</span>")
  icon_mastodon <- glue("<span style='font-family:jet;'>&#xf0ad1;</span>")
  usuario <- glue("<span style='color:{color1};'>**vhgauto**</span>")
  sep <- glue("**|**")

  mi_caption <- glue(
    "{autor} {sep} {icon_github} {icon_twitter} {icon_instagram} ",
    "{icon_mastodon} {usuario}"
  )

  asp <- 66/897

  g <- ggplot() +
    annotate(
      geom = "richtext", x = 0, y = 0, label = mi_caption, fill = NA,
      label.color = NA, size = 10, family = "ubuntu", color = color2) +
    coord_cartesian(clip = "off") +
    theme_void() +
    theme(
      aspect.ratio = asp)

  # guardo
  ggsave(
    plot = g,
    filename = glue("captions/{provincia}.png"),
    width = ancho,
    height = round(ancho*asp),
    units = "px")

  mensaje("Caption guardado")
}

f_simbolos <- function(provincia) {

  escudo <<- image_read(glue("escudos/{provincia}.png"))
  bandera <<- image_read(glue("banderas/{provincia}.png"))
  autor <<- image_read(glue("captions/{provincia}.png"))

  mensaje("Bandera, escudo y autor cargados")

}

mensaje("Funciones cargadas")
