showNotification("Trying to retrive REDCap data It might take a minute.", duration = NULL, id = "try_redcap")

dl_redcap_dta <- try(
  withCallingHandlers({
    shinyjs::html(id = "text_redcap_log", "<strong>REDCap data retrieval Log:</strong>")
    redcap_read(
      redcap_uri = "https://m-redcap-test.tropmedres.ac/redcap_test/api/", 
      token = acorn_cred()$redcap_server_api,
      col_types = cols(.default = col_character())
    )$data
  },
  message = function(m) {
    shinyjs::html(id = "text_redcap_log", html = m$message, add = TRUE)
  }
  )
)

if(inherits(dl_redcap_dta, "try-error"))  {
  removeNotification(id = "try_redcap")
  showNotification("We couldn't retrive REDCap Data. Please try again.", type = "error")
  return()
}

removeNotification(id = "try_redcap")
showNotification("Clinical data successfully retrived from REDCap server.")
shinyjs::html(id = "text_redcap_log", "<hr/>", add = TRUE)

# Test "REDCap dataset empty" ----
n <- nrow(dl_redcap_dta)

if(n == 0) {
  checklist_status$redcap_qc_1 <- list(status = "ko", msg = "The REDCap dataset is empty. Please contact ACORN data management.")
} else {
  checklist_status$redcap_qc_1 <- list(status = "okay", msg = glue("The REDCap dataset contains data."))
}


# Test "REDCap dataset columns number" ----
if(ncol(dl_redcap_dta) != 210) {
  checklist_status$redcap_qc_2 <- list(status = "ko", msg = "The REDCap dataset structure is not as expected (not 210 columns). Please contact ACORN data management.")
} else {
  checklist_status$redcap_qc_2 <- list(status = "okay", msg = "The REDCap dataset structure is as expected (210 columns)")
}

# Test "REDCap dataset columns names" ----
if(all(names(dl_redcap_dta) == c("recordid", "redcap_repeat_instrument", "redcap_repeat_instance", 
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
                                 "cmb_comorbidities___pep", "cmb_comorbidities___tub", "cmb_overnight", 
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
                                 "bsi_is_com_2days", "bsi_is_com_fever", "f05_deleted", "f05_bsi_complete"))) {
  checklist_status$redcap_qc_3 <- list(status = "okay", msg = "The REDCap dataset column names match.")
} else {
  checklist_status$redcap_qc_3 <- list(status = "ko", msg = "The REDCap dataset structure is not as expected (columns names do not match). Please contact ACORN data management.")
}

# Create patient_enrolment dataframe ----
patient_enrolment <- dl_redcap_dta %>% 
  select(c(recordid:redcap_repeat_instance, 
           f01odkreckey:f01_enrolment_complete, 
           f04odkreckey:f04_d28_complete)) %>%
  filter(is.na(redcap_repeat_instrument))

# Create infection_episode dataframe ----
# combine F02 and F03
dl_redcap_f02 <- dl_redcap_dta %>% 
  select(c(recordid:redcap_repeat_instance,
           f02odkreckey:f02_infected_episode_complete)) %>%
  filter(!is.na(redcap_repeat_instrument)) %>%
  mutate(id_dmdtc = glue("{recordid}-{hpd_dmdtc}"))

