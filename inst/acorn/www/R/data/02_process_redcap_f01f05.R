# TODO: remove this snippet when it's clear
# Exploration:
# dl_redcap_dta %>%
#   select(recordid, acornid, redcap_repeat_instrument) %>%
#   View()
# acornid can be NA if the record is incomplete; the row is a F02 record.
# a non F02 record without an acornid should trigger a warning and be ignored
# the recordid should be used to complete F02 records with an acornid


# patient_enrolment ----

## Create patient_enrolment dataframe with data from F01 and F04 - one row per enrolment ----
patient_enrolment <- dl_redcap_dta %>% 
  select(c(recordid:redcap_repeat_instance, 
           f01odkreckey:f01_enrolment_complete, 
           f04odkreckey:f04_d28_complete)) %>%
  filter(is.na(redcap_repeat_instrument))

## Test that "Every record has an ACORN id" ----
ifelse(any(is.na(patient_enrolment$acornid)), 
       { checklist_status$redcap_acornid <- list(status = "okay", msg = "All records have an 'ACORN id'") },
       { recordid_na_acornid <- patient_enrolment$recordid[is.na(patient_enrolment$acornid)]
       checklist_status$redcap_acornid <- list(status = "warning", msg = paste("(TODO: TRANSFORM IN ERROR) The following records do not have an 'ACORN id': "), paste(recordid_na_acornid, collapse = ", ")) })

## Test that "Every D28 form (F04) matches exactly one patient enrolment (F01)" ----
# for every recordid, when d28_date is filled (mandatory field in F04), siteid should be filled (mandatory field in F01)
recordid_F04 <- patient_enrolment$recordid[!is.na(patient_enrolment$d28_date)]

ifelse(! any(is.na(patient_enrolment$siteid[patient_enrolment$recordid %in% recordid_F04])),
       { checklist_status$redcap_F04F01 <- list(status = "okay", msg = "Every D28 form (F04) matches exactly one patient enrolment (F01)") },
       { checklist_status$redcap_F04F01 <- list(status = "warning", msg = "Some D28 form (F04) do not have a matching patient enrolment (F01)") })

# infection_episode ----

## Create infection_episode dataframe with one row per infection episode ----
# by combining F02 and F03
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

## Test "Every recorded hospital outcome (F03) has a matching infection episode (F02)" ----
ifelse(all(dl_redcap_f03$id_dmdtc %in% dl_redcap_f02$id_dmdtc), 
       { checklist_status$redcap_F03F02 <- list(status = "okay", msg = "Every recorded hospital outcome (F03) has a matching infection episode (F02)")},
       { checklist_status$redcap_F03F02 <- list(status = "warning", msg = "Some hospital outcome (F03) do not have a matching infection episode (F02)")})

infection_episode <- full_join(dl_redcap_f02, 
                               dl_redcap_f03 %>% select(!recordid:redcap_repeat_instance),
                               by = "id_dmdtc") %>%
  select(!redcap_repeat_instrument)


## Test that "Every infection episode (F02) has a matching patient enrolment (F01)" ----
# we detect that by finding recordid for which siteid (required value) is missing
# if it happens, we elminate any recordid of all datasets and warn
recordid_no_matching_enrolment <- patient_enrolment$recordid[is.na(patient_enrolment$siteid)]
ifelse(identical(recordid_no_matching_enrolment, character(0)), 
       { checklist_status$redcap_F02F01 <- list(status = "okay", msg = "Every infection episode (F02) has a matching patient enrolment (F01)") }, 
       { checklist_status$redcap_F02F01 <- list(status = "warning", msg = paste("The following 'recordid' have an infection episode (F02) but not a matching patient enrolment (F01):",
                                                                                paste(recordid_no_matching_enrolment, collapse = ", ")))
       patient_enrolment <- patient_enrolment %>% filter(!recordid %in% recordid_no_matching_enrolment)})




## Test that "Every hospital outcome form (F03) matches exactly one patient enrolment (F01)"
ifelse(all(dl_redcap_f03$recordid %in% patient_enrolment$recordid), 
       { checklist_status$redcap_F03F01 <- list(status = "okay", msg = "Every hospital outcome form (F03) matches exactly one patient enrolment (F01)") },
       { checklist_status$redcap_F03F01 <- list(status = "warning", msg = "Some hospital outcome (F03) do not have a matching patient enrolment (F01)") })


