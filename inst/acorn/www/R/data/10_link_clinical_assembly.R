message("10_link_clinical_assembly.R")

# Detection of cases B
caseB <- clin %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category %in% c("CAI", "HCAI") ~ date_admission)) %>%
  group_by(patient_id) %>%
  filter(n() > 1) %>%
  arrange(date_cai_hai) %>%
  mutate(lag_days = date_cai_hai - lag(date_cai_hai),
         lag_sc = lag(surveillance_category)) %>%
  ungroup() %>%
  filter(surveillance_category == "HAI", lag_sc %in% c("CAI", "HCAI"), lag_days == 3)

ifelse(nrow(caseB) == 0, 
       { checklist_status$linkage_caseB <- list(status = "okay", msg = i18n$t("There are no atypical case (one HCAI/CAI with early HAI but no overlap).")) },
       { checklist_status$linkage_caseB  <- list(status = "warning", msg = paste(i18n$t("The following 'patient id' are atypical cases (one HCAI/CAI with early HAI but no overlap):"),
                                                                                 paste(caseB$patient_id, collapse = ", "))) })

# Make a data frame of (H)CAI episodes / HAI episodes and merge
dta_cai <- clin %>%
  filter(surveillance_category %in% c("CAI", "HCAI")) %>%
  inner_join(lab, by = c("patient_id" = "patid")) %>%
  filter(specdate >= (date_admission - 2),
         specdate <= (date_admission + 2))

dta_hai <- clin %>%
  filter(surveillance_category == "HAI") %>%
  inner_join(lab, by = c("patient_id" = "patid")) %>%
  filter(specdate >= hai_date_symptom_onset,
         specdate <= (hai_date_symptom_onset + 2))

acorn_dta <- bind_rows(dta_cai, dta_hai) 

# remove case C - require to have an isolate id.
# would not work with specid as specimens with several isolates 
# would be removed by mistake

caseC <- acorn_dta %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category %in% c("CAI", "HCAI") ~ date_admission)) %>%
  group_by(isolateid) %>%
  arrange(date_cai_hai) %>%
  filter(row_number() > 1) %>%
  pull(patient_id) %>%
  unique()

ifelse(is_empty(caseC), 
       checklist_status$linkage_caseC <- list(status = "okay", msg = i18n$t("There are no problem case (overlapping specimen collection windows)")),
       checklist_status$linkage_caseC  <- list(status = "warning", msg = paste(i18n$t("The following 'patient id' are problem case (overlapping specimen collection windows):"), 
                                                                               paste(caseC, collapse = ", ")))
)

acorn_dta <- acorn_dta %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category %in% c("CAI", "HCAI") ~ date_admission)) %>%
  group_by(isolateid) %>%
  arrange(date_cai_hai) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  replace_na(list(contaminant = "No"))

ifelse(nrow(acorn_dta) >= 1,
       checklist_status$linkage_result <- list(status = "okay", msg = i18n$t("Successfully combined clinical and lab data into .acorn file")),
       checklist_status$linkage_result <- list(status = "ko", msg = i18n$t("Error in combining clinical and lab data."))
)