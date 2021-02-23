#' Launch the ACORN dashboard
#' 
#' This function is used to generate the standalone version
#' @param options Named options that should be passed to the run_app call.
#' @return
#' Open browser
#' 
#' @export
#'
#' @import aws.s3 bslib curl DT glue highcharter lubridate openssl REDCapR rmarkdown shiny shinyanimate shiny.i18n shinyjs shinyWidgets tidyverse
#' 

run_app <- function(options = list()) {
  app_directory <- system.file("acorn", package = "acorn")
  shinyAppDir(app_directory, options = options)
}