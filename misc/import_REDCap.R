# Script to import data in REDCap

rm(list = ls())
library(lubridate)
library(tidyverse)


# Import data ----
setwd("/Users/olivier/Documents/Projets/ACORN/REDCap Import/")

f01 <- read_csv("./Test_Data/ACORN_F01_ENROLLMENT.csv")
f02 <- read_csv("./Test_Data/ACORN_F02_HOSPOUTCOME.csv")
f02rep <- read_csv("./Test_Data/ACORN_F02_HOSPOUTCOME-HO_REPEATEPISODE.csv")
f03 <- read_csv("./Test_Data/ACORN_F03_D28.csv")
f04 <- read_csv("./Test_Data/ACORN_F04_HAIWARD.csv")

# data exported from REDCap
# redcap_export <- read_csv("ACORN2_DATA_2021-03-02_0757.csv")
# View(redcap_export)
# View(redcap_export %>% select(redcap_repeat_instrument, f02odkreckey, hpd_dmdtc, hpd_adm_wardtype, hpd_agegroup, ifd_surcate, ho_iv_anti_reason, ho_dmdtc))
# redcap_export %>% 
#   group_by(redcap_repeat_instrument) %>%
#   summarise_all(~sum(! is.na(.)))


# template <- read_csv("ACORN2_ImportTemplate_2021-03-19.csv")
# names(template)
# pattern: 
# "recordid", "redcap_repeat_instrument", "redcap_repeat_instance", 
# f01odkreckey, ..., f01_deleted, f01_enrolment_complete,
# f02odkreckey, ..., f02_deleted, f02_infected_episode_complete, 
# f03odkreckey, ..., f03_deleted, f03_infection_hospital_outcome_complete, 
# f04odkreckey, ..., f04_deleted, f04_d28_complete
# f05odkreckey, ..., f05_deleted, f05_bsi_complete,
# X199


# Merge data as per 08_odk_assembly.R in ACORN-1 ----
## Sort out dates (come out of ODK as d mmm yyyy) with lubridate::dmy ----
# F01
f01 <- f01 %>% 
  mutate(DMDTC = dmy(CAL_DMDTC_TOSTRING), 
         BRTHDTC = dmy(CAL_BRTHDTC_TOSTRING), 
         HPD_ADM_DATE = dmy(CAL_HPD_ADM_DATE_TOSTRING), 
         HPD_HOSP_DATE = dmy(CAL_HPD_HOSP_DATE_TOSTRING),
         IFD_HAI_DATE = dmy(CAL_IFD_HAI_DATE_TOSTRING),
         AGEY = as.numeric(AGEY),
         AGEM = as.numeric(AGEM),
         AGED = as.numeric(AGED))

# F02
f02 <- f02 %>% 
  mutate(HPD_ADM_DATE = dmy(CAL_HPD_ADM_DATE_TOSTRING), 
         HO_DISCHARGE_DATE = dmy(CAL_HO_DISCHARGE_DATE_TOSTRING))

# F02rep
f02rep <- f02rep %>% 
  mutate(DMDTC = dmy(CAL_DMDTC_TOSTRING))

# F03
f03 <- f03 %>% 
  mutate(HPD_ADM_DATE = dmy(CAL_HPD_ADM_DATE_TOSTRING), 
         D28_DATE = dmy(CAL_D28_DATE_TOSTRING),
         D28_DEATH_DATE = dmy(CAL_D28_DEATH_DATE_TOSTRING))

# F04
f04 <- f04 %>% 
  mutate(SURVEY_DATE = dmy(CAL_SURVEY_DATE_TOSTRING))

## Merge f02 and the f02rep infection episode repeats ----
f02 <- left_join(f02, f02rep, by = c("KEY" = "PARENT_KEY"))

# Delete one record in f01 without any matching f02 record
f01 <- f01[-which(!f01$USUBJID %in% f02$USUBJID), ]

## Reduce f01-f02-f03 to a single data.frame (1 infection episode enrolment per row) ----
# Make linker variable (site - subject id - enrolment date)
f01$LINK <- paste(f01$SITEID, f01$USUBJID, f01$DMDTC, sep = "-")
f01$LINK1 <- paste(f01$SITEID, f01$USUBJID, f01$HPD_ADM_DATE, sep = "-") # To link f01 and f03 (as no DMDTC in f03. OK as only one f03 per admission and all f02 for an admission are linked to a single f01)
f02$LINK <- paste(f02$SITEID, f02$USUBJID, f02$DMDTC, sep = "-")
f03$LINK1 <- paste(f03$SITEID, f03$USUBJID, f03$HPD_ADM_DATE, sep = "-")