dl_redcap_f03 <- dl_redcap_dta %>% 
  select(c(recordid:redcap_repeat_instance, 
           odkreckey:f03_infection_hospital_outcome_complete)) %>%
  filter(is.na(redcap_repeat_instrument)) %>%
  rename(ho_dmdtc_EPISODE_1 = ho_dmdtc1, ho_fin_infect_diag_EPISODE_1 = ho_fin_infect_diag1,
         ho_dmdtc_EPISODE_2 = ho_dmdtc2, ho_fin_infect_diag_EPISODE_2 = ho_fin_infect_diag2,
         ho_dmdtc_EPISODE_3 = ho_dmdtc3, ho_fin_infect_diag_EPISODE_3 = ho_fin_infect_diag3,
         ho_dmdtc_EPISODE_4 = ho_dmdtc4, ho_fin_infect_diag_EPISODE_4 = ho_fin_infect_diag4,
         ho_dmdtc_EPISODE_5 = ho_dmdtc5, ho_fin_infect_diag_EPISODE_5 = ho_fin_infect_diag5) %>%
  pivot_longer(
    cols = ho_dmdtc_EPISODE_1:ho_fin_infect_diag_EPISODE_5,
    names_to = c(".value", "group"),
    names_sep = "_EPISODE_"
  ) %>%
  filter(!is.na(ho_dmdtc)) %>%
  mutate(id_dmdtc = glue("{recordid}-{ho_dmdtc}"))


infection_episode <- full_join(dl_redcap_f02, 
                               dl_redcap_f03 %>% select(!recordid:redcap_repeat_instance),
                               by = "id_dmdtc") %>%
  select(!redcap_repeat_instrument)


# Test "Every infection episode (F02) has a matching patient enrolment (F01)" ----
# we detect that by finding recordid for which siteid (required value) is missing
# if it happens, we elminate any recordid of all datasets and warn
recordid_no_matching_enrolment <- patient_enrolment$recordid[is.na(patient_enrolment$siteid)]
if(identical(recordid_no_matching_enrolment, character(0))) {
  checklist_status$redcap_qc_4 <- list(status = "okay", msg = "Every infection episode (F02) has a matching patient enrolment (F01)")
} else {
  checklist_status$redcap_qc_4 <- list(status = "warning", msg = paste("The following 'recordid' have an infection episode (F02) but not a matching patient enrolment (F01):",
                                                                       paste(recordid_no_matching_enrolment, collapse = ", ")))
  patient_enrolment <- patient_enrolment %>% filter(!recordid %in% recordid_no_matching_enrolment)
}

# Test "Every hospital outcome (F03) has a matching infection episode (F02)" ----
# we detect that by finding recordid for which siteid (required value) is missing
# if it happens, we elminate any recordid of all datasets and warn
if(all(dl_redcap_f03$id_dmdtc %in% dl_redcap_f02$id_dmdtc)) {
  checklist_status$redcap_qc_5 <- list(status = "okay", msg = "Every hospital outcome (F03) has a matching infection episode (F02)")
} else {
  checklist_status$redcap_qc_5 <- list(status = "warning", msg = "Some hospital outcome (F03) do not have a matching infection episode (F02)")
}

# Test "All confirmed entries match the original entry"
if(all(patient_enrolment$siteid == patient_enrolment$siteid_cfm,
       patient_enrolment$usubjid == patient_enrolment$usubjid_cfm,
       patient_enrolment$acornid == patient_enrolment$acornid_cfm,
       patient_enrolment$hpd_adm_date == patient_enrolment$hpd_adm_date_cfm, na.rm = TRUE)) {
  checklist_status$redcap_qc_6 <- list(status = "okay", msg = "All confirmed entries match the original entry")
} else {
  checklist_status$redcap_qc_6 <- list(status = "ko", msg = "Some confirmed entries do not match the original entry")
}

# TODO: check that for a given enrollement, all infection episodes are on different dates
if(any(checklist_status$redcap_qc_1$status == "ko",
       checklist_status$redcap_qc_2$status == "ko",
       checklist_status$redcap_qc_3$status == "ko",
       checklist_status$redcap_qc_4$status == "ko",
       checklist_status$redcap_qc_5$status == "ko",
       checklist_status$redcap_qc_6$status == "ko")) {
  checklist_status$redcap_dta <- list(status = "ko", msg = "A critical error was detected during clinical data generation (see above)")
  return()
}

