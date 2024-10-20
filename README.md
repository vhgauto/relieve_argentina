# Mapas de elevación de Argentina

Descripción de los datos y la metodología para la confección de mapas de relieve de las provincias argentinas.

## Provincias de Argentina

Los polígonos fueron obtenidos a partir del vector de provincias del [Instituto Geográfico Nacional](https://www.ign.gob.ar/NuestrasActividades/InformacionGeoespacial/CapasSIG).

En el caso de la provincia Tierra del Fuego, Sector Antártico e Islas del Atlántico Sur, los dividí en sub regiones: Islas Malvinas, Islas Georgias del Sur y Sector Antártico.

## Modelo digital de elevación

Los datos de relieve de las provincias se obtuvieron a partir del paquete [`{elevatr}`](https://github.com/USEPA/elevatr), indicando en cada caso el nivel de zoom deseado.

Para la Ciudad Autónoma de Buenos Aires, obtuve los datos de elevación del [Instituto Geográfico Nacional](https://www.ign.gob.ar/NuestrasActividades/Geodesia/ModeloDigitalElevaciones/Mapa), a 5m, uniendo todas las porciones.

Para remover valores de altura excesivamente altos o bajos, apliqué un suavizado sobre el ráster completo, a partir de una ventana móvil de 5x5 píxeles, calculando la mediana.

En algunos casos, el ráster presentaba gran cantidad de valores negativos. Decidí remover directamente estos píxeles, remplazándolos con un valor constante. Para elegir este valor límite, analicé la distribución de alturas con un histograma.

## Paletas de colores

Cada provincia presenta una paleta de colores diferente. La gran mayoría proviene de alguno de estos paquetes:

* [`{colorspace}`](https://cran.r-project.org/web/packages/colorspace/vignettes/colorspace.html)
* [`{hcl}`](https://colorspace.r-forge.r-project.org/articles/hcl_palettes.html)
* [`{MetBrewer}`](https://www.blakerobertmills.com/my-work/met-brewer)
* [`{MoMAColors}`](https://www.blakerobertmills.com/my-work/momacolors)
* [`{nord}`](https://cran.r-project.org/web/packages/nord/readme/README.html)
* [`{PrettyCols}`](https://nrennie.rbind.io/PrettyCols/)
* [`{RColorBrewer}`](https://www.datanovia.com/en/blog/the-a-z-of-rcolorbrewer-palette/)
* [`{scico}`](https://github.com/thomasp85/scico)
* [`{viridis}`](https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html)

Algunas paletas de colores son combinaciones de colores individuales o paletas existentes con colores extras.

## Banderas y escudos

Las banderas junto con los escudos fueron descargados de los correspondientes artículos de [Wikipedia](https://es.wikipedia.org/wiki/Anexo:Provincias_de_Argentina).

## Rayshader

El paquete [`{rayshader}`](https://www.rayshader.com/) permite crear visualizaciones increíbles a partir de datos de elevación, generando mapas en 3D con iluminación y sombras.

La generación del mapa final, todos con 5000 píxeles de ancho, requirió mucho tiempo de procesamiento. El mapa de Neuquén, uno de los que más tiempo llevó, secesitó más de 3h 30m.

Para generar el mapa, `{rayshader}` requiere generar una matriz a partir del ráster de elevación. Siempre tuve el resguardo de que la matriz generada ocupe menos de 200Mb en la memoria de la sesión, para evitar cierres inesperados.

## Anotaciones

Una vez generado el mapa 3D con el relieve de la provincia, con la paleta de colores elegida, era necesario incorporar al archivo `.png` el escudo, la bandera, el nombre de la provincia y mis datos como autor.

Para todo esto utilicé el paquete [`{magick}`](https://cran.r-project.org/web/packages/magick/vignettes/intro.html), que permite la lectura del mapa generado y la posibilidad de incorporar texto, rescalar imágenes e insertar otras imágenes.

## Ejecución

Para facilitar la generación de los mapas de cada región, agregué scripts auxiliares: `_soporte.R` contiene todas las funciones que facilitar la descarga, lectura y selección de parámetros; `_provincia.R` se encarga de generar todos los directorios de acuerdo a la región elegida; y `_plantilla.R` es usada como base para los scripts de cada región.

## Material de ayuda

Este proyecto fue posible por incontables tutoriales. En particular recomiendo los canales de YouTube de [Spencer Schien](https://www.youtube.com/@MrPecners/featured) y [Milos Makes Maps](https://www.youtube.com/@milos-makes-maps/featured).

La plantilla para generar los scripts por cada región fue creado a partir de [esta guía de Nicola Rennie](https://nrennie.rbind.io/blog/script-templates-r/).

## Contacto

Sitio web desarrollado y mantenido por [<b>Víctor Gauto</b>](mailto:victor.gauto@putlook.com).

<p align="center">

[![](https://skillicons.dev/icons?i=instagram)](https://www.instagram.com/vhgauto/) [![](https://skillicons.dev/icons?i=twitter)](https://x.com/vhgauto) [![](https://skillicons.dev/icons?i=mastodon)](https://fosstodon.org/@vhgauto)

</p>