# Reduce the data.frames (remove duplicated variables)
f01.sel <- f01 %>% select(KEY, LINK, LINK1, SITEID, DMDTC, USUBJID, BRTHDTC, AGEY, AGEM, AGED, SEX,
                          HPD_ADM_DATE, HPD_IS_HOSP_DATE, HPD_HOSP_DATE, HPD_ADM_WARDTYPE, HPD_ADM_WARD,
                          CMB_COMORBIDITIES, CMB_OVERNIGHT, CMB_SURGERY,
                          IFD_SURCATE = `IFD_SURCATE_GROUP-IFD_SURCATE`, IFD_SURDIAG, IFD_HAI_DATE,
                          SER_GCS_UNDER15, SER_RR_22UP, SER_SBP_UNDER100, SER_ABNORMAL_TEMP, SER_INAPP_TACHYCARDIA, SER_ALTER_MENTAL,
                          SER_REDUCE_PP, HAI_HAVE_MED_DEVICE, MIC_BLOODCOLLECT, MIC_REC_ANTIBIOTIC, ANTIBIOTIC, ANTIBIOTIC_OTHER)
f02.sel <- f02 %>% select(LINK, HO_HAVE_ICD10, HO_ICD10, HO_FINDIAG, HO_SEPSIS_SOURCE, HO_SEPSIS_SOURCE_OTH,
                          HO_DISCHARGE_DATE, HO_DISCHARGESTATUS, HO_DAYS_ICU)
f03.sel <- f03 %>% select(LINK1, D28_DATE, D28_STATUS, D28_DEATH_DATE)

# Link f01 (enrolment) to f02 (hosp discharge) and f03 (d28 outcome)
f01.f02.sel <- left_join(f01.sel, f02.sel, by = "LINK")

clin <- left_join(f01.f02.sel, f03.sel, by = "LINK1")  # one row per admission
rm(f01, f01.sel, f01.f02.sel, f02, f02.sel, f02rep, f03, f03.sel)

# (Helper) for easy copy/paste of column names ----

# sink(file = "/Users/olivier/Documents/Projets/ACORN/REDCap Import/names_template.txt")
# for (col in 1:ncol(template)) cat("template$", names(template)[col], " <- ", "\n", sep = "") 
# sink(file = NULL)
# 
# sink(file = "/Users/olivier/Documents/Projets/ACORN/REDCap Import/names_f01.txt")
# for (col in 1:ncol(f01)) cat("f01$", names(f01)[col], "\n", sep = "") 
# sink(file = NULL)
# 
# sink(file = "/Users/olivier/Documents/Projets/ACORN/REDCap Import/names_f02.txt")
# for (col in 1:ncol(f02)) cat("f02$", names(f02)[col], "\n", sep = "") 
# sink(file = NULL)
# 
# sink(file = "/Users/olivier/Documents/Projets/ACORN/REDCap Import/names_f02_rep.txt")
# for (col in 1:ncol(f02_rep)) cat("f02_rep$", names(f02_rep)[col], "\n", sep = "")
# sink(file = NULL)
#
# sink(file = "/Users/olivier/Documents/Projets/ACORN/REDCap Import/names_f03.txt")
# for (col in 1:ncol(f03)) cat("f03$", names(f03)[col], "\n", sep = "") 
# sink(file = NULL)


# Creation of files for REDCap import ----

nb_clin <- nrow(clin)
set.seed(0203)
sample_10_records <- sample(paste0("import-acorn1b-", 1:nb_clin), 10)


## template_f01 ----
template_f01 <- tibble(recordid = paste0("import-acorn1b-", 1:nb_clin))