## Test "All confirmed entries match the original entry"
if(all(patient_enrolment$siteid == patient_enrolment$siteid_cfm,
       patient_enrolment$usubjid == patient_enrolment$usubjid_cfm,
       patient_enrolment$acornid == patient_enrolment$acornid_cfm,
       patient_enrolment$hpd_adm_date == patient_enrolment$hpd_adm_date_cfm, na.rm = TRUE)) {
  checklist_status$redcap_confirmed_match <- list(status = "okay", msg = "All confirmed entries match the original entry")
} else {
  checklist_status$redcap_confirmed_match <- list(status = "ko", msg = "Some confirmed entries do not match the original entry")
}

# TODO: check that for a given enrollement, all infection episodes are on different dates
if(any(checklist_status$redcap_not_empty$status == "ko",
       checklist_status$redcap_structure$status == "ko",
       checklist_status$redcap_columns$status == "ko",
       checklist_status$redcap_acornid$status == "ko",
       checklist_status$redcap_F04F01$status == "ko",
       checklist_status$redcap_F03F02$status == "ko",
       checklist_status$redcap_F02F01$status == "ko",
       checklist_status$redcap_F03F01$status == "ko",
       checklist_status$redcap_confirmed_match$status == "ko")) {
  checklist_status$redcap_dta <- list(status = "ko", msg = "A critical error was detected during clinical data generation (see above)")
  return()
}

# consolidate patient_enrolment & infection_episode in infection ----
infection <- left_join(infection_episode %>%
                         select(-c("f02odkreckey", "odkreckey", "id_dmdtc")), 
                       patient_enrolment %>%
                         select(-c("redcap_repeat_instrument", "redcap_repeat_instance", "f01odkreckey",
                                   "acornid_odk", "adm_date_odk", "siteid_cfm", "usubjid_cfm", "acornid_cfm",
                                   "hpd_adm_date_cfm", "f04odkreckey")), 
                       by = "recordid")

# Convert columns to date/numeric formats
infection <- infection %>%
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
infection$aged[is.na(infection$aged) & is.na(infection$brthdtc)] <- 0
infection$agem[is.na(infection$agem) & is.na(infection$brthdtc)] <- 0
infection$agey[is.na(infection$agey) & is.na(infection$brthdtc)] <- 0
infection$calc_aged <- as.numeric(infection$hpd_dmdtc - infection$brthdtc)
infection$calc_aged[is.na(infection$brthdtc)] <- ceiling((infection$aged[is.na(infection$brthdtc)]) + (infection$agem[is.na(infection$brthdtc)] * 30.4375) + (infection$agey[is.na(infection$brthdtc)] * 365.25))
infection$aged <- infection$calc_aged # to replace in the original location: this is age in days at date of enrolment
infection$agey <- round(infection$aged / 365.25, 2) # to make a calculated age in years based on aged: this is age in years at date of enrolment
infection <- infection %>% select(-brthdtc, -calc_aged, -agem)


# TODO: check if consistent with age_category fieldd
infection$agey[infection$hpd_agegroup == "A"] >= 18
infection$agey[infection$hpd_agegroup == "P"] <= 17
infection$aged[infection$hpd_agegroup == "N"] <= 28

# rename / drop (by commenting) / recode columns
browser()

