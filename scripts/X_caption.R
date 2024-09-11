
# paquetes ----------------------------------------------------------------

library(glue)
library(showtext)
library(ggtext)
library(tidyverse)



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
}

f_simbolos <- function(provincia) {

  escudo <<- image_read(glue("escudos/{provincia}.png"))
  bandera <<- image_read(glue("banderas/{provincia}.png"))
  autor <<- image_read(glue("captions/{provincia}.png"))

}








