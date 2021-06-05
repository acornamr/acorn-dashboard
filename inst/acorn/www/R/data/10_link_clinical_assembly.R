browser()

test <- TRUE
if(test) {
  clin <- tribble(
    ~patient_id, ~surveillance_category, ~date_admission, ~hai_date_symptom_onset,
    "Paul",      "HAI",                  NA,              "2021-03-01",
    "Paul",      "CAI",                  "2021-04-01",    NA,
    "Liz",       "CAI",                  "2021-04-01",    NA,
    "Olivier",   "CAI",                  "2021-01-01",    NA,
    "Olivier",   "HAI",                  NA,              "2021-01-04"
  ) %>%
    mutate(date_admission = as.Date(date_admission),
           hai_date_symptom_onset = as.Date(hai_date_symptom_onset))
  
  lab <- tribble(
    ~patid, ~specdate,    ~isolate,
    "Paul", "2021-02-28", "orange hipo",     # removed: specimen date before hai_date_symptom_onset
    "Paul", "2021-03-02", "blue camel",      # kept
    "Paul", "2021-03-02", "purple cat",      # kept
    "Paul", "2021-04-01", "red squirrel",    # kept
    "Paul", "2021-04-06", "white elephant",  # removed: no date to match
    "Liz",  "2021-03-31", "yellow bird",     # kept
    "Liz",  "2021-04-01", "black rat",       # kept
    "Ong",  "2021-03-01", "green horse"      # removed: no matching patient in clin
  ) %>%
    mutate(specdate = as.Date(specdate))
} else {
  lab <- lab_dta()      # one row per isolate
  clin <- redcap_dta()  # one row per infection
}


# remove case B
clin %>% 
  mutate(date_cai_hai = case_when(
    surveillance_category == "HAI" ~ hai_date_symptom_onset,
    surveillance_category == "CAI" ~ date_admission)) %>%
  group_by(patient_id) %>%
  filter(n() > 1) %>%
  arrange(date_cai_hai) %>%
  mutate(lag_days = date_cai_hai - lag(date_cai_hai)) %>%
  ungroup()

  # detect (B):
  # patients with a CAI at day D0 and a stated HAI onset of admission before D3
  lab %>%
  group_by(episode_id) %>%
  mutate(flag_case_B = any(hai_date_symptom_onset <= (date_admission + 3)))

message("")




# Make a data frame of CAI episodes
dta_cai <- clin %>%
  filter(surveillance_category == "CAI") %>%
  inner_join(lab, by = c("patient_id" = "patid")) %>%
  filter(specdate >= (date_admission - 2),
         specdate <= (date_admission + 2))


# Make a data frame of HAI episodes
dta_hai <- clin %>%
  filter(surveillance_category == "HAI") %>%
  inner_join(lab, by = c("patient_id" = "patid")) %>%
  filter(specdate >= hai_date_symptom_onset,
         specdate <= (hai_date_symptom_onset + 2))

acorn_dta <- bind_rows(dta_cai, dta_hai)






# TODO: anonymise with md5()
# TODO: rename acorn_dta?
# careful that the acorn id WILL be duplicated between the sites
# acorn id should be non hashed / patient id should be hashed / we should be able to get back the specimen id
acorn_dta <- lab %>%
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