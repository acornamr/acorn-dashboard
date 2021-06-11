browser()

test <- TRUE
if(test) {
  clin <- tribble(
    ~patient_id, ~surveillance_category, ~date_admission, ~hai_date_symptom_onset,
    "Paul",      "HAI",                  NA,              "2021-03-01",
    "Paul",      "CAI",                  "2021-04-01",    NA,
    "Liz",       "CAI",                  "2021-04-01",    NA,
    "Olivier",   "CAI",                  "2021-01-01",    NA,           
    "Olivier",   "HAI",                  NA,              "2021-01-04",
    "Tam",       "CAI",                  "2021-05-01",    NA,
    "Tam",       "CAI",                  "2021-05-04",    NA) %>%
    mutate(date_admission = as.Date(date_admission),
           hai_date_symptom_onset = as.Date(hai_date_symptom_onset))
  
  lab <- tribble(
    ~patid, ~specdate,    ~specid,  ~isolateid,
    "Paul", "2021-02-28", 1,        1, # removed: specimen date before hai_date_symptom_onset
    "Paul", "2021-03-02", 1,        1, # kept
    "Paul", "2021-03-02", 2,        1, # kept
    "Paul", "2021-03-02", 2,        2, # kept
    "Paul", "2021-04-01", 1,        1, # kept
    "Paul", "2021-04-06", 1,        1, # removed: no date to match
    "Liz",  "2021-03-31", 1,        1, # kept
    "Liz",  "2021-04-01", 1,        1, # kept
    "Ong",  "2021-03-01", 1,        1, # removed: no matching patient in clin
    "Tam",  "2021-05-03", 1,        1, # kept: will be duplicated before treatment of cases of type C
    "Tam",  "2021-05-03", 1,        2) %>% # kept: will be duplicated before treatment of cases of type C
    mutate(specid = glue("{patid}-{specdate}-{specid}")) %>%
    mutate(isolateid = glue("{specid}-{isolateid}")) %>%
    mutate(specdate = as.Date(specdate))
} else {
  lab <- lab_dta() # one row per isolate
  clin <- redcap_dta()  # one row per infection
}


# Detection of cases B
# TODO: inquire with Paul what we should do with those infection episodes:
# warning in the app but no action? error in the app? remove the HAI episode from clin with warning? 
caseB <- clin %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category == "CAI" ~ date_admission)) %>%
  group_by(patient_id) %>%
  filter(n() > 1) %>%
  arrange(date_cai_hai) %>%
  mutate(lag_days = date_cai_hai - lag(date_cai_hai),
         lag_sc = lag(surveillance_category)) %>%
  ungroup() %>%
  filter(surveillance_category == "HAI", lag_sc == "CAI", lag_days == 3)

ifelse(nrow(caseB) == 0, 
       { checklist_status$linkage_caseB <- list(status = "okay", msg = "There are no atypical case (one CAI / early HAI but no overlap)") },
       { checklist_status$linkage_caseB  <- list(status = "warning", msg = paste("The following patient id are atypical cases (one CAI / early HAI but no overlap):", paste(caseB$patient_id, collapse = ", "))) })

# Make a data frame of CAI episodes / HAI episodes and merge
dta_cai <- clin %>%
  filter(surveillance_category == "CAI") %>%
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
    surveillance_category == "CAI" ~ date_admission)) %>%
  group_by(isolateid) %>%
  arrange(date_cai_hai) %>%
  filter(row_number() > 1) %>%
  pull(patient_id) %>%
  unique()

ifelse(is_empty(caseC), 
       { checklist_status$linkage_caseC <- list(status = "okay", msg = "There are no problem case (overlapping specimen collection windows)") },
       { checklist_status$linkage_caseC  <- list(status = "warning", msg = paste("The following patient id are problem case (overlapping specimen collection windows):", paste(caseC, collapse = ", "))) })

acorn_dta <- acorn_dta %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category == "CAI" ~ date_admission)) %>%
  group_by(isolateid) %>%
  arrange(date_cai_hai) %>%
  filter(row_number() == 1) %>%
  ungroup()



# careful that the acorn id WILL be duplicated between the sites
acorn_dta <- acorn_dta %>%
  mutate(
    specdate = as.Date(specdate),
    orgnum = orgnum.acorn,
    organism = orgname,
    organism_local = org.local,
    organism_whonet = org.whonet,
    ast_group = ast.group)