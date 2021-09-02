message("09_checklist_lab.R")

if(format_data_dic == "TABULAR") {
  if(c("patid", "specid", "specdate", "spectype.local") %in% names(amr) %>% all()) {
    checklist_status$lab_data_qc_1 <- list(status = "okay", msg = i18n$t("Lab dataset contains the minimal columns."))
  }
  else{
    checklist_status$lab_data_qc_1 <- list(status = "ko", msg = i18n$t("Lab dataset does not contains the minimal columns."))
  }
}

if(format_data_dic == "WHONET") {
  if(c("patid", "specid", "specdate", "spectype.whonet") %in% names(amr) %>% all()) {
    checklist_status$lab_data_qc_1 <- list(status = "okay", msg = i18n$t("Lab dataset contains the minimal columns."))
  }
  else{
    checklist_status$lab_data_qc_1 <- list(status = "ko", msg = i18n$t("Lab dataset does not contains the minimal columns."))
  }
}

if(all(!is.na(amr$patid))) {
  checklist_status$lab_data_qc_2 <- list(status = "okay", msg = i18n$t("All 'patid' are provided."))
} else {
  checklist_status$lab_data_qc_2 <- list(status = "warning", msg = i18n$t("There are rows with missing 'patid'."))
}

if(all(!is.na(amr$specid))) {
  checklist_status$lab_data_qc_3 <- list(status = "okay", msg = i18n$t("All 'specid' are provided."))
} else{
  checklist_status$lab_data_qc_3 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specid'."))
}

if(all(!is.na(amr$specdate))) {
  checklist_status$lab_data_qc_4 <- list(status = "okay", msg = i18n$t("All 'specdate' are provided."))
} else {
  checklist_status$lab_data_qc_4 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specdate'."))
}

if(all(amr$specdate <= Sys.Date())) {
  checklist_status$lab_data_qc_5 <- list(status = "okay", msg = i18n$t("All 'specdate' are today or before today."))
} else {
  checklist_status$lab_data_qc_5 <- list(status = "warning", msg = i18n$t("There are rows for which 'specdate' are after today."))
}

if(all(!is.na(amr$specgroup))) {
  checklist_status$lab_data_qc_6 <- list(status = "okay", msg = i18n$t("All 'specgroup' are provided."))
} else {
  checklist_status$lab_data_qc_6 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specgroup'."))
}

if(all(!is.na(amr$orgname))) {
  checklist_status$lab_data_qc_7 <- list(status = "okay", msg = i18n$t("All 'orgname' are provided."))
} else {
  checklist_status$lab_data_qc_7 <- list(status = "warning", msg = i18n$t("There are rows with missing 'orgname'."))
}

checklist_status$lab_dta = list(status = "okay", msg = i18n$t("Lab data successfully provided."))