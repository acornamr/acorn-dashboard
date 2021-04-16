# Test "REDCap dataset empty" ----
n <- nrow(dl_redcap_dta)

if(n == 0) {
  checklist_status$redcap_qc_1 <- list(status = "ko", msg = "The REDCap dataset is empty. Please contact ACORN data management.")
} else {
  checklist_status$redcap_qc_1 <- list(status = "okay", msg = glue("The REDCap dataset contains {n} elements."))
}


# Test "REDCap dataset columns number" ----
if(ncol(dl_redcap_dta) != 210) {
  checklist_status$redcap_qc_2 <- list(status = "ko", msg = "The REDCap dataset structure is not as expected (ncol is not 210). Please contact ACORN data management.")
} else {
  checklist_status$redcap_qc_2 <- list(status = "okay", msg = "The REDCap dataset structure is as expected.")
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

# Clean patient_enrolment ----
# columns "odk" have data already in other columns (TODO: confirm with Ong)
# columns "_cfm" are duplicated
patient_enrolment <- patient_enrolment %>%
  select(-c("redcap_repeat_instrument", "redcap_repeat_instance", "f01odkreckey",
            "acornid_odk", "adm_date_odk", "siteid_cfm", "usubjid_cfm", "acornid_cfm",
            "hpd_adm_date_cfm", "f04odkreckey"))

# Clean infection_episode ----
# columns "odk" have data already in other columns (TODO: confirm with Ong)
# id_dmdtc isn't used anymore
infection_episode <- infection_episode %>%
  select(-c("f02odkreckey", "odkreckey", "id_dmdtc"))


# TODO: check that for a given enrollement, all infection episodes are on different dates


if(any(checklist_status$redcap_qc_1$status == "ko",
       checklist_status$redcap_qc_2$status == "ko",
       checklist_status$redcap_qc_3$status == "ko",
       checklist_status$redcap_qc_4$status == "ko",
       checklist_status$redcap_qc_5$status == "ko",
       checklist_status$redcap_qc_6$status == "ko")) {
  checklist_status$redcap_dta <- list(status = "ko", msg = "A critical error was detected during clinical data generation (see above)")
} else {
  
  dta <- left_join(infection_episode, patient_enrolment,
                   by = "recordid")
  redcap_dta(dta)
  
  checklist_status$redcap_dta <- list(status = "okay", msg = glue("Clinical data provided with {length(unique(dta$recordid))} patient enrolments and {nrow(dta)} infection episodes"))
}