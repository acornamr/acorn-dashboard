app_version <- "2.5.4"  # Make sure that the app version is identical in DESCRIPTION
session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")

# IMPORTANT: ensure that there is a match between the calls below and:
# - run_app.R
# - DESCRIPTION
# - NAMESPACE

# Calls to these packages are not required as all used functions are prefixed with pack_name::
# aws.s3, ComplexUpset, DBI, DT, flexdashboard, openssl, readr, readxl, REDCapR, RSQLite,
# rvest, shinyjs, writexl

library(bslib)
library(curl)
library(glue)
library(highcharter)
library(lubridate)
library(markdown)  # The includeMarkdown function requires the markdown package.
library(REDCapR)
library(shiny)
library(shiny.i18n)  # i18n$t()
library(shinyWidgets)  # prettyCheckboxGroup()
library(tidyverse)


cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I and R
cols_aware <- c("Access" = "#2c3e50", 
                "Watch" = "#f39c12", 
                "Reserve" = "#e74c3c", 
                "Unknown" = "#969696")

acorn_theme    <- bs_theme(version = 4, bootswatch = "flatly", "border-width" = "2px")
acorn_theme_la <- bs_theme(version = 4, bootswatch = "flatly", "border-width" = "2px", base_font = "Phetsarath OT")
acorn_theme_vn <- bs_theme(version = 4, bootswatch = "flatly", "border-width" = "2px", base_font = "Arial")

hc_export_kind <- c("downloadJPEG", "downloadCSV")

choices_datamanagement <- c("Generate and load .acorn </br> from clinical and lab data", 
                            "Load .acorn </br> from cloud", 
                            "Load .acorn </br> from local file",
                            "Info on </br> loaded .acorn")

code_sites <- c("Run Demo", "Upload Local .acorn",
                readr::read_delim(file = "./www/data/ACORN2_site_codes.csv", delim = ";", show_col_types = FALSE) %>% pull(`ACORN2 site code`))

aware <- readr::read_delim(file = "./www/data/AWaRe_WHO_2019.csv", delim = "\t", show_col_types = FALSE) |> 
  transmute(
    category,
    antibiotic_code = paste0("antibiotic_", tolower(atc_code))
  )

about <- tribble(
  ~ sheet, ~ content,
  "meta",                "Metadata on acorn data generation.",
  "redcap_hai_dta",      "HAI (REDCap F06) form data with one row per submission.",
  "redcap_f01f05_dta",   "REDCap F01,...,F05 forms data with one row per episode.",
  "lab_dta",             "Lab data provided for patients enrolled in ACORN.",
  "acorn_dta",           "REDCap F01,...,F05 forms + Lab data consolidated with one row per isolate. Infection episodes with no linked lab data are not included in this dataset.",
  "tables_dictionary",   "Dictionary of the _dta tables: redcap_hai_dta, redcap_f01f05_dta, lab_dta, and acorn_dta.",
  "corresp_org_antibio", "Organisms that are shown for each antibiotic.",
  "data_dictionary_",    "All (unformated) sheets from the site ACORN2_lab_data_dictionary.xlsx file.",
  "lab_codes_",          "All (unformated) sheets from the ACORN2_lab_codes.xlsx file."
)

current_tables_dictionary <- readr::read_delim(file = "./www/data/tables_dictionary.csv", delim = ";", show_col_types = FALSE)

# safe to expose since the shared_acornamr bucket can only be listed/read
shared_acornamr_key <- readRDS("./www/cred/shared_acornamr_key.rds")
shared_acornamr_sec <- readRDS("./www/cred/shared_acornamr_sec.rds")

# contains all require i18n elements
i18n <- Translator$new(translation_json_path = "./www/translations/translation.json")
i18n$set_translation_language("en")

lang <- data.frame(
  val = c("ba", "en", "fr", "kh", "la", "vn"),
  img = c(
    "<img src = './images/flags/id.png' width = 20px><div class='language_name'>Bahasa Indonesia</div></img>",
    "<img src = './images/flags/gb.png' width = 20px><div class='language_name'>English</div></img>",
    "<img src = './images/flags/fr.png' width = 20px><div class='language_name'>French</div></img>",
    "<img src = './images/flags/kh.png' width = 20px><div class='language_name'>Khmer</div></img>",
    "<img src = './images/flags/la.png' width = 20px><div class='language_name'>Lao</div></img>",
    "<img src = './images/flags/vn.png' width = 20px><div class='language_name'>Vietnamese</div></img>"
  )
)

# source functions
for(file in list.files('./www/R/functions/'))  source(paste0('./www/R/functions/', file), local = TRUE)