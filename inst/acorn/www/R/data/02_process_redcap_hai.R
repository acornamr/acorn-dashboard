dl_hai_dta <- dl_hai_dta %>%
  transmute(site_id = recordid, 
            # redcap_repeat_instrument, 
            # redcap_repeat_instance, 
            # f06odkreckey, 
            survey_date, 
            ward_type = recode(wardtype, MED = "Adult medical ward", SRG = "Adult surgical ward", 
                               ICU = "Adult intensive care unit", PMED = "Pediatric medical ward", 
                               PSRG = "Pediatric surgical ward", PICU = "Pediatric intensive care unit", 
                               NMED = "Neonatal medical ward", NSRG = "Neonatal surgical ward", 
                               NICU = "Neonatal intensive care unit", OBS = "Obstetrics / Gynaecology ward",
                               HON = "Haematology / Oncology ward", EMR = "Emergency department"), 
            ward, 
            mixed_ward = recode(mixward, "Y" = "Yes", "N" = "No", "UNK" = "Unknown"),
            ward_beds = as.numeric(ward_beds), 
            ward_patients = as.numeric(ward_patients), 
            ward_med_patients = as.numeric(ward_med_patients), 
            ward_sur_patients = as.numeric(ward_sur_patients), 
            ward_icu_patients = as.numeric(ward_icu_patients)
            # f06_deleted, 
            # f06_hai_ward_complete
  )


## Test that dates of enrolment match across datasets
if(infection %>% filter(surveillance_category == "HAI") %>% pull(date_episode_enrolment) %in% dl_hai_dta$survey_date %>% all()) {
  checklist_status$redcap_hai_dates <- list(status = "okay", msg = "All dates of enrolment for HAI patients have a matching date in the HAI survey dataset")
} else {
  checklist_status$redcap_hai_dates <- list(status = "warning", msg = "Some dates of enrolment for HAI patients do have a matching date in the HAI survey dataset")
}