
# mensajes en consola
mensaje <- function(x) print(glue::glue("\n\n-- {x} --\n\n"))

# funciones ---------------------------------------------------------------

# cargo todas las librerías sin mensajes de advertencias
f_library <- function(x) {
  suppressWarnings(suppressMessages(library(x, character.only = TRUE)))
}

# obtengo la provincia de interés
# casos especiales para Tierra del Fuego e Islas Malvinas
f_provincia <- function(provincia) {

  tdf <- c("Ushuaia", "Tolhuin", "Río Grande")
  idas <- "Islas del Atlántico Sur"
  aa <- "Antártida Argentina"

  if (provincia == "Tierra del Fuego") {

    pcia <- departamentos[departamentos$departamentos %in% tdf, ] |>
      st_cast("MULTILINESTRING") |>
      st_cast("POLYGON") |>
      st_make_valid() |>
      st_geometry()

  } else if (provincia == "Islas Malvinas") {

    bb <- st_bbox(
      c(xmin = 4608412, xmax = 4865186, ymax = 4348687, ymin = 4179525),
      crs = st_crs(5346)) |>
      st_as_sfc() |>
      st_cast("POLYGON")

    pcia <- departamentos[departamentos$departamentos == idas, ] |>
      st_cast("MULTILINESTRING") |>
      st_cast("POLYGON") |>
      st_make_valid() |>
      st_geometry() |>
      st_crop(bb)

  } else if (provincia == "Islas del Atlántico Sur") {

    pcia <- departamentos[departamentos$departamentos == idas, ] |>
      st_cast("MULTILINESTRING") |>
      st_cast("POLYGON") |>
      st_make_valid() |>
      st_geometry()

  } else if (provincia == "Antártida Argentina") {

    pcia <- departamentos[departamentos$departamentos == aa, ] |>
      st_cast("MULTILINESTRING") |>
      st_cast("POLYGON") |>
      st_make_valid() |>
      st_geometry()

  } else {
    pcia <- departamentos[departamentos$provincia == provincia, ] |>
      st_cast("MULTILINESTRING") |>
      st_cast("POLYGON") |>
      st_make_valid()
  }

  return(pcia)
}

# modelo digital de elevación de la provincia de interés
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

# genero los objetos: matriz a partir de DEM, límites internos de los
# departamentos y relación de aspecto
f_rayshader <- function(provincia, zoom) {

  mensaje("Provincia")

  dem <- f_dem(provincia, zoom)

  mensaje("DEM")

  d5 <- terra::focal(dem, w = 5, fun = median, na.rm = TRUE)

  mensaje("Suavizo DEM")

  dem_matriz <- raster_to_matrix(d5)

  mensaje("Matriz")

  dem_bb <- ext(d5)

  asp <- (dem_bb[4] - dem_bb[3])/(dem_bb[2] - dem_bb[1])
  names(asp) <- NULL

  l <- list(
    dem = d5,
    matrix = dem_matriz,
    asp = asp
  )

  return(l)
}

# figura con redes sociales y nombre de usuario
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

# cargo escudo, bandera y autor de la provincia de interés
f_simbolos <- function(provincia) {

  tdf <- "Tierra del Fuego, Antártida e Islas del Atlántico Sur"

  if (provincia == "Tierra del Fuego" | provincia == "Islas Malvinas") {
    escudo <<- image_read(glue("escudos/{tdf}.png"))
    bandera <<- image_read(glue("banderas/{tdf}.png"))
    autor <<- image_read(glue("captions/{provincia}.png"))
  } else {
    escudo <<- image_read(glue("escudos/{provincia}.png"))
    bandera <<- image_read(glue("banderas/{provincia}.png"))
    autor <<- image_read(glue("captions/{provincia}.png"))
  }

  mensaje("Bandera, escudo y autor cargados")

}

f_nombre <- function(provincia, zoom) {

  archivos <- list.files(
    path = glue("figuras/{provincia}/"),
    pattern = glue("_{zoom}_"),
    full.names = TRUE)

  # si NUNCA se creó una imagen, se genera la 1ra
  if (length(archivos) == 0) {
    archivo_nuevo <- glue("figuras/{provincia}/viz_{zoom}_1.png")

    return(archivo_nuevo)
  }

  version <- archivos[str_detect(archivos, glue("_{zoom}"))] |>
    str_replace(glue("figuras/{provincia}/viz_(.+)_(.+).png"), "\\2") |>
    as.numeric() |>
    max() + 1

  archivo_nuevo <- glue("figuras/{provincia}/viz_{zoom}_{version}.png")

  return(archivo_nuevo)
}

f_actual <- function(provincia, zoom) {

  archivos <- list.files(glue("figuras/{provincia}/"), full.names = TRUE)

  version <- archivos[str_detect(archivos, glue("_{zoom}"))] |>
    str_replace(glue("figuras/{provincia}/viz_(.+)_(.+).png"), "\\2") |>
    as.numeric() |>
    max()

  archivo_nuevo <- glue("figuras/{provincia}/viz_{zoom}_{version}.png")

  return(archivo_nuevo)
}

f_imagen <- function(provincia) {
  image_read(f_actual(provincia, zoom)) |> 
    image_scale("2000x") |> 
    image_write(glue("figuras_sd/{provincia}.png"))

  mensaje("Imagen creada")
}

mensaje("Funciones cargadas")

# paquetes ----------------------------------------------------------------

# cargo los paquetes a partir de un vector
# sin advertencias en la consola
paq <- c(
  "terra", "rayshader", "sf", "glue", "showtext", "ggtext", "magick",
  "tidyverse")

purrr::map(paq, f_library)

mensaje("Paquetes cargados")

# fuentes -----------------------------------------------------------------

# leo las fuentes de texto de interés
font_add_google(name = "Ubuntu", family = "ubuntu")

# íconos
font_add("jet", "fuentes/JetBrainsMonoNLNerdFontMono-Regular.ttf")

showtext_auto()
showtext_opts(dpi = 300)

mensaje("Fuentes cargadas")

# datos -------------------------------------------------------------------

# leo el vector con provincias y departamentos
# departamentos <- st_read("vectores/dptos_pcias_continental.gpkg", quiet = TRUE)
departamentos <- st_read("vectores/dptos_pcias_bicontinental.gpkg", quiet = TRUE)

mensaje("Datos leídos")

# HDRI --------------------------------------------------------------------
# el .hdri que usé en todas: photo_studio_loft_hall_4k.hdr
# https://polyhaven.com/hdris/studio

hdri_file <- function(x = NULL) {

  if (is.null(x)) {
    hdri <- "hdri/photo_studio_loft_hall_4k.hdr"
  } else {
    hdri <- list.files("hdri/" , full.names = TRUE)[x]
  }

  return(hdri)

}

mensaje("HDRI cargado")
