updatePickerInput(session, "filter_ward_name",
                  choices =  sort(unique(redcap_f01f05_dta()$ward)),
                  selected = sort(unique(redcap_f01f05_dta()$ward)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ward)) - 1),
                                 `count-selected-text` = "All Wards"))