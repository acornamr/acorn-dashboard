message("10_checklist_lab.R")

if(format_data_dic == "TABULAR") {
  if(c("patid", "specid", "specdate", "spectype.local") %in% names(amr_acorn_relevant) %>% all()) {
    checklist_status$lab_data_qc_1 <- list(status = "okay", msg = i18n$t("Lab dataset contains the minimal columns."))
  }
  else{
    checklist_status$lab_data_qc_1 <- list(status = "ko", msg = i18n$t("Lab dataset does not contains the minimal columns."))
  }
}

if(format_data_dic == "WHONET") {
  if(c("patid", "specid", "specdate", "spectype.whonet") %in% names(amr_acorn_relevant) %>% all()) {
    checklist_status$lab_data_qc_1 <- list(status = "okay", msg = i18n$t("Lab dataset contains the minimal columns."))
  }
  else{
    checklist_status$lab_data_qc_1 <- list(status = "ko", msg = i18n$t("Lab dataset does not contains the minimal columns."))
  }
}

if(all(!is.na(amr_acorn_relevant$patid))) {
  checklist_status$lab_data_qc_2 <- list(status = "okay", msg = i18n$t("All 'patid' are provided."))
} else {
  checklist_status$lab_data_qc_2 <- list(status = "warning", msg = i18n$t("There are rows with missing 'patid'."))
}

if(all(!stringr::str_detect(amr_acorn_relevant$specid, "^SPEC"))) {
  checklist_status$lab_data_qc_3 <- list(status = "okay", msg = i18n$t("All 'specid' are provided."))
} else{
  checklist_status$lab_data_qc_3 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specid'."))
}

if(all(!is.na(amr_acorn_relevant$specdate))) {
  checklist_status$lab_data_qc_4 <- list(status = "okay", msg = i18n$t("All 'specdate' are provided."))
} else {
  checklist_status$lab_data_qc_4 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specdate'."))
}

if(all(amr_acorn_relevant$specdate <= Sys.Date(), na.rm = TRUE)) {
  checklist_status$lab_data_qc_5 <- list(status = "okay", msg = i18n$t("All 'specdate' are today or before today."))
} else {
  checklist_status$lab_data_qc_5 <- list(status = "warning", msg = i18n$t("There are rows for which 'specdate' are after today."))
}

if(all(!is.na(amr_acorn_relevant$specgroup))) {
  checklist_status$lab_data_qc_6 <- list(status = "okay", msg = i18n$t("All 'specgroup' are provided."))
} else {
  checklist_status$lab_data_qc_6 <- list(status = "warning", msg = i18n$t("There are rows with missing 'specgroup'."))
}

if(all(!is.na(amr_acorn_relevant$orgname))) {
  checklist_status$lab_data_qc_7 <- list(status = "okay", msg = i18n$t("All 'orgname' are provided."))
} else {
  checklist_status$lab_data_qc_7 <- list(status = "warning", msg = i18n$t("There are rows with missing 'orgname'."))
}

if(lab_log$missing_ast |> nrow() == 0) {
  checklist_status$lab_data_qc_8 <- list(status = "okay", msg = i18n$t("There is not missing data for key organism – antibiotic susceptibility test combinations."))
} else {
  checklist_status$lab_data_qc_8 <- list(status = "warning", msg = i18n$t("There is missing data for key organism – antibiotic susceptibility test combinations."))
}


if(lab_log$intrinsic_resistance |> nrow() == 0) {
  checklist_status$lab_data_qc_9 <- list(status = "okay", msg = i18n$t("There are not intrinsic resistance warnings to review."))
} else {
  checklist_status$lab_data_qc_9 <- list(status = "warning", msg = i18n$t("There are intrinsic resistance warnings to review."))
}

if(lab_log$unusual_ast |> nrow() == 0) {
  checklist_status$lab_data_qc_10 <- list(status = "okay", msg = i18n$t("There are not unusual antibiotic resistance phenotype warnings to review."))
} else {
  checklist_status$lab_data_qc_10 <- list(status = "warning", msg = i18n$t("There are unusual antibiotic resistance phenotype warnings to review."))
}

checklist_status$lab_dta = list(status = "okay", msg = i18n$t("Lab data successfully provided."))