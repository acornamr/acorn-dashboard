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
    "Tam",       "CAI",                  "2021-05-04",    NA,
  ) %>%
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
    "Tam",  "2021-05-03", 1,        2, # kept: will be duplicated before treatment of cases of type C
  ) %>%
    mutate(specid = glue("{patid}-{specdate}-{specid}")) %>%
    mutate(isolateid = glue("{specid}-{isolateid}")) %>%
    mutate(specdate = as.Date(specdate))
} else {
  lab <- lab_dta()      # one row per isolate
  clin <- redcap_dta()  # one row per infection
}


# Case B
# TODO: inquire with Paul what we should do with those infection episodes:
# warning in the app but no action? error in the app? remove the HAI episode from clin with warning? 
clin %>% 
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
acorn_dta <- acorn_dta %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category == "CAI" ~ date_admission)) %>%
  group_by(isolateid) %>%
  arrange(date_cai_hai) %>%
  filter(row_number() == 1) %>%
  ungroup()


# TODO: anonymise with md5()
# careful that the acorn id WILL be duplicated between the sites
# acorn id should be non hashed / patient id should be hashed / we should be able to get back the specimen id
acorn_dta <- acorn_dta %>%
  mutate(
    patient_id = patid, # as.character(md5(patid)),
    specimen_id = specid, # as.character(md5(specid)),
    # episode_id = as.character(md5(ACORN.EPID)),  # TODO: clarify with Paul what is being done here?
    date_specimen = as.Date(specdate),
    specimen_type = recode(specgroup,
                           blood = "Blood", csf = "CSF", sterile.fluid = "Sterile fluids", lower.resp = "Lower respiratory tract specimen",
                           pleural.fluid = "Pleural fluid", throat = "Throat swab", urine = "Urine", gu = "Genito-urinary swab", stool = "Stool",
                           other = "Other specimens"),
    isolate_id = paste0(specid, orgnum.acorn), # as.character(md5(paste0(specid, orgnum.acorn))),
    orgnum = orgnum.acorn,
    organism = orgname,
    organism_local = org.local,
    organism_whonet = org.whonet,
    ast_group = ast.group)