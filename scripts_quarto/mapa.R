
# paquetes y colores
source("scripts_quarto/soporte_quarto.R")

# paletas de colores de cada región
source("scripts_quarto/_paletas.R")

# tema de la figura
theme_set(theme_void())

# función que genera los mapas de cada región
f_gg <- function(datos, expand = TRUE) {

  df <- inner_join(
    datos,
    label_color_tbl,
    by = join_by(region)
  ) |>
    mutate(
      ll = glue(
        "<span style='font-family: Bebas Neue; color: {c3}; font-size:50px'>",
        "{region}<br>{label_color}"
      )
    )

  ggplot() +
    geom_sf(
      data = df, fill = c4, color = c1, linewidth = .1
    ) +
    geom_sf_interactive(
      data = df,
      aes(
        data_id = region, onclick = glue("window.open(\"{link}\")"),
        tooltip = ll
      ),
      linewidth = .1, tooltip_fill = "transparent", color = c1, fill = c2,
      hover_nearest = FALSE
    ) +
    coord_sf(expand = expand, clip = "off")
}

# función que lee cada vector
f_vector <- function(vector, tolerancia = 0) {
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
    ) |>
    st_simplify(dTolerance = tolerancia)
}

# leo cada vector
# el vector de Argentina tengo que simplificarlo para que aparezca el
# mapa animado en quarto
arg_sf <- f_vector("arg_cont.gpkg", 100)
caba_sf <- f_vector("arg_caba.gpkg", 100)
ig_sf <- f_vector("arg_ig.gpkg", 100)
im_sf <- f_vector("arg_im.gpkg", 100)
is_sf <- f_vector("arg_is.gpkg")
aa_sf <- f_vector("arg_aa.gpkg")

# genero los mapas de cada región
g_arg <- f_gg(arg_sf, expand = FALSE)
g_caba <- f_gg(caba_sf)
g_im <- f_gg(im_sf)
g_ig <- f_gg(ig_sf)
g_is <- f_gg(is_sf)
g_aa <- f_gg(aa_sf)

# combino todas las regiones
reg <- tibble(
  region = c(
    arg_sf$region, caba_sf$region, ig_sf$region, im_sf$region, is_sf$region,
    aa_sf$region
  )
)

# texto de cada región
g_region <- ggplot() +
  geom_text_interactive(
    data = reg,
    aes(label = region, data_id = region, x = 0, y = 0),
    hjust = 0, vjust = 1, size = 8, alpha = 0
  ) +
  coord_cartesian(expand = FALSE, clip = "off", xlim = c(0, 1))

# acomodo todas las partes
diseño <- "
####
A###
ABDF
ACEF
"

# figura final
g <- g_arg + g_caba + g_im + g_ig + g_is + g_aa +
  plot_layout(
    design = diseño,
    widths = c(1, .5, .5, .5, 5),
    heights = c(1, 5, 5, 5, 5)
  )

# figura interactiva
g_int <- girafe(
  ggobj = g,
  bg = "transparent",
  options = list(
    opts_tooltip(
      css = "font-size: 50px; line-height: 70px;",
      use_fill = TRUE,
      offx = 400,
      offy = 20,
      opacity = 1,
      use_cursor_pos = FALSE
    ),
    opts_sizing(width = 1, rescale = TRUE),
    opts_toolbar(saveaspng = FALSE)
  )
)