template_f01$f01odkreckey <- clin$KEY
template_f01$acornid_odk <- ""
template_f01$adm_date_odk <- ""
template_f01$siteid <- clin$SITEID
template_f01$siteid_cfm <- clin$SITEID
template_f01$dmdtc <- clin$DMDTC
template_f01$usubjid <- clin$USUBJID
template_f01$usubjid_cfm <- clin$USUBJID
template_f01$acornid <- paste0("ACORN-", 1:nb_clin)
template_f01$acornid_cfm <- paste0("ACORN-", 1:nb_clin)
template_f01$brthdtc <- clin$BRTHDTC
template_f01$agey <- clin$AGEY
template_f01$agem <- clin$AGEM
template_f01$aged <- clin$AGED
template_f01$sex <- clin$SEX
template_f01$hpd_adm_date <- clin$HPD_ADM_DATE
template_f01$hpd_adm_date_cfm <- clin$HPD_ADM_DATE
template_f01$hpd_is_hosp_date <- clin$HPD_IS_HOSP_DATE
template_f01$hpd_is_othfaci_date <- ""
template_f01$hpd_hosp_date <- clin$HPD_HOSP_DATE
template_f01$hpd_admtype <- ""
template_f01$hpd_admreason <- ""
template_f01$cmb_comorbidities___aids <- 0
template_f01$cmb_comorbidities___onc <- as.numeric(grepl("ONC", clin$CMB_COMORBIDITIES))
template_f01$cmb_comorbidities___cpd <- as.numeric(grepl("CLD", clin$CMB_COMORBIDITIES))
template_f01$cmb_comorbidities___cog <- 0
template_f01$cmb_comorbidities___rheu <- 0
template_f01$cmb_comorbidities___dem <- 0
template_f01$cmb_comorbidities___diab <- as.numeric(grepl("DM", clin$CMB_COMORBIDITIES))
template_f01$cmb_comorbidities___diad <- 0
template_f01$cmb_comorbidities___hop <- 0
template_f01$cmb_comorbidities___hivwa <- 0
template_f01$cmb_comorbidities___hivna <- 0
template_f01$cmb_comorbidities___mlr <- 0
template_f01$cmb_comorbidities___mal <- as.numeric(grepl("MAL", clin$CMB_COMORBIDITIES))
template_f01$cmb_comorbidities___mst <- 0
template_f01$cmb_comorbidities___mld <- 0
template_f01$cmb_comorbidities___liv <- 0
template_f01$cmb_comorbidities___pep <- 0
template_f01$cmb_comorbidities___tub <- 0
template_f01$cmb_overnight <- clin$CMB_OVERNIGHT
template_f01$cmb_rhc <- ""
template_f01$cmb_surgery <- clin$CMB_SURGERY
template_f01$f01_deleted <- ""
template_f01$f01_enrolment_complete <- ""
template_f01$f04odkreckey <- clin$KEY
template_f01$d28_date <- clin$D28_DATE
template_f01$d28_status <- clin$D28_STATUS
template_f01$d28_death_date <- clin$D28_DEATH_DATE
template_f01$f04_deleted <- ""
template_f01$f04_d28_complete <- ""

# Export
template_f01 <- template_f01  %>%
  mutate(across(everything(), as.character)) %>% 
  replace(is.na(.), "")

write_csv(template_f01, file = "template_f01_REDCap_2021-05-03.csv")
write_csv(template_f01 %>% filter(recordid %in% sample_10_records), 
          file = "template_f01_REDCap_sample10rows_2021-05-03.csv")

