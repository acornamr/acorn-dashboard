message("Start ACORN shiny app.")

app_version <- "prototype.001"  # IMPORTANT ensure that the version is identical in DESCRIPTION and README.md

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I, R
# cols_sir <- c("#2166ac", "#fddbc7", "#b2182b")  # resp. S, I, R
hc_export_kind <- c("downloadJPEG", "downloadCSV")

# IMPORTANT: packages listed here should be synced with run_app.R and DESCRIPTION
library(aws.s3)
library(bslib)  # bs_theme()
library(curl)
library(DBI)  # to read lab data
library(DT)
library(flexdashboard)  # gaugeOutput()
library(glue)
library(highcharter)
library(lubridate)
library(openssl)
library(readr)  # to read lab data
library(readxl)  # to read lab data
library(REDCapR)  # to read clinical data
library(RSQLite)  # to read lab data
library(rmarkdown)  # pandoc_available()
library(shiny)
library(shinyanimate)
library(shiny.i18n)  # i18n$t()
library(shinyjs)
library(shinyWidgets)  # chooseSliderSkin()
library(tidyverse)
library(writexl)

session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")
session_id <- glue("{glue_collapse(sample(LETTERS, 5, TRUE))}_{session_start_time}")

# it's safe to expose those since the shared_acornamr bucket content can only be listed + read with these credentials
shared_acornamr_key <- readRDS("./www/cred/bucket_cred/shared_acornamr_key.rds")
shared_acornamr_sec <- readRDS("./www/cred/bucket_cred/shared_acornamr_sec.rds")

# contains all require i18n elements
i18n <- Translator$new(translation_csvs_path = './www/translations/')
i18n$set_translation_language('en')

for(file in list.files('./www/R/functions/'))  source(paste0('./www/R/functions/', file), local = TRUE)  # define all functions

acorn_theme <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px")
acorn_theme_la <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px", base_font = "Phetsarath OT")

h4_title <- function(...)  div(class = "h4_title", ...)

tab <- function(...) {
  shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
}