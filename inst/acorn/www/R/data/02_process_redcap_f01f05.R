message("02_process_redcap_f01f05.R")

# Delete records where the "Is mark as delete record" is set to "Yes" for F01 ----
dl_redcap_f01f05_dta <- dl_redcap_f01f05_dta %>%
  replace_na(list(f01_deleted = "N", f02_deleted = "N", deleted = "N", f04_deleted = "N", f05_deleted = "N")) |> 
  filter(f01_deleted != "Y")

# Management of REDCap records where the "Is mark as delete record" is set to "Yes" for F02, F03, F04 or F05 ----
# If a form F02 is marked as deleted, remove the corresponding row.
dl_redcap_f01f05_dta <- dl_redcap_f01f05_dta |> 
  filter(!(!is.na(redcap_repeat_instrument) & f02_deleted == "Y"))

# If a form F03, F04 or F05 is marked as deleted, set corresponding data elements to NA (except for _deleted and _complete).
dl_redcap_f01f05_dta <- dl_redcap_f01f05_dta |> 
  mutate(across(odkreckey:ho_days_icu, 
                ~ replace(., deleted == "Y", NA))) |> 
  mutate(across(f04odkreckey:d28_death_date, 
                ~ replace(., f04_deleted == "Y", NA))) |> 
  mutate(across(f05odkreckey:bsi_is_com_fever, 
                ~ replace(., f05_deleted == "Y", NA)))


# Create patient_enrolment dataframe with data from F01, F04 and F05 - one row per enrolment. ----
patient_enrolment <- dl_redcap_f01f05_dta %>% 
  select(recordid:redcap_repeat_instance, 
         f01odkreckey:f01_enrolment_complete, 
         f04odkreckey:f04_d28_complete,
         f05odkreckey:f05_bsi_complete) %>%
  filter(is.na(redcap_repeat_instrument))

# Test that "Every ACORN ID matches no more than one local ID". ----
test <- left_join(
  patient_enrolment |> 
    group_by(acornid) |> 
    summarise(match_local_id = n_distinct(usubjid)) |> 
    filter(match_local_id >= 2),
  patient_enrolment |> select(usubjid, recordid, acornid),
  join_by = "acornid"
)

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_acorn_id <- list(status = "okay", msg = i18n$t("Every ACORN ID matches no more than one local patient ID.")) },
       { 
         checklist_status$redcap_acorn_id <- list(status = "warning", msg = i18n$t("Some ACORN ID match several local patient IDs.")) 
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "ACORN ID with several local patient IDs.", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = test$acornid))
       })

# Test that "Every local ID matches no more than one ACORN ID". ----
test <- left_join(
  patient_enrolment |> 
    group_by(usubjid) |> 
    summarise(match_acorn_id = n_distinct(acornid)) |> 
    filter(match_acorn_id >= 2),
  patient_enrolment |> select(usubjid, recordid, acornid),
  join_by = "usubjid"
)

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_local_id <- list(status = "okay", msg = i18n$t("Every local patients ID matches no more than one ACORN ID.")) },
       { 
         checklist_status$redcap_local_id <- list(status = "warning", msg = i18n$t("Some local patient ID match several ACORN IDs.")) 
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "Local patient ID with several ACORN IDs.", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = test$acornid))
       })

# Test that "Every D28 form (F04) matches exactly one patient enrolment (F01)". ----
# For every recordid, when d28_date is filled (mandatory field in F04), siteid should be filled (mandatory field in F01).
test <- patient_enrolment |> 
  filter(!is.na(d28_date), is.na(siteid))

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_F04F01 <- list(status = "okay", msg = i18n$t("Every D28 record (F04) matches exactly one patient enrolment (F01).")) },
       { 
         checklist_status$redcap_F04F01 <- list(status = "warning", msg = i18n$t("Some D28 records (F04) don't have a matching patient enrolment (F01).")) 
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "F04 record without matching F01", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = test$acornid))
       })

# Create infection_episode dataframe with one row per infection episode by combining F02 and F03. ----
dl_redcap_f02 <- dl_redcap_f01f05_dta %>% 
  select(c(recordid:redcap_repeat_instance,
           f02odkreckey:f02_infected_episode_complete)) %>%
  filter(!is.na(redcap_repeat_instrument)) %>%
  mutate(id_dmdtc = glue("{recordid}-{hpd_dmdtc}"))

dl_redcap_f03 <- dl_redcap_f01f05_dta %>% 
  select(c(recordid:redcap_repeat_instance, usubjid,
           odkreckey:f03_infection_hospital_outcome_complete)) %>%
  filter(is.na(redcap_repeat_instrument))

dl_redcap_f03 <- dl_redcap_f03 %>%
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

