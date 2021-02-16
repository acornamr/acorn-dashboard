i18n <- Translator$new(translation_csvs_path = './www/translations/')
i18n$set_translation_language('en')

# modification of usei18n function for standalone app
# provide path to a copy of shiny-i18n.js in the www folder
# https://github.com/Appsilon/shiny.i18n/blob/master/inst/www/shiny-i18n.js
custom_usei18n <- function (translator)
{
  # what's problematic with the standalone:
  # shiny::addResourcePath("shiny_i18n", system.file("www", package = "shiny.i18n"))
  # js_file <- file.path("shiny_i18n", "shiny-i18n.js")
  js_file <- file.path("shiny_i18n", "./www/translations/shiny-i18n.js")
  translator$use_js()
  translations <- translator$get_translations()
  key_translation <- translator$get_key_translation()
  translations[[key_translation]] <- rownames(translations)
  shiny::tagList(shiny::tags$head(shiny::tags$script(glue::glue("var i18n_translations = {toJSON(translations, auto_unbox = TRUE)}")),
                                  shiny::tags$script(src = js_file)), i18n_state(translator$key_translation))
}

environment(custom_usei18n) <- asNamespace('shiny.i18n')
assignInNamespace("usei18n", custom_usei18n, ns = "shiny.i18n")
