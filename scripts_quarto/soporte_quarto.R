
# paquetes
library(sf)
library(ggiraph)
library(glue)
library(ggtext)
library(patchwork)
library(tidyverse)

# colores
c1 <- "#222222"
c2 <- "#75AEE0"
c3 <- "#F6B606"
c4 <- "white"
c5 <- "#666666"

# punto de separador
separador <- glue("<span style='color: {c3};'>·</span>")

# espacios para las RRSS
espacios <- "&nbsp;&nbsp;&nbsp;&nbsp;"

# arcoiris al final del sitio web

# cantidad de colores y cuadrado
n_col <- 200
cuadrado <- "■" #"█"

arcoiris <- glue(
  "<span style='color: {rainbow(n_col)}; font-size: 10px'>{cuadrado}</span>"
) |>
  str_flatten()