dta <- left_join(infection_episode %>%
                   select(-c("f02odkreckey", "odkreckey", "id_dmdtc")), 
                 patient_enrolment %>%
                   select(-c("redcap_repeat_instrument", "redcap_repeat_instance", "f01odkreckey",
                             "acornid_odk", "adm_date_odk", "siteid_cfm", "usubjid_cfm", "acornid_cfm",
                             "hpd_adm_date_cfm", "f04odkreckey")), 
                 by = "recordid")

# Convert columns to date/numeric formats
dta <- dta %>%
  mutate(hpd_dmdtc = as_date(hpd_dmdtc),
         hpd_onset_date = as_date(hpd_onset_date),
         ho_discharge_date = as_date(ho_discharge_date),
         ho_dmdtc = as_date(ho_dmdtc),
         brthdtc = as_date(brthdtc),
         hpd_adm_date = as_date(hpd_adm_date),
         hpd_hosp_date = as_date(hpd_hosp_date),
         d28_date = as_date(d28_date),
         d28_death_date = as_date(d28_death_date)) %>%
  mutate(agey = as.numeric(agey),
         agem = as.numeric(agem),
         aged = as.numeric(aged))

# Summarise the age with agey and aged
dta$aged[is.na(dta$aged) & is.na(dta$brthdtc)] <- 0
dta$agem[is.na(dta$agem) & is.na(dta$brthdtc)] <- 0
dta$agey[is.na(dta$agey) & is.na(dta$brthdtc)] <- 0
dta$calc_aged <- as.numeric(dta$hpd_dmdtc - dta$brthdtc)
dta$calc_aged[is.na(dta$brthdtc)] <- ceiling((dta$aged[is.na(dta$brthdtc)]) + (dta$agem[is.na(dta$brthdtc)] * 30.4375) + (dta$agey[is.na(dta$brthdtc)] * 365.25))
dta$aged <- dta$calc_aged # to replace in the original location: this is age in days at date of enrolment
dta$agey <- round(dta$aged / 365.25, 2) # to make a calculated age in years based on aged: this is age in years at date of enrolment
dta <- dta %>% select(-brthdtc, -calc_aged, -agem)


