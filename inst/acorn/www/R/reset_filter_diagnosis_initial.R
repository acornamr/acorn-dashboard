updatePickerInput(session, "filter_diagnosis_initial",
                  choices =  sort(unique(redcap_f01f05_dta()$surveillance_diag)),
                  selected = sort(unique(redcap_f01f05_dta()$surveillance_diag)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$surveillance_diag)) - 1),
                                 `count-selected-text` = "All Initial Diagnosis"))