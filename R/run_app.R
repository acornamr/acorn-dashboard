#' Launch the ACORN dashboard
#' 
#' This function is used to generate the standalone version
#' @param options Named options that should be passed to the run_app call.
#' @return
#' Open browser
#' 
#' @export
#'
#' @import aws.s3 bslib ComplexUpset curl DBI DT flexdashboard glue highcharter lubridate markdown openssl readr readxl
#' REDCapR rmarkdown RSQLite rvest shiny shiny.i18n shinyjs shinyWidgets tictoc tidyverse writexl

run_app <- function(options = list()) {
  app_directory <- system.file("acorn", package = "acorn")
  shinyAppDir(app_directory, options = options)
}