infection <- infection %>% transmute(
  redcap_id = as.character(md5(recordid)),
  # redcap_repeat_instance,
  # Start fields from F02
  date_episode_enrolment = hpd_dmdtc,
  age_category = hpd_agegroup, 
  suveillance_category = ifd_surcate,
  hai_date_symptom_onset = hpd_onset_date,
  ward_type = recode(hpd_adm_wardtype, MED = "Adult medical ward", SRG = "Adult surgical ward", 
                     ICU = "Adult intensive care unit", PMED = "Pediatric medical ward", 
                     PSRG = "Pediatric surgical ward", PICU = "Pediatric intensive care unit", 
                     NMED = "Neonatal medical ward", NSRG = "Neonatal surgical ward", 
                     NICU = "Neonatal intensive care unit", OBS = "Obstetrics / Gynaecology ward",
                     HON = "Haematology / Oncology ward", EMR = "Emergency department"),
  ward = toupper(hpd_adm_ward), 
  suspected_infection = recode(ho_iv_anti_reason, BJ = "Bone / Joint", CVS = "Cardiovascular system",
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
  med_device_none = recode(hai_have_med_device___none, "0" = "_", "1" = "None"),
  med_device_pcv = recode(hai_have_med_device___pcv, "0" = "_", "1" = "Peripheral IV catheter"),
  med_device_cvc = recode(hai_have_med_device___cvc, "0" = "_", "1" = "Central IV catheter"),
  med_device_iuc = recode(hai_have_med_device___iuc, "0" = "_", "1" = "Urinary catheter"),
  med_device_vent = recode(hai_have_med_device___vent, "0" = "_", "1" = "Intubation / Mechanical ventilation"),
  icu_48_hai = recode(hai_icu48days, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
  surgery_hai = recode(surgery_hai_have_sur, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"), 
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
  antibiotic_other = recode(antibiotic___oth, "0" = "", "1" = "Other"),
  antibiotic_other_text,
  # f02_deleted, 
  # f02_infected_episode_complete, 
  # Start fields from F03:
  total_infection_episode_nb = as.numeric(no_num_episode), 
  ho_discharge_status = recode(ho_dischargestatus, "ALIVE" = "Alive", "DEAD" = "Dead", 
                               "MORIBUND" = "Discharged to die at home", "LAMA" = "Left against medical advice"),
  ho_discharge_to = recode(ho_dischargeto, "HOM" = "Home", "HOS" = "Other hospital", 
                           "LTC" = "Long-term care facility", "NA" = "Not applicable (death)",
                           "UNK" = "Unknown"),
  ho_discharge_date, 
  ho_days_icu = as.numeric(ho_days_icu), 
  # deleted, 
  # f03_infection_hospital_outcome_complete, 
  infection_episode_nb = as.numeric(group),
  ho_date_enrolment = ho_dmdtc, 
  ho_final_diag = recode(ho_fin_infect_diag, BJ = "Bone / Joint", CVS = "Cardiovascular system",
                         CNS = "Central nervous system", URTI = "ENT / Upper respiratory tract",
                         EYE = "Eye", FN = "Febrile neutropenia", GI = "Gastrointestinal",
                         GU = "Genital", IA = "Intra-abdominal", LRTI = "Lower respiratory tract",
                         NEC = "Necrotising enterocolitis", PNEU = "Pneumonia", 
                         SEPSIS = "Sepsis (source unclear)", SSTI = "Skin / Soft tissue", 
                         SSI = "Surgical site", UTI = "Urinary tract", OTH = "Other (diagnosis documented)", 
                         UND = "Undefined (infection treated but no site / source of identified)",
                         UNK = "Unknown (not documented)", REJ = "Infection rejected (alternative diagnosis made)"),
  # End F03
  # Start fields from F01:
  hospital_code = siteid, 
  date_enrolment = dmdtc, 
  patient_id = as.character(md5(usubjid)), 
  acorn_id = as.character(md5(acornid)), 
  age = agey, 
  age_days = aged, 
  sex = recode(sex, M = "Male", `F` = "Female"),
  date_admission = hpd_adm_date, 
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
  cmb_tub = recode(cmb_comorbidities___tub, "0" = "", "1" = "Tuberculosis"), 
  cmb_overnight = recode(cmb_comorbidities___none, "N" = "No", "Y" = "Yes"), 
  cmb_rhc = recode(cmb_rhc, "N" = "No", "Y" = "Yes"), 
  cmb_surgery = recode(cmb_surgery, "N" = "No", "Y" = "Yes"), 
  
  # f01_deleted, 
  # f01_enrolment_complete, 
  # End F01
  # Start fields from F04
  d28_date, 
  d28_status = recode(d28_status, "ALIVE" = "(TBC) Alive - completely recovered", 
                      "ABALIVE" = "(TBC) Alive - not back to normal activities", 
                      "DEAD" = "(TBC) Dead"), # TODO: confime with updated data dic from Ong
  d28_death_date
  # f04_deleted, 
  # f04_d28_complete
  # End F04
)


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