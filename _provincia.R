# función que crea los directorios y script para el procesamiento de
# la provincia elegida, a partir de una plantilla

nueva_provincia <- function(provincia) {

  # nombre de la carpeta a crear
  semana_carpeta <- glue::glue("scripts/{provincia}")

  # archivo .R
  new_file <- file.path(semana_carpeta, "script.R")

  # verifico que la carpeta de la provincia no exista
  if (file.exists(new_file)) {


    cat(crayon::red("\n\n\nProvincia existente\n\n\n"))

    system(glue::glue("open {new_file}"))

    stop()
  }

  # creo directorio del script
  dir.create(semana_carpeta, recursive = TRUE, showWarnings = FALSE)

  # creo directorio para las figuras
  dir.create(glue::glue("figuras/{provincia}/"), showWarnings = FALSE)

  glue::glue(
    crayon::blue(
      crayon::bold(
        "\n\nNueva carpeta creada\n\n")
    )
  )

  if (!file.exists(new_file)) {
    file.create(new_file)

    # copy lines to .R file
    r_txt <- readLines("_plantilla.R")

    r_txt <- gsub(
      pattern = "provincia_int",
      replacement = provincia,
      x = r_txt
    )

    # write to new file
    writeLines(r_txt, con = new_file)

    cat(
      crayon::blue(
        crayon::bold(
          glue::glue(
            "\n\n-- Script creado para: {provincia} --\n\n")
        )
      )
    )

  }

  system(glue::glue("open {new_file}"))


}

cat(
  crayon::bgRed(
    crayon::white(
      glue::glue(
        "\n\nUsar función {crayon::bold('nueva_provincia()')} ",
        "para iniciar el procesamiento.\n\n\n")
    )
  )
)
