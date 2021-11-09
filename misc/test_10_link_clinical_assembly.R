# Mock data to check the detection of case B/C in 10_link_clinical_assembly.R
# Created before the split of CAI into CAI and HCAI

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