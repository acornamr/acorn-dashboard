updatePickerInput(session, "filter_method_other", 
                  choices =  sort(setdiff(unique(acorn_dta()$specgroup), "Blood")), 
                  selected = sort(setdiff(unique(acorn_dta()$specgroup), "Blood")),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(setdiff(unique(acorn_dta()$specgroup), "Blood")) - 1), 
                                 `count-selected-text` = "All Other Specimens"))

# important to use redcap_f01f05_dta below for all filters that are used on redcap_f01f05_dta 
# as the enrolments without a specimen are removed from acorn_dta
updatePickerInput(session, "filter_ward_type", 
                  choices =  sort(unique(redcap_f01f05_dta()$ward_type)), 
                  selected = sort(unique(redcap_f01f05_dta()$ward_type)), 
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ward_type)) - 1), 
                                 `count-selected-text` = "All Type of Wards"))

updateDateRangeInput(session, "filter_date_enrolment", 
                     start = min(redcap_f01f05_dta()$date_episode_enrolment), 
                     end = max(redcap_f01f05_dta()$date_episode_enrolment))

updatePickerInput(session, "filter_diagnosis_initial", 
                  choices =  sort(unique(redcap_f01f05_dta()$surveillance_diag)), 
                  selected = sort(unique(redcap_f01f05_dta()$surveillance_diag)), 
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$surveillance_diag)) - 1), 
                                 `count-selected-text` = "All Initial Diagnosis"))

updatePickerInput(session, "filter_diagnosis_final", 
                  choices =  sort(unique(redcap_f01f05_dta()$ho_final_diag)), 
                  selected = sort(unique(redcap_f01f05_dta()$ho_final_diag)), 
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ho_final_diag)) - 1), 
                                 `count-selected-text` = "All Final Diagnosis"))


all_organism <- unique(acorn_dta()$orgname)
other_organism_vec <- setdiff(all_organism, 
                              union(c("Acinetobacter baumannii", "Escherichia coli", "Klebsiella pneumoniae", "Staphylococcus aureus",
                                      "Streptococcus pneumoniae", "Neisseria gonorrhoeae"),
                                    c(str_subset(all_organism, "rowth"),
                                      str_subset(all_organism, "ultured"),
                                      str_subset(all_organism, "almonella"))))
updateSelectInput(session = session, "other_organism",
                  choices = other_organism_vec)