# START Previousely in 11_prepare_data ----
if(FALSE){
  # Preparation for the App
  patient <- clin %>%
    transmute(
      site_id = SITEID,
      patient_id = as.character(md5(USUBJID)),
      date_enrollment = DMDTC,
      episode_id = as.character(md5(ACORN.EPID)),
      age = AGEY,
      sex = SEX,
      date_admission = HPD_ADM_DATE,
      transfer = HPD_IS_HOSP_DATE,
      date_hospitalisation = HPD_HOSP_DATE,
      ward = HPD_ADM_WARDTYPE,
      ward_text = HPD_ADM_WARD,
      CMB_COMORBIDITIES,
      comorb_cancer = NA,
      comorb_renal = NA,
      comorb_lung = NA,
      comorb_diabetes = NA,
      comorb_malnutrition = NA,
      overnight_3months = CMB_OVERNIGHT,
      surgery_3months = CMB_SURGERY,
      surveillance_cat = IFD_SURCATE,
      surveillance_diag = IFD_SURDIAG,
      date_symptom_onset = IFD_HAI_DATE,
      state_mentation = SER_GCS_UNDER15,
      state_respiratory = SER_RR_22UP,
      state_systolic = SER_SBP_UNDER100,
      state_temperature = SER_ABNORMAL_TEMP,
      state_tachycardia = SER_INAPP_TACHYCARDIA,
      state_mental = SER_ALTER_MENTAL,
      state_perfusion = SER_REDUCE_PP,
      HAI_HAVE_MED_DEVICE,
      medical_p_catheter = NA,
      medical_c_catheter = NA,
      medical_u_catheter = NA,
      medical_ventilation = NA,
      blood_24 = MIC_BLOODCOLLECT,
      antibiotic_24 = MIC_REC_ANTIBIOTIC,
      antibiotic_other = ANTIBIOTIC_OTHER,
      ANTIBIOTIC,
      Amikacin = "No", 
      Amoxicillin = "No", 
      `Amoxicillin-Clavulanate` = "No", 
      Ampicillin = "No", 
      `Ampicillin-Sulbactam`  = "No", 
      Azithromycin = "No", 
      Benzylpenicillin = "No", 
      Cefepime = "No", 
      Cefixime = "No", 
      Cefotaxime = "No", 
      Ceftazidime = "No", 
      Ceftriaxone = "No", 
      Cephalexin = "No", 
      Ciprofloxacin = "No", 
      Clarithromycin = "No", 
      Clindamycin = "No", 
      Cloxacillin = "No", 
      Cotrimoxazole = "No", 
      Daptomycin = "No", 
      Doripenem = "No", 
      Doxycycline = "No",
      Erythromycin = "No", 
      Gentamicin = "No", 
      Imipenem = "No", 
      Levofloxacin = "No", 
      Linezolid = "No",
      Meropenem = "No",
      Metronidazole = "No", 
      Moxifloxacin = "No", 
      Norfloxacin = "No", 
      Ofloxacin = "No", 
      `Penicillin V` = "No", 
      `Piperacillin-Tazobactam` = "No", 
      Roxithromycin = "No", 
      Teicoplanin = "No", 
      Tetracycline = "No", 
      Tigecycline = "No", 
      Vancomycin = "No",
      d28_outcome = ifelse(is.na(D28_DATE), FALSE, TRUE), 
      date_enrollment_d28 = NA, 
      date_admission_d28 = NA, 
      date_discharge = NA, 
      date_d28 = D28_DATE, 
      status_d28 = D28_STATUS, 
      date_death = D28_DEATH_DATE,
      clinical_outcome = ifelse(is.na(HO_DISCHARGESTATUS), FALSE, TRUE),  
      username_outcome = NA, 
      hospital_name_outcome = NA, 
      date_enrollment_outcome = NA, 
      date_admission_outcome = NA, 
      code_icd10 = HO_ICD10, 
      diag_final = HO_FINDIAG,   # CONF or REJ
      sepsis_source = HO_SEPSIS_SOURCE, 
      sepsis_source_other = HO_SEPSIS_SOURCE_OTH, 
      discharge_status = HO_DISCHARGESTATUS, 
      date_discharge_outcome = HO_DISCHARGE_DATE, 
      days_icu = HO_DAYS_ICU)
  
  patient$comorb_cancer[str_detect(patient$CMB_COMORBIDITIES, "ONC")] <- "Cancer"
  patient$comorb_renal[str_detect(patient$CMB_COMORBIDITIES, "CRF")] <- "Chronic renal failure"
  patient$comorb_lung[str_detect(patient$CMB_COMORBIDITIES, "CLD")] <- "Chronic lung disease"
  patient$comorb_diabetes[str_detect(patient$CMB_COMORBIDITIES, "DM")] <- "Diabetes mellitus"
  patient$comorb_malnutrition[str_detect(patient$CMB_COMORBIDITIES, "MAL")] <- "Malnutrition"
  
  patient$medical_p_catheter[str_detect(patient$HAI_HAVE_MED_DEVICE, "PCV")] <- "Peripheral IV catheter"
  patient$medical_c_catheter[str_detect(patient$HAI_HAVE_MED_DEVICE, "CVC")] <- "Central IV catheter"
  patient$medical_u_catheter[str_detect(patient$HAI_HAVE_MED_DEVICE, "IUC")] <- "Urinary catheter"
  patient$medical_ventilation[str_detect(patient$HAI_HAVE_MED_DEVICE, "VENT")] <- "Intubation / Mechanical ventilation"
  
  patient$Amikacin[str_detect(patient$ANTIBIOTIC, "J01GB06")] <- "Yes"
  patient$Amoxicillin[str_detect(patient$ANTIBIOTIC, "J01CA04")] <- "Yes"
  patient$`Amoxicillin-Clavulanate`[str_detect(patient$ANTIBIOTIC, "J01CR02")] <- "Yes"
  patient$Ampicillin[str_detect(patient$ANTIBIOTIC, "J01CA01")] <- "Yes"
  patient$`Ampicillin-Sulbactam` [str_detect(patient$ANTIBIOTIC, "J01CR01")] <- "Yes"
  patient$Azithromycin[str_detect(patient$ANTIBIOTIC, "J01FA10")] <- "Yes"
  patient$Benzylpenicillin[str_detect(patient$ANTIBIOTIC, "J01CE01")] <- "Yes"
  patient$Cefepime[str_detect(patient$ANTIBIOTIC, "J01DE01")] <- "Yes"
  patient$Cefixime[str_detect(patient$ANTIBIOTIC, "J01DD08")] <- "Yes"
  patient$Cefotaxime[str_detect(patient$ANTIBIOTIC, "J01DD01")] <- "Yes"
  patient$Ceftazidime[str_detect(patient$ANTIBIOTIC, "J01DD02")] <- "Yes"
  patient$Ceftriaxone[str_detect(patient$ANTIBIOTIC, "J01DD04")] <- "Yes"
  patient$Cephalexin[str_detect(patient$ANTIBIOTIC, "J01DB01")] <- "Yes"
  patient$Ciprofloxacin[str_detect(patient$ANTIBIOTIC, "J01MA02")] <- "Yes"
  patient$Clarithromycin[str_detect(patient$ANTIBIOTIC, "J01FA09")] <- "Yes"
  patient$Clindamycin[str_detect(patient$ANTIBIOTIC, "J01FF01")] <- "Yes"
  patient$Cloxacillin[str_detect(patient$ANTIBIOTIC, "J01CF02")] <- "Yes"
  patient$Cotrimoxazole[str_detect(patient$ANTIBIOTIC, "J01EE01")] <- "Yes"
  patient$Daptomycin[str_detect(patient$ANTIBIOTIC, "J01XX09")] <- "Yes"
  patient$Doripenem[str_detect(patient$ANTIBIOTIC, "J01DH04")] <- "Yes"
  patient$Doxycycline[str_detect(patient$ANTIBIOTIC, "J01AA02")] <- "Yes"
  patient$Erythromycin[str_detect(patient$ANTIBIOTIC, "J01FA01")] <- "Yes"
  patient$Gentamicin[str_detect(patient$ANTIBIOTIC, "J01GB03")] <- "Yes"
  patient$Imipenem[str_detect(patient$ANTIBIOTIC, "J01DH51")] <- "Yes"
  patient$Levofloxacin[str_detect(patient$ANTIBIOTIC, "J01MA12")] <- "Yes"
  patient$Linezolid[str_detect(patient$ANTIBIOTIC, "J01XX08")] <- "Yes"
  patient$Meropenem[str_detect(patient$ANTIBIOTIC, "J01DH02")] <- "Yes"
  patient$Metronidazole[str_detect(patient$ANTIBIOTIC, "J01XD01")] <- "Yes"
  patient$Moxifloxacin[str_detect(patient$ANTIBIOTIC, "J01MA14")] <- "Yes"
  patient$Norfloxacin[str_detect(patient$ANTIBIOTIC, "J01MA06")] <- "Yes"
  patient$Ofloxacin[str_detect(patient$ANTIBIOTIC, "J01MA01")] <- "Yes"
  patient$`Penicillin V`[str_detect(patient$ANTIBIOTIC, "J01CE02")] <- "Yes"
  patient$`Piperacillin-Tazobactam`[str_detect(patient$ANTIBIOTIC, "J01CR05")] <- "Yes"
  patient$Roxithromycin[str_detect(patient$ANTIBIOTIC, "J01FA06")] <- "Yes"
  patient$Teicoplanin[str_detect(patient$ANTIBIOTIC, "J01XA02")] <- "Yes"
  patient$Tetracycline[str_detect(patient$ANTIBIOTIC, "J01AA07")] <- "Yes"
  patient$Tigecycline[str_detect(patient$ANTIBIOTIC, "J01AA12")] <- "Yes"
  patient$Vancomycin[str_detect(patient$ANTIBIOTIC, "J01XA01")] <- "Yes"
  
  
  
  patient <- patient %>% 
    mutate(
      ward = recode(ward, MED = "Medical", SUR = "Surgical", PED = "Paediatric", ICUNEO = "NICU", ICUPED = "PICU"),
      ward_text = toupper(ward_text),
      sex = recode(sex, M = "Male", `F` = "Female"),
      surveillance_diag = recode(surveillance_diag, MEN = "Meningitis", PNEU = "Pneumonia", SEPSIS = "Sepsis"),
      
      transfer = recode(transfer, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      surgery_3months = recode(surgery_3months, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      
      state_mentation = recode(patient$state_mentation, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_respiratory = recode(patient$state_respiratory, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_systolic = recode(patient$state_systolic, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_temperature = recode(patient$state_temperature, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_tachycardia = recode(patient$state_tachycardia, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_mental = recode(patient$state_mental, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      state_perfusion = recode(patient$state_mental, Y = "Yes", N = "No", UNK = "Unknown", .missing = "Missing Value"),
      
      
      overnight_3months = recode(overnight_3months, Y = "Yes", N = "No"),
      blood_24 = recode(blood_24, Y = "Yes", N = "No"),
      antibiotic_24 = recode(antibiotic_24, Y = "Yes", N = "No"),
      status_d28 = recode(status_d28, ALIVE = "Alive", DEAD = "Dead", UTC = "Unable to Contact"),
      diag_final = recode(diag_final, CONF = "Confirmed", REJ = "Rejected", UPD = "Updated"),
      sepsis_source = recode(sepsis_source, BURN = "Burn", CVS = "Cardiovascular system", CNS = "Central nervous system", 
                             CR = "Line-associated", GI = "Gastrointestinal", IA = "Intra-abdominal", GU = "Genital",
                             UTI = "Urinary tract", URTI = "Upper respiratory tract", LRTI = "Lower respiratory tract", 
                             BJ = "Bone / Joint", SST = "Skin / Soft tissue", UND = "Undefined", OTH = "Other"),
      discharge_status = recode(discharge_status, ALIVE = "Alive", DEAD = "Dead", MORIBUND = "Discharged to die at home",
                                LAMA = "Left against medical advice", TRANS = "Transferred")) %>% 
    select(-CMB_COMORBIDITIES, -HAI_HAVE_MED_DEVICE, -ANTIBIOTIC)
  
  
  # Define Clinical Severity
  patient$clinical_severity <- "Unknown"
  patient$clinical_severity[patient$age >= 18 & (patient$state_mentation == "Yes" | patient$state_respiratory == "Yes" | patient$state_systolic == "Yes")] <- "Severe"
  patient$clinical_severity[patient$age < 18 & (patient$state_temperature == "Yes" | patient$state_tachycardia == "Yes" | 
                                                  patient$state_mental == "Yes" | patient$state_perfusion == "Yes")] <- "Severe"
  
}
# END Previousely in 11_prepare_data ----



redcap_dta(dta)
checklist_status$redcap_dta <- list(status = "okay", 
                                    msg = glue("Clinical data provided with {length(unique(dta$recordid))} patient enrolments and {nrow(dta)} infection episodes"))

if(checklist_status$lab_dta$status == "okay")  {
  updateActionButton(session = session, inputId = "generate_acorn_data", label = HTML("Generate <em>.acorn</em>"), icon = icon("angle-right"))
}