# Test that "Every hospital outcome record (F03) has a matching infection episode record (F02)". ----
test <- dl_redcap_f03 |> 
  filter(!id_dmdtc %in% dl_redcap_f02$id_dmdtc)

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_F03F02 <- list(status = "okay", msg = i18n$t("Every hospital outcome record (F03) has a matching infection episode (F02)."))},
       { 
         checklist_status$redcap_F03F02 <- list(status = "warning", msg = i18n$t("Some hospital outcome records (F03) don't have a matching infection episode (F02). These records have been removed."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "F03 record without matching F02", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = NA))
         dl_redcap_f03 <- dl_redcap_f03 %>% filter(id_dmdtc %in% dl_redcap_f02$id_dmdtc)
       })

infection_episode <- full_join(dl_redcap_f02, 
                               dl_redcap_f03 %>% select(!recordid:usubjid),
                               by = "id_dmdtc") %>%
  select(!redcap_repeat_instrument)

# Test that "outcomes to all the F02s for that admission are recorded in the single F03" ----
# The number entered in Q7 of F03 should be the same as the number of F02.
test <- left_join(
  dl_redcap_f03 |> transmute(recordid, nb_episode_f03 = as.numeric(no_num_episode)),
  dl_redcap_f02 |> group_by(recordid) |> summarise(nb_episode_f02 = n()),
  by = "recordid") |> 
  filter(nb_episode_f02 != nb_episode_f03)

test <- left_join(
  test, 
  patient_enrolment |> select(usubjid, acornid, recordid),
  by = "recordid")

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_F03F02_nb <- list(status = "okay", msg = i18n$t("All patients with multiple infection episodes (F02) per admission (F01) have the correct number of infection episode outcomes recorded in the hospital outcome record (F03)."))},
       { 
         checklist_status$redcap_F03F02_nb <- list(status = "warning", msg = i18n$t("One or more patients with multiple infection episodes (F02) per admission (F01) have an incorrect number of infection episode outcomes recorded in the hospital outcome record (F03)."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "Wrong number of F02 outcomes recorded in the F03 Q7.", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = test$acornid))
       })

# Test that "Every infection episode (F02) has a matching patient enrolment (F01)". ----
test <- patient_enrolment[! dl_redcap_f02$recordid %in% patient_enrolment$recordid, ]
ifelse(nrow(test) == 0, 
       { checklist_status$redcap_F02F01 <- list(status = "okay", msg = i18n$t("Every infection episode record (F02) has a matching patient enrolment (F01).")) }, 
       { 
         checklist_status$redcap_F02F01 <- list(status = "warning", msg = i18n$t("Some infection episode records (F02) don't have a matching patient enrolment (F01). These records have been removed."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "F02 record without matching F01", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = test$acornid))
         patient_enrolment <- patient_enrolment %>% filter(!recordid %in% test)
       })


# Test that "Every hospital outcome form (F03) has a matching patient enrolment (F01)". ----
test <- dl_redcap_f03[! dl_redcap_f03$recordid %in% patient_enrolment$recordid, ]
ifelse(nrow(test) == 0, 
       { checklist_status$redcap_F03F01 <- list(status = "okay", msg = i18n$t("Every hospital outcome record (F03) has a matching patient enrolment (F01).")) },
       { 
         checklist_status$redcap_F03F01 <- list(status = "warning", msg = i18n$t("Some hospital outcome records (F03) don't have a matching patient enrolment (F01).")) 
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "F03 record without matching F01", local_id = test$usubjid, redcap_id = test$recordid, acorn_id = NA))
       })


# Consolidate patient_enrolment & infection_episode in infection dataframe. ----
infection <- left_join(
  infection_episode %>% select(-c("f02odkreckey", "odkreckey", "id_dmdtc")), 
  patient_enrolment %>% select(-c("redcap_repeat_instrument", "redcap_repeat_instance", "f01odkreckey",
                                  "acornid_odk", "adm_date_odk", "siteid_cfm", "usubjid_cfm", "acornid_cfm",
                                  "hpd_adm_date_cfm", "f04odkreckey")), 
  by = "recordid")

