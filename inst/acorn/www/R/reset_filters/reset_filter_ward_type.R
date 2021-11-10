updatePickerInput(session, "filter_ward_type",
                  choices =  sort(unique(redcap_f01f05_dta()$ward_type)),
                  selected = sort(unique(redcap_f01f05_dta()$ward_type)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ward_type)) - 1),
                                 `count-selected-text` = "All Type of Wards"))