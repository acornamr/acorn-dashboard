app_version <- "2.0.7"  # Make sure that the app version is identical in DESCRIPTION and build_standalone_Windows.R
session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")

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
library(markdown)  # to avoid issue with includeMarkdown() on shinyapps.io deployment
library(openssl)  # aes_cbc_decrypt()
library(readr)  # to read lab data
library(readxl)  # to read lab data
library(REDCapR)  # to read clinical data
library(RSQLite)  # to read lab data
library(rvest)  # html_element()
library(shiny)
library(shinyanimate)
library(shiny.i18n)  # i18n$t()
library(shinyjs)
library(shinyWidgets)  # chooseSliderSkin()
library(tidyverse)
library(writexl)

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I, R

acorn_theme <-    bslib::bs_theme(version = 4, bootswatch = "flatly", "border-width" = "2px")
acorn_theme_la <- bslib::bs_theme(version = 4, bootswatch = "flatly", "border-width" = "2px", base_font = "Phetsarath OT")

hc_export_kind <- c("downloadJPEG", "downloadCSV")

code_sites <- c("demo",
                read_delim(file = "./www/data/ACORN2_site_codes.csv", delim = ";", show_col_types = FALSE) %>% pull(`ACORN2 site code`))

columns_redcap <- c("recordid", "redcap_repeat_instrument", "redcap_repeat_instance", 
                    "f01odkreckey", "acornid_odk", "adm_date_odk", "siteid", "siteid_cfm", 
                    "dmdtc", "usubjid", "usubjid_cfm", "acornid", "acornid_cfm", 
                    "brthdtc", "agey", "agem", "aged", "sex", "hpd_adm_date", "hpd_adm_date_cfm", 
                    "cal_agey", "hpd_is_hosp_date", "hpd_is_othfaci_date", "hpd_hosp_date", 
                    "hpd_admtype", "hpd_admreason", "cmb_comorbidities___none", "cmb_comorbidities___aids", 
                    "cmb_comorbidities___onc", "cmb_comorbidities___cpd", "cmb_comorbidities___cog", 
                    "cmb_comorbidities___rheu", "cmb_comorbidities___dem", "cmb_comorbidities___diab", 
                    "cmb_comorbidities___diad", "cmb_comorbidities___hop", "cmb_comorbidities___hivwa", 
                    "cmb_comorbidities___hivna", "cmb_comorbidities___mlr", "cmb_comorbidities___mal", 
                    "cmb_comorbidities___mst", "cmb_comorbidities___mld", "cmb_comorbidities___liv", 
                    "cmb_comorbidities___pep", "cmb_comorbidities___renal", "cmb_comorbidities___tub", "cmb_overnight", 
                    "cmb_rhc", "cmb_surgery", "f01_deleted", "f01_enrolment_complete", 
                    "f02odkreckey", "hpd_dmdtc", "hpd_agegroup", "ifd_surcate", "hpd_onset_date", 
                    "hpd_adm_wardtype", "hpd_adm_ward", "ho_iv_anti_reason", "ser_gcs_under15", 
                    "ser_rr_22up", "ser_sbp_under100", "ser_abnormal_temp_adult", 
                    "ser_abnormal_temp", "ser_inapp_tachycardia", "ser_alter_mental", 
                    "ser_reduce_pp", "ser_neo_reduce", "ser_neo_feed", "ser_neo_convul", 
                    "hai_have_med_device___none", "hai_have_med_device___pcv", "hai_have_med_device___cvc", 
                    "hai_have_med_device___iuc", "hai_have_med_device___vent", "hai_icu48days", 
                    "hai_have_sur", "mic_bloodcollect", "mic_rec_antibiotic", "antibiotic___j01gb06", 
                    "antibiotic___j01ca04", "antibiotic___j01cr02", "antibiotic___j01ca01", 
                    "antibiotic___j01cr01", "antibiotic___j01fa10", "antibiotic___j01ce01", 
                    "antibiotic___j01de01", "antibiotic___j01dd08", "antibiotic___j01dd01", 
                    "antibiotic___j01dd02", "antibiotic___j01dd04", "antibiotic___j01db01", 
                    "antibiotic___j01ma02", "antibiotic___j01fa09", "antibiotic___j01ff01", 
                    "antibiotic___j01cf02", "antibiotic___j01ee01", "antibiotic___j01xx09", 
                    "antibiotic___j01dh04", "antibiotic___j01aa02", "antibiotic___j01dh03", 
                    "antibiotic___j01fa01", "antibiotic___j01gb03", "antibiotic___j01dh51", 
                    "antibiotic___j01ma12", "antibiotic___j01xx08", "antibiotic___j01dh02", 
                    "antibiotic___j01xd01", "antibiotic___j01ma14", "antibiotic___j01ma06", 
                    "antibiotic___j01ma01", "antibiotic___j01ce02", "antibiotic___j01cr05", 
                    "antibiotic___j01fa06", "antibiotic___j01xa02", "antibiotic___j01aa07", 
                    "antibiotic___j01aa12", "antibiotic___j01xa01", "antibiotic___unk", 
                    "antibiotic___oth", "antibiotic_other", "f02_deleted", "f02_infected_episode_complete", 
                    "odkreckey", "no_num_episode", "ho_dmdtc1", "ho_fin_infect_diag1", 
                    "ho_dmdtc2", "ho_fin_infect_diag2", "ho_dmdtc3", "ho_fin_infect_diag3", 
                    "ho_dmdtc4", "ho_fin_infect_diag4", "ho_dmdtc5", "ho_fin_infect_diag5", 
                    "ho_dischargestatus", "ho_dischargeto", "ho_discharge_date", 
                    "ho_days_icu", "deleted", "f03_infection_hospital_outcome_complete", 
                    "f04odkreckey", "d28_date", "d28_status", "d28_death_date", "f04_deleted", 
                    "f04_d28_complete", "f05odkreckey", "wardtype", "ward", "bsi_culture_date", 
                    "bsi_pahtogen", "bsi_ast_date", "bsi_ast_date_unknown___unk", 
                    "bsi_immune_hiv", "bsi_immune_endstage", "bsi_immune_insulin", 
                    "bsi_immune_malignant", "bsi_immune_cytotoxic", "bsi_immune_prednisolone", 
                    "bsi_immune_cirrhosis", "bsi_immune_neutropenia", "bsi_immune_haema", 
                    "bsi_immune_organtran", "bsi_score_temp", "bsi_score_temp_unknown___unk", 
                    "bsi_score_resprate", "bsi_score_resprate_unknown___unk", "bsi_score_hrate", 
                    "bsi_score_hrate_unknown___unk", "bsi_score_sys", "bsi_score_sys_unknown___unk", 
                    "bsi_mentalstatus", "bsi_acute_hypo", "bsi_48h_intvas", "bsi_48h_mv", 
                    "bsi_48h_ca", "bsi_antibiotic_count", "bsi_antibiotic1_name", 
                    "bsi_antibiotic1_name_other", "bsi_antibiotic1_startdate", "bsi_antibiotic1_enddate", 
                    "bsi_antibiotic1_route", "bsi_antibiotic2_name", "bsi_antibiotic2_name_other", 
                    "bsi_antibiotic2_startdate", "bsi_antibiotic2_enddate", "bsi_antibiotic2_route", 
                    "bsi_antibiotic3_name", "bsi_antibiotic3_name_other", "bsi_antibiotic3_startdate", 
                    "bsi_antibiotic3_enddate", "bsi_antibiotic3_route", "bsi_antibiotic4_name", 
                    "bsi_antibiotic4_name_other", "bsi_antibiotic4_startdate", "bsi_antibiotic4_enddate", 
                    "bsi_antibiotic4_route", "bsi_antibiotic5_name", "bsi_antibiotic5_name_oth", 
                    "bsi_antibiotic5_startdate", "bsi_antibiotic5_enddate", "bsi_antibiotic5_route", 
                    "bsi_is_primary", "bsi_sec_source", "bsi_sec_source_oth", "bsi_is_com_implant", 
                    "bsi_is_com_2days", "bsi_is_com_fever", "f05_deleted", "f05_bsi_complete")

# safe to expose since the shared_acornamr bucket can only be listed/read
shared_acornamr_key <- readRDS("./www/cred/bucket_cred/shared_acornamr_key.rds")
shared_acornamr_sec <- readRDS("./www/cred/bucket_cred/shared_acornamr_sec.rds")

# contains all require i18n elements
i18n <- Translator$new(translation_json_path = "./www/translations/translation.json")
i18n$set_translation_language("en")

lang <- data.frame(
  val = c("ba", "en", "fr", "la", "vn"),
  img = c(
    "<img src = './images/flags/id.png' width = 20px><div class='language_name'>Bahasa Indonesia</div></img>",
    "<img src = './images/flags/gb.png' width = 20px><div class='language_name'>English</div></img>",
    "<img src = './images/flags/fr.png' width = 20px><div class='language_name'>French</div></img>",
    "<img src = './images/flags/la.png' width = 20px><div class='language_name'>Lao</div></img>",
    "<img src = './images/flags/vn.png' width = 20px><div class='language_name'>Vietnamese</div></img>"
  )
)

# source functions
for(file in list.files('./www/R/functions/'))  source(paste0('./www/R/functions/', file), local = TRUE)