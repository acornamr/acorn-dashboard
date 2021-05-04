message("Generate an Enrolment Log")

enrolment_log <- redcap_dta() %>%
  select('ID number' = recordid, 
         'Date of enrolment' = hpd_dmdtc, 
         'Date of admission' = hpd_adm_date, 
         'Primary admission reason' = hpd_admreason,
         
         'Infection Episode' = group,
         'Date of episode enrolment' = ho_dmdtc, 
         'Discharge status' = ho_dischargestatus,
         'Discharge date' = ho_discharge_date, 
         
         'Actual Day-28 date' = d28_date, 
         'Day-28 status' = d28_status) %>%
  mutate('Expected Day-28 date' = `Date of enrolment` + 28)

# Create an enrolment log for clinical staff ----
enrol.log <- clin %>% select('ID number' = USUBJID, 'Enrol date' = DMDTC, 'Syndrome' = IFD_SURDIAG,
                             'Admission date' = HPD_ADM_DATE, 'Discharge date' = HO_DISCHARGE_DATE, 
                             'Discharge status' = HO_DISCHARGESTATUS, 'Actual Day-28 date' = D28_DATE, 
                             'Day-28 status' = D28_STATUS) %>%
  mutate(calc.d28 = as.Date(`Enrol date` + 28), # Calculate an expected D28 follow-up date for each enrolment
         id = paste(`ID number`, `Admission date`, sep="-"))  %>%   # Make a person-admission grouping variable
  group_by(id) %>% 
  mutate(`Predicted Day-28 date` = max(calc.d28), # Calculate the "final" (i.e. latest) D28 follow-up date for each admission
         `Episode number` = seq_along(`Enrol date`)) %>%  # Make an episode number (For each enrolment in an admission)
  ungroup() %>%
  arrange(`ID number`, `Admission date`, `Enrol date`) %>% # Sort by ID, admission date, and enrolment date
  select(`ID number`, `Episode number`, `Enrol date`, `Syndrome`, `Admission date`, `Discharge date`, `Discharge status`, 
         `Predicted Day-28 date`, `Actual Day-28 date`, `Day-28 status`)


# Make anonymised patient ID (ACORN + site + sequential number based on hospital ID)
clin <- transform(clin, ACORN.ANONID=as.numeric(factor(clin$USUBJID)))
clin$ACORN.ANONID <- paste("ACORN", clin$SITEID, clin$ACORN.ANONID, sep = "-")


# Make an episode ID (ACORN>ANONID + DMDTC), to link specimen to a specific episode
clin$ACORN.EPID <- paste(clin$ACORN.ANONID, clin$DMDTC, sep = "-")


# Remove date of birth from clinical data.frame (make a single calculated age in days variable (combining cases with a dob and those with only an age))
clin$AGE_D <- as.numeric(clin$DMDTC - clin$BRTHDTC)
clin$AGED[is.na(clin$AGED) & is.na(clin$BRTHDTC)] <- 0
clin$AGEM[is.na(clin$AGEM) & is.na(clin$BRTHDTC)] <- 0
clin$AGEY[is.na(clin$AGEY) & is.na(clin$BRTHDTC)] <- 0
clin$AGE_D[is.na(clin$BRTHDTC)] <- ceiling((clin$AGED[is.na(clin$BRTHDTC)]) + (clin$AGEM[is.na(clin$BRTHDTC)] * 30.4375) + (clin$AGEY[is.na(clin$BRTHDTC)] * 365.25))
clin$AGED <- clin$AGE_D # to replace in the original location: this is age in days at date of enrolment
clin$AGEY <- clin$AGED/365.25 # to make a calculated age in years based on AGED: this is age in years at date of enrolment
clin <- clin %>% select(-"BRTHDTC", -"AGE_D", -"AGEM")