# These are new and all set to NA
# template_f01$f05odkreckey <- NA
# template_f01$wardtype <- NA
# template_f01$ward <- NA
# template_f01$bsi_culture_date <- NA
# template_f01$bsi_pahtogen <- NA
# template_f01$bsi_ast_date <- NA
# template_f01$bsi_ast_date_unknown___unk <- NA
# template_f01$bsi_immune_hiv <- NA
# template_f01$bsi_immune_endstage <- NA
# template_f01$bsi_immune_insulin <- NA
# template_f01$bsi_immune_malignant <- NA
# template_f01$bsi_immune_cytotoxic <- NA
# template_f01$bsi_immune_prednisolone <- NA 
# template_f01$bsi_immune_cirrhosis <- NA
# template_f01$bsi_immune_neutropenia <- NA
# template_f01$bsi_immune_haema <- NA
# template_f01$bsi_immune_organtran <- NA
# template_f01$bsi_score_temp <- NA
# template_f01$bsi_score_temp_unknown___unk <- NA
# template_f01$bsi_score_resprate <- NA
# template_f01$bsi_score_resprate_unknown___unk <- NA
# template_f01$bsi_score_hrate <- NA
# template_f01$bsi_score_hrate_unknown___unk <- NA
# template_f01$bsi_score_sys <- NA
# template_f01$bsi_score_sys_unknown___unk <- NA
# template_f01$bsi_mentalstatus <- NA
# template_f01$bsi_acute_hypo <- NA
# template_f01$bsi_48h_intvas <- NA
# template_f01$bsi_48h_mv <- NA
# template_f01$bsi_48h_ca <- NA
# template_f01$bsi_antibiotic_count <- NA
# template_f01$bsi_antibiotic1_name <- NA
# template_f01$bsi_antibiotic1_name_other <- NA
# template_f01$bsi_antibiotic1_startdate <- NA
# template_f01$bsi_antibiotic1_enddate <- NA
# template_f01$bsi_antibiotic1_route <- NA
# template_f01$bsi_antibiotic2_name <- NA
# template_f01$bsi_antibiotic2_name_other <- NA
# template_f01$bsi_antibiotic2_startdate <- NA
# template_f01$bsi_antibiotic2_enddate <- NA
# template_f01$bsi_antibiotic2_route <- NA
# template_f01$bsi_antibiotic3_name <- NA
# template_f01$bsi_antibiotic3_name_other <- NA
# template_f01$bsi_antibiotic3_startdate <- NA
# template_f01$bsi_antibiotic3_enddate <- NA
# template_f01$bsi_antibiotic3_route <- NA
# template_f01$bsi_antibiotic4_name <- NA
# template_f01$bsi_antibiotic4_name_other <- NA
# template_f01$bsi_antibiotic4_startdate <- NA
# template_f01$bsi_antibiotic4_enddate <- NA
# template_f01$bsi_antibiotic4_route <- NA
# template_f01$bsi_antibiotic5_name <- NA
# template_f01$bsi_antibiotic5_name_oth <- NA
# template_f01$bsi_antibiotic5_startdate <- NA
# template_f01$bsi_antibiotic5_enddate <- NA
# template_f01$bsi_antibiotic5_route <- NA
# template_f01$bsi_is_primary <- NA
# template_f01$bsi_sec_source <- NA
# template_f01$bsi_sec_source_oth <- NA
# template_f01$bsi_is_com_implant <- NA
# template_f01$bsi_is_com_2days <- NA
# template_f01$bsi_is_com_fever <- NA
# template_f01$f05_deleted <- NA
# template_f01$f05_bsi_complete <- NA


## template_f02 ----
template_f02 <- tibble(recordid = paste0("import-acorn1b-", 1:nb_clin),
                       redcap_repeat_instrument = "f02_infected_episode",
                       redcap_repeat_instance = 1)

template_f02$f02odkreckey <- clin$KEY
template_f02$hpd_dmdtc <- clin$DMDTC
template_f02$hpd_agegroup <- ""
template_f02$ifd_surcate <- clin$IFD_SURCATE
template_f02$hpd_onset_date <- clin$IFD_HAI_DATE

template_f02$hpd_adm_wardtype <- clin$HPD_ADM_WARDTYPE
template_f02$hpd_adm_wardtype[template_f02$hpd_adm_wardtype == "SUR"] <- "SRG"
template_f02$hpd_adm_wardtype[template_f02$hpd_adm_wardtype == "PED"] <- "PMED"
template_f02$hpd_adm_wardtype[template_f02$hpd_adm_wardtype == "ICUNEO"] <- "NICU"
template_f02$hpd_adm_wardtype[template_f02$hpd_adm_wardtype == "ICUPED"] <- "PICU"

