app_version <- "2.0.5"  # Make sure that the app version is identical in DESCRIPTION and build_standalone_Windows.R

# IMPORTANT: packages listed here should be identical in run_app.R and DESCRIPTION
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

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I, R
hc_export_kind <- c("downloadJPEG", "downloadCSV")

code_sites <- c("demo",
                read_delim(file = "./www/data/ACORN2_site_codes.csv", delim = ";", show_col_types = FALSE) %>% pull(`ACORN2 site code`))

session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")

# safe to expose since the shared_acornamr bucket can only be listed/read
shared_acornamr_key <- readRDS("./www/cred/bucket_cred/shared_acornamr_key.rds")
shared_acornamr_sec <- readRDS("./www/cred/bucket_cred/shared_acornamr_sec.rds")

# contains all require i18n elements
i18n <- Translator$new(translation_json_path = "./www/translations/translation.json")
i18n$set_translation_language("en")

lang <- data.frame(
  val = c("ba", "en", "fr", "la", "vn"),
  img = c(
    "<img src = './images/flags/id.png' width = 20px><div class='jhr'>Bahasa Indonesia</div></img>",
    "<img src = './images/flags/gb.png' width = 20px><div class='jhr'>English</div></img>",
    "<img src = './images/flags/fr.png' width = 20px><div class='jhr'>French</div></img>",
    "<img src = './images/flags/la.png' width = 20px><div class='jhr'>Lao</div></img>",
    "<img src = './images/flags/vn.png' width = 20px><div class='jhr'>Vietnamese</div></img>"
  )
)
  
  
  # define all functions
  for(file in list.files('./www/R/functions/'))  source(paste0('./www/R/functions/', file), local = TRUE)
  
  acorn_theme <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px")
  acorn_theme_la <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px", base_font = "Phetsarath OT")
  
  h4_title <- function(...)  div(class = "h4_title", ...)
  
  tab <- function(...) {
    shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
  }