updatePickerInput(session, "filter_diagnosis_final",
                  choices =  sort(unique(redcap_f01f05_dta()$ho_final_diag)),
                  selected = sort(unique(redcap_f01f05_dta()$ho_final_diag)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ho_final_diag)) - 1),
                                 `count-selected-text` = "All Final Diagnosis"))