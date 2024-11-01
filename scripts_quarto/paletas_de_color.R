
# █
# ■

cuadrado <- "█"

# función para extraer las paletas de colores de cada script
f_pal <- function(x) {
  script_tbl <- tibble(l = x) |>
    mutate(pal = str_detect(l, "texture = colorRampPalette")) |>
    mutate(id = row_number())

  pal_id <- filter(script_tbl, pal) |>
    pull(id)

  pal_eval <- script_tbl |>
    filter(id == pal_id + 2) |>
    pull(l) |>
    str_trim()

  return(pal_eval)
}

# leo todos los scripts
scripts <- list.files(
  path = "scripts/",
  recursive = TRUE,
  pattern = "script.R",
  full.names = TRUE
)

scripts_lineas <- map(scripts, readLines)

# extraigo las paletas de colores y asocio a las regiones
lista_pal <- map(scripts_lineas, f_pal)
pcias <- dirname(scripts) |>
  str_remove("scripts/")
names(lista_pal) <- pcias

# acomodo las paletas y genero la grilla de colores (cuadrado)
label_color_tbl <- enframe(lista_pal, name = "region", value = "pal") |>
  unnest(pal) |>
  mutate(funcion_chr = glue("colorRampPalette(c({pal}))(10)")) |>
  mutate(colores = map(funcion_chr, ~ eval(parse(text = .x)))) |>
  select(region, colores) |>
  unnest(cols = colores) |>
  mutate(
    label = glue(
      "<span style='color: {colores}; font-size:70px;'>",
      "{cuadrado}</span>"
    )
  ) |>
  reframe(label_color = str_flatten(label), .by = region)
