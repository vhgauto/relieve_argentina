
# paquetes y colores
source("scripts_quarto/soporte_quarto.R")

# tema de la figura
theme_set(theme_void())

# función que genera los mapas de cada región
f_gg <- function(datos, expand = TRUE) {
  ggplot() +
    geom_sf(
      data = datos, fill = c4, color = c1, linewidth = .1
    ) +
    geom_sf_interactive(
      data = datos,
      aes(data_id = region, onclick = glue("window.open(\"{link}\")")),
      linewidth = .1,
      color = c1, fill = c2, hover_nearest = TRUE
    ) +
    coord_sf(expand = expand, clip = "off")
}

# función que lee cada vector
f_vector <- function(vector) {
  st_read(glue("vectores/{vector}"), quiet = TRUE) |>
    mutate(
      region2 = str_replace_all(region, " ", "_")
    ) |> 
    mutate(
      region2 = glue("{region2}_viz")
    ) |> 
    mutate(
      link = glue(
        "https://raw.githubusercontent.com/vhgauto/arg_rayshader/refs/heads/",
        "main/figuras/{region}/{region2}.png"
      )
    )
}

# arg -> Argentina continental, Islas Malvinas
# caba -> Ciudad Autónoma de Buenos Aires
# ig -> Islas Georgias del Sur
# im -> Islas Malvinas
# is -> Islas Sandwich del Sur

# leo cada vector
# el vector de Argentina tengo que simplificarlo para que aparezca el
# mapa animado en quarto
arg_sf <- f_vector("arg_cont.gpkg") |>
  st_simplify(dTolerance = 1000)
caba_sf <- f_vector("arg_caba.gpkg")
ig_sf <- f_vector("arg_ig.gpkg")
im_sf <- f_vector("arg_im.gpkg")
is_sf <- f_vector("arg_is.gpkg")

# genero los mapas de cada región
g_arg <- f_gg(arg_sf, expand = FALSE)
g_caba <- f_gg(caba_sf)
g_im <- f_gg(im_sf)
g_ig <- f_gg(ig_sf)
g_is <- f_gg(is_sf)

# combino todas las regiones
reg <- tibble(
  region = c(
    arg_sf$region, caba_sf$region, ig_sf$region, im_sf$region, is_sf$region)
)

# texto de cada región
g_region <- ggplot() +
  geom_text_interactive(
    data = reg,
    aes(label = region, data_id = region, x = 0, y = 0),
    hjust = 0, vjust = 1, size = 7, alpha = 0
  ) +
  coord_cartesian(expand = FALSE, clip = "off", xlim = c(0, 1))

# acomodo todas las partes
diseño <- "
###
ABB
A##
ACD
AEF
"

# figura final
g <- g_arg + g_region + g_caba + g_im + g_ig + g_is +
  plot_layout(
    design = diseño,
    widths = c(1, .5, .5),
    heights = c(1, 5, 5, 5, 5)
  )

# figura interactiva
g_int <- girafe(
  ggobj = g,
  bg = "transparent",
  options = list(
    opts_hover(
      css = girafe_css(
        css = glue("fill:{c3}"),
        text = glue(
          "stroke:none;fill:{c3};fill-opacity:1;font-family:Bebas Neue"
        )
      )
    ),
    opts_sizing(width = 1, rescale = TRUE),
    opts_toolbar(saveaspng = FALSE)
  )
)