infection <- infection %>% transmute(
  redcap_id = recordid,
  # redcap_repeat_instance,
  # Start fields from F02
  date_episode_enrolment = as_date(hpd_dmdtc),
  age_category = recode(hpd_agegroup, "A" = "Adult", "P" = "Child", "N"  = "Neonate"),
  surveillance_category = ifd_surcate,
  hai_date_symptom_onset = as_date(hpd_onset_date),
  ward_type = recode(hpd_adm_wardtype, MED = "Adult medical ward", SRG = "Adult surgical ward", 
                     ICU = "Adult intensive care unit", PMED = "Pediatric medical ward", 
                     PSRG = "Pediatric surgical ward", PICU = "Pediatric intensive care unit", 
                     NMED = "Neonatal medical ward", NSRG = "Neonatal surgical ward", 
                     NICU = "Neonatal intensive care unit", OBS = "Obstetrics / Gynaecology ward",
                     HON = "Haematology / Oncology ward", EMR = "Emergency department"),
  ward = toupper(hpd_adm_ward), 
  surveillance_diag = recode(ho_iv_anti_reason, BJ = "Bone / Joint", CVS = "Cardiovascular system",
                             CNS = "Central nervous system", URTI = "ENT / Upper respiratory tract",
                             EYE = "Eye", FN = "Febrile neutropenia", GI = "Gastrointestinal",
                             GU = "Genital", IA = "Intra-abdominal", LRTI = "Lower respiratory tract",
                             NEC = "Necrotising enterocolitis", PNEU = "Pneumonia", 
                             SEPSIS = "Sepsis (source unclear)", SSTI = "Skin / Soft tissue", 
                             SSI = "Surgical site", UTI = "Urinary tract",
                             OTH = "Other (diagnosis documented)", UNK = "Unknown (not documented)"),
  adult_altered_mentation = recode(ser_gcs_under15, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  adult_respiratory_rate = recode(ser_rr_22up, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  adult_blood_pressure = recode(ser_sbp_under100, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  adult_abnormal_temp = recode(ser_abnormal_temp_adult, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  child_neo_abnormal_temp= recode(ser_abnormal_temp, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  child_neo_inapp_tachycardia = recode(ser_inapp_tachycardia, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  child_neo_alter_mental = recode(ser_alter_mental, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  child_neo_reduce_pp= recode(ser_reduce_pp, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  neo_reduce = recode(ser_neo_reduce, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  neo_feed = recode(ser_neo_feed, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  neo_convul = recode(ser_neo_convul, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  med_device_none = recode(hai_have_med_device___none, "0" = "", "1" = "None"),
  med_device_pcv = recode(hai_have_med_device___pcv, "0" = "", "1" = "Peripheral IV catheter"),
  med_device_cvc = recode(hai_have_med_device___cvc, "0" = "", "1" = "Central IV catheter"),
  med_device_iuc = recode(hai_have_med_device___iuc, "0" = "", "1" = "Urinary catheter"),
  med_device_vent = recode(hai_have_med_device___vent, "0" = "", "1" = "Intubation / Mechanical ventilation"),
  icu_48_hai = recode(hai_icu48days, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  surgery_hai = recode(hai_have_sur, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  blood_collect = recode(mic_bloodcollect, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  received_antibio = recode(mic_rec_antibiotic, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  antibiotic_j01gb06 = recode(antibiotic___j01gb06, "0" = "", "1" = "Amikacin"),
  antibiotic_j01ca04 = recode(antibiotic___j01ca04, "0" = "", "1" = "Amoxicillin"),
  antibiotic_j01cr02 = recode(antibiotic___j01cr02, "0" = "", "1" = "Amoxicillin-Clavulanate"), 
  antibiotic_j01ca01 = recode(antibiotic___j01ca01, "0" = "", "1" = "Ampicillin"),
  antibiotic_j01cr01 = recode(antibiotic___j01cr01, "0" = "", "1" = "Ampicillin-Sulbactam"),
  antibiotic_j01fa10 = recode(antibiotic___j01fa10, "0" = "", "1" = "Azithromycin"),
  antibiotic_j01ce01 = recode(antibiotic___j01ce01, "0" = "", "1" = "Benzylpenicillin"),
  antibiotic_j01de01 = recode(antibiotic___j01de01, "0" = "", "1" = "Cefepime"),
  antibiotic_j01dd08 = recode(antibiotic___j01dd08, "0" = "", "1" = "Cefixime"),
  antibiotic_j01dd01 = recode(antibiotic___j01dd01, "0" = "", "1" = "Cefotaxime"),
  antibiotic_j01dd02 = recode(antibiotic___j01dd02, "0" = "", "1" = "Ceftazidime"),
  antibiotic_j01dd04 = recode(antibiotic___j01dd04, "0" = "", "1" = "Ceftriaxone"),
  antibiotic_j01db01 = recode(antibiotic___j01db01, "0" = "", "1" = "Cephalexin"),
  antibiotic_j01ma02 = recode(antibiotic___j01ma02, "0" = "", "1" = "Ciprofloxacin"),
  antibiotic_j01fa09 = recode(antibiotic___j01fa09, "0" = "", "1" = "Clarithromycin"),
  antibiotic_j01ff01 = recode(antibiotic___j01ff01, "0" = "", "1" = "Clindamycin"),
  antibiotic_j01cf02 = recode(antibiotic___j01cf02, "0" = "", "1" = "Cloxacillin"),
  antibiotic_j01ee01 = recode(antibiotic___j01ee01, "0" = "", "1" = "Cotrimoxazole"),
  antibiotic_j01xx09 = recode(antibiotic___j01xx09, "0" = "", "1" = "Daptomycin"),
  antibiotic_j01dh04 = recode(antibiotic___j01dh04, "0" = "", "1" = "Doripenem"),
  antibiotic_j01aa02 = recode(antibiotic___j01aa02, "0" = "", "1" = "Doxycycline"),
  antibiotic_j01dh03 = recode(antibiotic___j01dh03, "0" = "", "1" = "Ertapenem"),
  antibiotic_j01fa01 = recode(antibiotic___j01fa01, "0" = "", "1" = "Erythromycin"),
  antibiotic_j01gb03 = recode(antibiotic___j01gb03, "0" = "", "1" = "Gentamicin"),
  antibiotic_j01dh51 = recode(antibiotic___j01dh51, "0" = "", "1" = "Imipenem"),
  antibiotic_j01ma12 = recode(antibiotic___j01ma12, "0" = "", "1" = "Levofloxacin"),
  antibiotic_j01xx08 = recode(antibiotic___j01xx08, "0" = "", "1" = "Linezolid"),
  antibiotic_j01dh02 = recode(antibiotic___j01dh02, "0" = "", "1" = "Meropenem"),
  antibiotic_j01xd01 = recode(antibiotic___j01xd01, "0" = "", "1" = "Metronidazole"),
  antibiotic_j01ma14 = recode(antibiotic___j01ma14, "0" = "", "1" = "Moxifloxacin"),
  antibiotic_j01ma06 = recode(antibiotic___j01ma06, "0" = "", "1" = "Norfloxacin"),
  antibiotic_j01ma01 = recode(antibiotic___j01ma01, "0" = "", "1" = "Ofloxacin"),
  antibiotic_j01ce02 = recode(antibiotic___j01ce02, "0" = "", "1" = "Penicillin V"),
  antibiotic_j01cr05 = recode(antibiotic___j01cr05, "0" = "", "1" = "Piperacillin-Tazobactam"),
  antibiotic_j01fa06 = recode(antibiotic___j01fa06, "0" = "", "1" = "Roxithromycin"),
  antibiotic_j01xa02 = recode(antibiotic___j01xa02, "0" = "", "1" = "Teicoplanin"),
  antibiotic_j01aa07 = recode(antibiotic___j01aa07, "0" = "", "1" = "Tetracycline"),
  antibiotic_j01aa12 = recode(antibiotic___j01aa12, "0" = "", "1" = "Tigecycline"),
  antibiotic_j01xa01 = recode(antibiotic___j01xa01, "0" = "", "1" = "Vancomycin"),
  antibiotic_unknown = recode(antibiotic___unk, "0" = "", "1" = "Unknown"),
  antibiotic_any_other = recode(antibiotic___oth, "0" = "", "1" = "Other"),
  antibiotic_other_text = antibiotic_other,
  # f02_deleted, 
  # f02_infected_episode_complete, 
  # Start fields from F03:
  # no_num_episode,
  ho_discharge_status = recode(ho_dischargestatus, "ALIVE" = "Alive", "DEAD" = "Dead", "MORIBUND" = "Discharged to die at home", "LAMA" = "Left against medical advice"),
  ho_discharge_to = recode(ho_dischargeto, "HOM" = "Home", "HOS" = "Other hospital", "LTC" = "Long-term care facility", "NA" = "Not applicable (death)", "UNK" = "Unknown"),   # "Not applicable (death)" category is coded "NA" and will be imported by R as a missing value.
  ho_discharge_date = as_date(ho_discharge_date), 
  ho_days_icu = as.numeric(ho_days_icu), 
  # deleted, 
  # f03_infection_hospital_outcome_complete, 
  # group,
  ho_date_enrolment = as_date(ho_dmdtc), 
  ho_final_diag = recode(ho_fin_infect_diag, BJ = "Bone / Joint", CVS = "Cardiovascular system",
                         CNS = "Central nervous system", URTI = "ENT / Upper respiratory tract",
                         EYE = "Eye", FN = "Febrile neutropenia", GI = "Gastrointestinal",
                         GU = "Genital", IA = "Intra-abdominal", LRTI = "Lower respiratory tract",
                         MELIOID = "Melioidosis",
                         NEC = "Necrotising enterocolitis", PNEU = "Pneumonia", 
                         SSTI = "Skin / Soft tissue", 
                         SSI = "Surgical site", TY = "Typhoid", UTI = "Urinary tract", OTH = "Other (diagnosis documented)", 
                         UND = "Undefined (infection treated but no site / source of identified)",
                         UNK = "Unknown (not documented)", REJ = "Infection rejected (alternative diagnosis made)"),
  # End F03
  # Start fields from F01:
  site_id = siteid, 
  date_enrolment = as_date(dmdtc), 
  patient_id = usubjid,
  acorn_id = acornid,
  birthday = as_date(brthdtc),
  age_year = as.numeric(agey),
  age_month = as.numeric(agem),
  age_day = as.numeric(aged), 
  sex = recode(sex, "M" = "Male", "F" = "Female", "OTH" = "Other", "UNK" = "Unknown sex"),
  date_admission = as_date(hpd_adm_date), 
  # cal_agey, 
  transfer_hospital = recode(hpd_is_hosp_date, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"),
  transfer_facility = recode(hpd_is_othfaci_date, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"),
  date_hospitalisation = hpd_hosp_date, 
  admission_type = recode(hpd_admtype, "EMR" = "Emergency", "ELT" = "Elective", "UNK" = "Unknown"), 
  admission_reason = recode(hpd_admreason, "CARD" = "Cardiovascular condition", "CTD" = "Connective tissue disease",
                            "DRM" = "Dermatological disease", "EMD" = "Endocrine / Metabolic disorder",
                            "GIT" = "Gastrointestinal disorder", "GUD" = "Genitourinary disorder", "GYN" = "Gynaecological disorder",
                            "HMD" = "Haematological disease", "INF" = "Infectious disease", "NRD" = "Neurological disease",
                            "ONC" = "Oncologic disorder", "ORT" = "Orthopaedic condition", "PMD" = "Pulmonary disease",
                            "REN" = "Renal disorder", "TRA" = "Trauma", "UDT" = "Undetermined"),
  cmb_none = recode(cmb_comorbidities___none, "0" = "", "1" = "None"),
  cmb_aids = recode(cmb_comorbidities___aids, "0" = "", "1" = "AIDS"),  
  cmb_onc = recode(cmb_comorbidities___onc, "0" = "", "1" = "Cancer / leukaemia"), 
  cmb_cpd = recode(cmb_comorbidities___cpd, "0" = "", "1" = "Chronic pulmonary disease"), 
  cmb_cog = recode(cmb_comorbidities___cog, "0" = "", "1" = "Congestive heart failure"), 
  cmb_rheu = recode(cmb_comorbidities___rheu, "0" = "", "1" = "Connective tissue / rheumatologic disease"), 
  cmb_dem = recode(cmb_comorbidities___dem, "0" = "", "1" = "Dementia"), 
  cmb_diab = recode(cmb_comorbidities___diab, "0" = "", "1" = "Diabetes"), 
  cmb_diad = recode(cmb_comorbidities___diad, "0" = "", "1" = "Diabetes with end organ damage"), 
  cmb_hop = recode(cmb_comorbidities___hop, "0" = "", "1" = "Hemi- or paraplegia"), 
  cmb_hivwa = recode(cmb_comorbidities___hivwa, "0" = "", "1" = "HIV on ART"), 
  cmb_hivna = recode(cmb_comorbidities___hivna, "0" = "", "1" = "HIV without ART"), 
  cmb_mlr = recode(cmb_comorbidities___mlr, "0" = "", "1" = "Malaria"), 
  cmb_mal = recode(cmb_comorbidities___mal, "0" = "", "1" = "Malnutrition"), 
  cmb_mst = recode(cmb_comorbidities___mst, "0" = "", "1" = "Metastatic solid tumour"), 
  cmb_mld = recode(cmb_comorbidities___mld, "0" = "", "1" = "Mild liver disease"), 
  cmb_liv = recode(cmb_comorbidities___liv, "0" = "", "1" = "Moderate or severe liver disease"), 
  cmb_pep = recode(cmb_comorbidities___pep, "0" = "", "1" = "Peptic ulcer"), 
  cmb_renal = recode(cmb_comorbidities___renal, "0" = "", "1" = "Renal disease"), 
  cmb_tub = recode(cmb_comorbidities___tub, "0" = "", "1" = "Tuberculosis"), 
  cmb_other_overnight = recode(cmb_overnight, "N" = "No", "Y" = "Yes", "UNK" = "Unknown"), 
  cmb_other_rhc = recode(cmb_rhc, "N" = "No", "Y" = "Yes", "UNK" = "Unknown"), 
  cmb_other_surgery = recode(cmb_surgery, "N" = "No", "Y" = "Yes", "UNK" = "Unknown"), 
  # f01_deleted, 
  # f01_enrolment_complete, 
  # End F01
  # Start fields from F04
  d28_date = as_date(d28_date), 
  d28_status = recode(d28_status, 
                      "ALIVE"   = "Alive - completely recovered", 
                      "ABALIVE" = "Alive - not back to normal activities", 
                      "DEAD"    = "Dead",
                      "UTC"     = "Unable to contact",
                      "HX"      = "Hx of Sickness",
                      "ADMIT"   = "Admission",
                      "NOADMIT" = "No Admission"),
  d28_death_date = as_date(d28_death_date),
  # f04_deleted, 
  # f04_d28_complete
  # End F04
  # Start fields from F05
  # f05odkreckey, 
  bsi_ward_type = wardtype, 
  bsi_ward = ward, 
  bsi_culture_date,
  bsi_pahtogen, bsi_ast_date, bsi_ast_date_unknown___unk,
  bsi_immune_hiv, bsi_immune_endstage, bsi_immune_insulin,
  bsi_immune_malignant, bsi_immune_cytotoxic, bsi_immune_prednisolone,
  bsi_immune_cirrhosis, bsi_immune_neutropenia, bsi_immune_haema,
  bsi_immune_organtran, bsi_score_temp, bsi_score_temp_unknown___unk,
  bsi_score_resprate, bsi_score_resprate_unknown___unk, bsi_score_hrate,
  bsi_score_hrate_unknown___unk, bsi_score_sys, bsi_score_sys_unknown___unk,
  bsi_mentalstatus, bsi_acute_hypo, bsi_48h_intvas, bsi_48h_mv,
  bsi_48h_ca, bsi_antibiotic_count, bsi_antibiotic1_name,
  bsi_antibiotic1_name_other, bsi_antibiotic1_startdate, bsi_antibiotic1_enddate,
  bsi_antibiotic1_route, bsi_antibiotic2_name, bsi_antibiotic2_name_other,
  bsi_antibiotic2_startdate, bsi_antibiotic2_enddate, bsi_antibiotic2_route,
  bsi_antibiotic3_name, bsi_antibiotic3_name_other, bsi_antibiotic3_startdate,
  bsi_antibiotic3_enddate, bsi_antibiotic3_route, bsi_antibiotic4_name,
  bsi_antibiotic4_name_other, bsi_antibiotic4_startdate, bsi_antibiotic4_enddate,
  bsi_antibiotic4_route, bsi_antibiotic5_name, bsi_antibiotic5_name_oth,
  bsi_antibiotic5_startdate, bsi_antibiotic5_enddate, bsi_antibiotic5_route,
  bsi_is_primary, bsi_sec_source, bsi_sec_source_oth, bsi_is_com_implant,
  bsi_is_com_2days, bsi_is_com_fever
  # f05_deleted, 
  # f05_bsi_complete
  # End F05
) %>%
  mutate(
    episode_id = glue("{acorn_id}-{date_episode_enrolment}"),
    has_clinical_outcome = !is.na(ho_discharge_date),
    has_d28_outcome = !is.na(d28_date)) %>%
  mutate(across(cmb_aids:cmb_tub, ~ ifelse(. == "", NA, .))) %>%
  unite(comorbidities, cmb_aids:cmb_tub, sep = " & ", na.rm = TRUE, remove = FALSE) %>%
  replace_na(list(surveillance_diag = "Unknown diagnosis",
                  ward_type = "Unknown type of ward",
                  ward = "Unknown ward",
                  sex = "Unknown sex",
                  blood_collect = "Unknown",
                  transfer_hospital = "Unknown",
                  cmb_other_overnight = "Unknown",
                  cmb_other_rhc = "Unknown",
                  cmb_other_surgery = "Unknown",
                  ho_final_diag = "Unknown diagnosis"))

# Split CAI into CAI and HCAI. ----
infection <- infection |> mutate(
  surveillance_category = case_when(
    surveillance_category == "HAI" ~ "HAI",
    surveillance_category == "CAI" & (cmb_other_overnight == "Yes" | cmb_other_rhc == "Yes" | cmb_other_surgery == "Yes") ~ "HCAI",
    TRUE ~ "CAI"
  )
)


# Test if there are D28 follow-up done before the expected D28 date. ----
test <- infection |> 
  filter(
    d28_date < (date_episode_enrolment + 28) & 
      ho_discharge_status != "Dead"
  )

ifelse(nrow(test) == 0, 
       { checklist_status$redcap_D28_date <- list(status = "okay", msg = i18n$t("There are no D28 follow-up done before the expected D28 date.")) },
       {
         checklist_status$redcap_D28_date <- list(status = "warning", msg = i18n$t("There are D28 follow-up done before the expected D28 date."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "D28 follow-up done before the expected D28 date.", local_id = test$patient_id, redcap_id = test$redcap_id, acorn_id = test$acorn_id))
       })


#  Test the presence of "multiple F02 with identical ACORN ID, admission date, and episode enrolment date". ----
test <- infection |> 
  group_by(acorn_id, date_admission, date_episode_enrolment) |> 
  mutate(duplicated_f02 = n() > 1) |> 
  ungroup() |> 
  filter(duplicated_f02) |> 
  distinct(patient_id, redcap_id, acorn_id)


ifelse(nrow(test) == 0, 
       { checklist_status$redcap_multiple_F02 <- list(status = "okay", msg = i18n$t("There are no multiple F02 with identical ACORN ID, admission date, and episode enrolment date.")) },
       {
         checklist_status$redcap_multiple_F02 <- list(status = "warning", msg = i18n$t("There are multiple F02 with identical ACORN ID, admission date, and episode enrolment date."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "Multiple F02 with identical ACORN ID, admission date, and episode enrolment date.", local_id = test$patient_id, redcap_id = test$redcap_id, acorn_id = test$acorn_id))
       })

# Give a count of the episodes for a given patient and date of admission.
infection <- infection |> 
  group_by(
    patient_id, 
    date_admission
  ) |> 
  mutate(
    episode_count = 1:n()
  ) |> 
  ungroup()

# Delete records that have a missing acornid. ----
test <- infection %>% filter(is.na(acorn_id))
ifelse(nrow(test) == 0, 
       { checklist_status$redcap_missing_acorn_id <- list(status = "okay", msg = i18n$t("All valid records have an ACORN ID.")) },
       {
         checklist_status$redcap_missing_acorn_id <- list(status = "warning", msg = i18n$t("Some records with a missing ACORN ID. These records have been removed."))
         checklist_status$log_errors <- bind_rows(checklist_status$log_errors, 
                                                  tibble(issue = "Missing ACORN ID", local_id = test$patient_id, redcap_id = test$redcap_id, acorn_id = "Missing"))
       })
infection <- infection |> filter(! is.na(acorn_id))

# Summarise the age with age_year and age_day. ----
infection$age_day[is.na(infection$age_day) & is.na(infection$birthday)] <- 0
infection$age_month[is.na(infection$age_month) & is.na(infection$birthday)] <- 0
infection$age_year[is.na(infection$age_year) & is.na(infection$birthday)] <- 0
infection$calc_age_day <- as.numeric(infection$date_episode_enrolment - infection$birthday)
infection$calc_age_day[is.na(infection$birthday)] <- ceiling((infection$age_day[is.na(infection$birthday)]) + (infection$age_month[is.na(infection$birthday)] * 30.4375) + (infection$age_year[is.na(infection$birthday)] * 365.25))
infection$age_day <- infection$calc_age_day # to replace in the original location: this is age in days at date of enrolment
infection$age_year <- round(infection$age_day / 365.25, 2) # to make a calculated age in years based on age_day: this is age in years at date of enrolment
infection <- infection %>% select(-birthday, -calc_age_day, -age_month)

# Infer age_category when missing from age_day and age_year. ----
infection <- infection %>% mutate(age_category_calc = case_when(
  age_day <= 28 ~ "Neonate",
  age_year <= 17 ~ "Child",
  age_year > 18 ~ "Adult",
  TRUE ~ "Unknown"))

infection$age_category[is.na(infection$age_category)] <- infection$age_category_calc[is.na(infection$age_category)]

# Define Clinical Severity, qSOFA score. ----
equal_yes <- function(x) replace_na(x, "No") == "Yes"

infection$clinical_severity_score <- 
  (infection$age_category == "Adult") * (
    equal_yes(infection$adult_altered_mentation) + 
      equal_yes(infection$adult_respiratory_rate) + 
      equal_yes(infection$adult_blood_pressure)) +
  (infection$age_category == "Child") * (
    equal_yes(infection$child_neo_abnormal_temp) +
      equal_yes(infection$child_neo_inapp_tachycardia) +
      equal_yes(infection$child_neo_alter_mental) +
      equal_yes(infection$child_neo_reduce_pp)
  ) +
  (infection$age_category == "Neonate") * (
    equal_yes(infection$child_neo_abnormal_temp) +
      equal_yes(infection$child_neo_inapp_tachycardia) +
      equal_yes(infection$child_neo_alter_mental) +
      equal_yes(infection$child_neo_reduce_pp) +
      equal_yes(infection$neo_reduce) +
      equal_yes(infection$neo_feed) +
      equal_yes(infection$neo_convul)
  )

# Define Updated Charlson Comorbidity Index (uCCI). ----
not_empty <- function(x) {
  if (all(is.na(x)))  x <- rep("", length(x))
  replace_na(x, "") != ""
}

infection$cci <- (infection$age_category == "Adult") * (
  2 * not_empty(infection$cmb_cog) + 
    2 * not_empty(infection$cmb_dem) +
    not_empty(infection$cmb_cpd) +
    not_empty(infection$cmb_rheu) +
    2 * not_empty(infection$cmb_mld) +
    not_empty(infection$cmb_diad) +
    2 * not_empty(infection$cmb_hop) +
    not_empty(infection$cmb_renal) +  
    2 * not_empty(infection$cmb_onc) +
    4 * not_empty(infection$cmb_liv) +
    6 * not_empty(infection$cmb_mst) +
    4 * not_empty(infection$cmb_aids)
)

# Reorder columns for save into .acorn. ----
infection <- infection %>% 
  select(
    any_of(
      c(
        "redcap_id", "episode_id", "episode_count",
        # F01:
        "site_id", "date_enrolment", "patient_id", "acorn_id", "age_year", 
        "age_day", "sex", "date_admission", "transfer_hospital", "transfer_facility", 
        "date_hospitalisation", "admission_type", "admission_reason", 
        "cmb_none", "comorbidities", "cmb_aids", "cmb_onc", "cmb_cpd", 
        "cmb_cog", "cmb_rheu", "cmb_dem", "cmb_diab", "cmb_diad", "cmb_hop", 
        "cmb_hivwa", "cmb_hivna", "cmb_mlr", "cmb_mal", "cmb_mst", "cmb_mld", 
        "cmb_liv", "cmb_pep", "cmb_renal", "cmb_tub", "cmb_other_overnight", 
        "cmb_other_rhc", "cmb_other_surgery",
        # F02:
        "date_episode_enrolment", "age_category", 
        "age_category_calc",
        "surveillance_category", 
        "hai_date_symptom_onset", "ward_type", "ward", "surveillance_diag", 
        "adult_altered_mentation", "adult_respiratory_rate", "adult_blood_pressure", 
        "adult_abnormal_temp", "child_neo_abnormal_temp", "child_neo_inapp_tachycardia", 
        "child_neo_alter_mental", "child_neo_reduce_pp", "neo_reduce", 
        "neo_feed", "neo_convul", "clinical_severity_score", "cci",
        "med_device_none", "med_device_pcv", 
        "med_device_cvc", "med_device_iuc", "med_device_vent", "icu_48_hai", 
        "surgery_hai", "blood_collect", "received_antibio", "antibiotic_j01gb06", 
        "antibiotic_j01ca04", "antibiotic_j01cr02", "antibiotic_j01ca01", 
        "antibiotic_j01cr01", "antibiotic_j01fa10", "antibiotic_j01ce01", 
        "antibiotic_j01de01", "antibiotic_j01dd08", "antibiotic_j01dd01", 
        "antibiotic_j01dd02", "antibiotic_j01dd04", "antibiotic_j01db01", 
        "antibiotic_j01ma02", "antibiotic_j01fa09", "antibiotic_j01ff01", 
        "antibiotic_j01cf02", "antibiotic_j01ee01", "antibiotic_j01xx09", 
        "antibiotic_j01dh04", "antibiotic_j01aa02", "antibiotic_j01dh03", 
        "antibiotic_j01fa01", "antibiotic_j01gb03", "antibiotic_j01dh51", 
        "antibiotic_j01ma12", "antibiotic_j01xx08", "antibiotic_j01dh02", 
        "antibiotic_j01xd01", "antibiotic_j01ma14", "antibiotic_j01ma06", 
        "antibiotic_j01ma01", "antibiotic_j01ce02", "antibiotic_j01cr05", 
        "antibiotic_j01fa06", "antibiotic_j01xa02", "antibiotic_j01aa07", 
        "antibiotic_j01aa12", "antibiotic_j01xa01", "antibiotic_unknown", 
        "antibiotic_any_other", "antibiotic_other_text", 
        # F03
        "has_clinical_outcome",
        "ho_discharge_status", "ho_discharge_to", "ho_discharge_date", 
        "ho_days_icu", "ho_date_enrolment", "ho_final_diag", 
        # F04
        "has_d28_outcome",
        "d28_date", "d28_status", 
        "d28_death_date", 
        # F05
        "bsi_ward_type", "bsi_ward", "bsi_culture_date", 
        "bsi_pahtogen", "bsi_ast_date", "bsi_ast_date_unknown___unk", 
        "bsi_immune_hiv", "bsi_immune_endstage", "bsi_immune_insulin", 
        "bsi_immune_malignant", "bsi_immune_cytotoxic", "bsi_immune_prednisolone", 
        "bsi_immune_cirrhosis", "bsi_immune_neutropenia", "bsi_immune_haema", 
        "bsi_immune_organtran", "bsi_score_temp", "bsi_score_temp_unknown___unk", 
        "bsi_score_resprate", "bsi_score_resprate_unknown___unk", "bsi_score_hrate", 
        "bsi_score_hrate_unknown___unk", "bsi_score_sys", "bsi_score_sys_unknown___unk", 
        "bsi_mentalstatus", "bsi_acute_hypo", "bsi_48h_intvas", "bsi_48h_mv", 
        "bsi_48h_ca", "bsi_antibiotic_count", 
        "bsi_antibiotic1_name", "bsi_antibiotic1_name_other", "bsi_antibiotic1_startdate", "bsi_antibiotic1_enddate", "bsi_antibiotic1_route", 
        "bsi_antibiotic2_name", "bsi_antibiotic2_name_other", "bsi_antibiotic2_startdate", "bsi_antibiotic2_enddate", "bsi_antibiotic2_route", 
        "bsi_antibiotic3_name", "bsi_antibiotic3_name_other", "bsi_antibiotic3_startdate", "bsi_antibiotic3_enddate", "bsi_antibiotic3_route", 
        "bsi_antibiotic4_name", "bsi_antibiotic4_name_other", "bsi_antibiotic4_startdate", "bsi_antibiotic4_enddate", "bsi_antibiotic4_route", 
        "bsi_antibiotic5_name", "bsi_antibiotic5_name_oth", "bsi_antibiotic5_startdate", "bsi_antibiotic5_enddate", "bsi_antibiotic5_route", 
        "bsi_antibiotic6_name", "bsi_antibiotic6_name_oth", "bsi_antibiotic6_startdate", "bsi_antibiotic6_enddate", "bsi_antibiotic6_route",
        "bsi_antibiotic7_name", "bsi_antibiotic7_name_oth", "bsi_antibiotic7_startdate", "bsi_antibiotic7_enddate", "bsi_antibiotic7_route",
        "bsi_antibiotic8_name", "bsi_antibiotic8_name_oth", "bsi_antibiotic8_startdate", "bsi_antibiotic8_enddate", "bsi_antibiotic8_route",
        "bsi_antibiotic9_name", "bsi_antibiotic9_name_oth", "bsi_antibiotic9_startdate", "bsi_antibiotic9_enddate", "bsi_antibiotic9_route",
        "bsi_antibiotic10_name", "bsi_antibiotic10_name_oth", "bsi_antibiotic10_startdate", "bsi_antibiotic10_enddate", "bsi_antibiotic10_route",
        "bsi_antibiotic_oth_note",
        "bsi_is_primary", "bsi_sec_source", "bsi_sec_source_oth", "bsi_is_com_implant", 
        "bsi_is_com_2days", "bsi_is_com_fever"
      )
    )
  )
