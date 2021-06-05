checklist_status$lab_data_qc_1 <- list(status = "okay", msg = glue("The Lab dataset contains {nrow(amr)} rows"))

if(format_data_dic == "TABULAR") {
  if(c("patid", "specid", "specdate", "spectype.local") %in% names(amr) %>% all()) {
    checklist_status$lab_data_qc_2 <- list(status = "okay", msg = "Lab dataset contains the minimal columns")
  }
  else{
    checklist_status$lab_data_qc_2 <- list(status = "ko", msg = "Lab dataset does not contains the minimal columns (TABULAR format: PATIENT_ID ; SPEC_NUM ; SPEC_DATE ; LOCAL_SPEC)")
  }
}

if(format_data_dic == "WHONET") {
  if(c("patid", "specid", "specdate", "spectype.whonet") %in% names(amr) %>% all()) {
    checklist_status$lab_data_qc_2 <- list(status = "okay", msg = "Lab dataset contains the minimal columns")
  }
  else{
    checklist_status$lab_data_qc_2 <- list(status = "ko", msg = "Lab dataset does not contains the minimal columns (WHONET format: PATIENT_ID ; SPEC_NUM ; SPEC_DATE ; SPEC_CODE)")
  }
}

if(all(!is.na(amr$patid))) {
  checklist_status$lab_data_qc_3 <- list(status = "okay", msg = "All patid are provided")
} else {
  checklist_status$lab_data_qc_3 <- list(status = "warning", msg = glue("Warning: there are {sum(is.na(amr$patid))} rows with missing patid."))
}

if(all(!is.na(amr$specid))) {
  checklist_status$lab_data_qc_4 <- list(status = "okay", msg = "All specid are provided")
} else{
  checklist_status$lab_data_qc_4 <- list(status = "warning", msg = glue("Warning: there are {sum(is.na(amr$specid))} rows with missing specid."))
}

if(all(!is.na(amr$specdate))) {
  checklist_status$lab_data_qc_5 <- list(status = "okay", msg = "All specdate are provided")
} else {
  checklist_status$lab_data_qc_5 <- list(status = "warning", msg = glue("Warning: there are {sum(is.na(amr$specdate))} rows with missing specdate."))
}

if(all(amr$specdate <= Sys.Date())) {
  checklist_status$lab_data_qc_6 <- list(status = "okay", msg = "All specdate are today or before today")
} else {
  checklist_status$lab_data_qc_6 <- list(status = "warning", msg = glue("Warning: there are {sum(amr$specdate > Sys.Date())} specdate that are after today."))
}

if(all(!is.na(amr$specgroup))) {
  checklist_status$lab_data_qc_7 <- list(status = "okay", msg = "All specgroup are provided")
} else {
  checklist_status$lab_data_qc_7 <- list(status = "warning", msg = glue("Warning: there are {sum(is.na(amr$specgroup))} rows with missing specgroup."))
}

if(all(!is.na(amr$orgname))) {
  checklist_status$lab_data_qc_8 <- list(status = "okay", msg = "All orgname are provided")
} else {
  checklist_status$lab_data_qc_8 <- list(status = "warning", msg = glue("Warning: there are {sum(is.na(amr$orgname))} rows with missing orgname."))
}

checklist_status$lab_dta = list(status = "okay", msg = "Lab data provided")