template_f02$hpd_adm_ward <- clin$HPD_ADM_WARD
template_f02$ho_iv_anti_reason <- ""
template_f02$ser_gcs_under15 <- clin$SER_GCS_UNDER15
template_f02$ser_rr_22up <- clin$SER_RR_22UP
template_f02$ser_sbp_under100 <- clin$SER_SBP_UNDER100
template_f02$ser_abnormal_temp <- clin$SER_ABNORMAL_TEMP  # same coding Y/N/UNK
template_f02$ser_inapp_tachycardia <- clin$SER_INAPP_TACHYCARDIA  # same coding Y/N/UNK
template_f02$ser_alter_mental <- clin$SER_ALTER_MENTAL  # same coding Y/N/UNK
template_f02$ser_reduce_pp <- clin$SER_REDUCE_PP  # same coding Y/N/UNK
template_f02$ser_neo_reduce <- ""  # NEW (conditional neonate)
template_f02$ser_neo_feed <- ""  # NEW (conditional neonate)
template_f02$ser_neo_convul <- ""  # NEW (conditional neonate)
template_f02$hai_have_med_device___pcv <- as.numeric(grepl("PCV", clin$HAI_HAVE_MED_DEVICE))
template_f02$hai_have_med_device___cvc <- as.numeric(grepl("CVC", clin$HAI_HAVE_MED_DEVICE))
template_f02$hai_have_med_device___iuc <- as.numeric(grepl("IUC", clin$HAI_HAVE_MED_DEVICE))
template_f02$hai_have_med_device___vent <- as.numeric(grepl("VENT", clin$HAI_HAVE_MED_DEVICE))
template_f02$hai_icu48days <- "" # NEW
template_f02$hai_have_sur <- "" # NEW
template_f02$mic_bloodcollect <- clin$MIC_BLOODCOLLECT
template_f02$mic_rec_antibiotic <- clin$MIC_REC_ANTIBIOTIC
template_f02$antibiotic___j01gb06 <- as.numeric(grepl("J01GB06", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ca04 <- as.numeric(grepl("J01CA04", clin$ANTIBIOTIC))
template_f02$antibiotic___j01cr02 <- as.numeric(grepl("J01CR02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ca01 <- as.numeric(grepl("J01CA01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01cr01 <- as.numeric(grepl("J01CR01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01fa10 <- as.numeric(grepl("J01FA10", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ce01 <- as.numeric(grepl("J01CE01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01de01 <- as.numeric(grepl("J01DE01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dd08 <- as.numeric(grepl("J01DD08", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dd01 <- as.numeric(grepl("J01DD01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dd02 <- as.numeric(grepl("J01DD02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dd04 <- as.numeric(grepl("J01DD04", clin$ANTIBIOTIC))
template_f02$antibiotic___j01db01 <- as.numeric(grepl("J01DB01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ma02 <- as.numeric(grepl("J01MA02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01fa09 <- as.numeric(grepl("J01FA09", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ff01 <- as.numeric(grepl("J01FF01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01cf02 <- as.numeric(grepl("J01CF02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ee01 <- as.numeric(grepl("J01EE01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01xx09 <- as.numeric(grepl("J01XX09", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dh04 <- as.numeric(grepl("J01DH04", clin$ANTIBIOTIC))
template_f02$antibiotic___j01aa02 <- as.numeric(grepl("J01AA02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dh03 <- 0  # NEW
template_f02$antibiotic___j01fa01 <- as.numeric(grepl("J01FA01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01gb03 <- as.numeric(grepl("J01GB03", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dh51 <- as.numeric(grepl("J01DH51", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ma12 <- as.numeric(grepl("J01MA12", clin$ANTIBIOTIC))
template_f02$antibiotic___j01xx08 <- as.numeric(grepl("J01XX08", clin$ANTIBIOTIC))
template_f02$antibiotic___j01dh02 <- as.numeric(grepl("J01DH02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01xd01 <- as.numeric(grepl("J01XD01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ma14 <- as.numeric(grepl("J01MA14", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ma06 <- as.numeric(grepl("J01MA06", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ma01 <- as.numeric(grepl("J01MA01", clin$ANTIBIOTIC))
template_f02$antibiotic___j01ce02 <- as.numeric(grepl("J01CE02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01cr05 <- as.numeric(grepl("J01CR05", clin$ANTIBIOTIC))
template_f02$antibiotic___j01fa06 <- as.numeric(grepl("J01FA06", clin$ANTIBIOTIC))
template_f02$antibiotic___j01xa02 <- as.numeric(grepl("J01XA02", clin$ANTIBIOTIC))
template_f02$antibiotic___j01aa07 <- as.numeric(grepl("J01AA07", clin$ANTIBIOTIC))
template_f02$antibiotic___j01aa12 <- as.numeric(grepl("J01AA12", clin$ANTIBIOTIC))
template_f02$antibiotic___j01xa01 <- as.numeric(grepl("J01XA01", clin$ANTIBIOTIC))
template_f02$antibiotic___unk <- as.numeric(grepl("UNK", clin$ANTIBIOTIC))
template_f02$antibiotic___oth <- as.numeric(grepl("OTH", clin$ANTIBIOTIC))
template_f02$antibiotic_other <- clin$ANTIBIOTIC_OTHER
template_f02$f02_deleted <- ""
template_f02$f02_infected_episode_complete <- ""

# Export
template_f02 <- template_f02  %>%
  mutate(across(everything(), as.character)) %>% 
  replace(is.na(.), "")

write_csv(template_f02, file = "template_f02_REDCap_2021-05-03.csv")
write_csv(template_f02 %>% filter(recordid %in% sample_10_records), 
          file = "template_f02_REDCap_sample10rows_2021-05-03.csv")

## template_f03 ----
template_f03 <- tibble(recordid = paste0("import-acorn1b-", 1:nb_clin))

# template_f03$f03odkreckey <- clin$KEY
template_f03$ho_dmdtc1 <- clin$DMDTC
template_f03$ho_fin_infect_diag1 <- clin$IFD_SURDIAG
template_f03$ho_dmdtc2 <- ""
template_f03$ho_fin_infect_diag2 <- ""
template_f03$ho_dmdtc3 <- ""
template_f03$ho_fin_infect_diag3 <- ""
template_f03$ho_dmdtc4 <- ""
template_f03$ho_fin_infect_diag4 <- ""
template_f03$ho_dmdtc5 <- ""
template_f03$ho_fin_infect_diag5 <- ""
# Random assignment of SEPSIS
n_sepsis <- sum(template_f03$ho_fin_infect_diag1 == "SEPSIS")
template_f03$ho_fin_infect_diag1[template_f03$ho_fin_infect_diag1 == "SEPSIS"] <-  sample(c("BJ", "CVS", "OTH", "URTI", "EYE", "FN", "GI", "GU", "IA", "LRTI", "NEC", "PNEU", "SSTI", "SSI", "UTI", "OTH", "UNK"), n_sepsis, replace = TRUE)
template_f03$ho_fin_infect_diag1[template_f03$ho_fin_infect_diag1 == "MEN"] <- "CNS"

template_f03$ho_dischargestatus <- clin$HO_DISCHARGESTATUS
template_f03$ho_dischargestatus[template_f03$ho_dischargestatus == "TRANS"] <- "ALIVE"
template_f03$ho_dischargeto[template_f03$ho_dischargestatus == "DEAD"] <- "NA"
n_not_dead <- sum(template_f03$ho_dischargestatus != "DEAD")
template_f03$ho_dischargeto[template_f03$ho_dischargestatus != "DEAD"] <- sample(c("HOM", "HOS", "LTC", "UNK"), n_not_dead, replace = TRUE) 
template_f03$ho_discharge_date <- clin$HO_DISCHARGE_DATE
template_f03$ho_days_icu <- clin$HO_DAYS_ICU
template_f03$f03_infection_hospital_outcome_complete <- ""

# Export
template_f03 <- template_f03  %>%
  mutate(across(everything(), as.character)) %>% 
  replace(is.na(.), "")

write_csv(template_f03, file = "template_f03_REDCap_2021-05-03.csv")
write_csv(template_f03 %>% filter(recordid %in% sample_10_records), 
          file = "template_f03_REDCap_sample10rows_2021-05-03.csv")

# template_hai ---- 
nb_hai <- nrow(f04)
template_hai <- tibble(recordid = paste0("import-acorn1b-hai-", 1:nb_hai),
                       redcap_repeat_instrument = "f06_hai_ward",
                       redcap_repeat_instance = 1)

template_hai$f06odkreckey <- f04$KEY
template_hai$survey_date <- f04$SURVEY_DATE

template_hai$wardtype <- f04$WARDTYPE
template_hai$wardtype[template_hai$wardtype == "SUR"] <- "SRG"
template_hai$wardtype[template_hai$wardtype == "PED"] <- "PMED"
template_hai$wardtype[template_hai$wardtype == "ICUNEO"] <- "NICU"
template_hai$wardtype[template_hai$wardtype == "ICUPED"] <- "PICU"

template_hai$ward <- f04$WARD
template_hai$mixward <- f04$MIXWARD
template_hai$ward_beds <- f04$WARD_BEDS
template_hai$ward_patients <- f04$WARD_PATIENTS
template_hai$ward_med_patients <- f04$WARD_PATIENTS
template_hai$ward_sur_patients <- f04$`FORMIXWARD-WARD_MED_PATIENTS`
template_hai$ward_icu_patients <- f04$`FORMIXWARD-WARD_SUR_PATIENTS`
template_hai$f06_deleted <- ""
template_hai$f06_hai_ward_complete <- ""

template_hai <- template_hai  %>%
  mutate(across(everything(), as.character)) %>% 
  replace(is.na(.), "")

write_csv(template_hai, file = "template_hai_REDCap_2021-05-03.csv")
