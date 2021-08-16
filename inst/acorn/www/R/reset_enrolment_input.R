updateCheckboxGroupButtons(session, "filter_enrolments",
                           choices = c("Surveillance Category", "Type of Ward", "Date of Enrolment/Survey", "Age Category", 
                                       "Initial Diagnosis", "Final Diagnosis", "Clinical Severity", "Clinical/D28 Outcome"),
                           selected = NULL,
                           status = "light", size = "sm",
                           checkIcon = list(yes = icon("filter")))


# Surveillance Category
updatePrettyCheckboxGroup(session, "filter_surveillance_cat", NULL, choiceNames = c("Community Acquired Infection", "Hospital Acquired Infection"),
                          choiceValues = c("CAI", "HAI"),
                          selected = c("CAI", "HAI"), inline = TRUE)

# Type of Ward
updatePickerInput(session, "filter_ward_type",
                  choices =  sort(unique(redcap_f01f05_dta()$ward_type)),
                  selected = sort(unique(redcap_f01f05_dta()$ward_type)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ward_type)) - 1),
                                 `count-selected-text` = "All Type of Wards"))

# Date of Enrolment/Survey
updateDateRangeInput(session, "filter_date_enrolment",
                     start = min(redcap_f01f05_dta()$date_episode_enrolment),
                     end = max(redcap_f01f05_dta()$date_episode_enrolment))

# Age Category
updatePrettyCheckboxGroup(session, "filter_age_cat", NULL,  choices = c("Adult", "Child", "Neonate"), 
                          selected = c("Adult", "Child", "Neonate"), inline = TRUE)

# Initial Diagnosis
updatePickerInput(session, "filter_diagnosis_initial",
                  choices =  sort(unique(redcap_f01f05_dta()$surveillance_diag)),
                  selected = sort(unique(redcap_f01f05_dta()$surveillance_diag)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$surveillance_diag)) - 1),
                                 `count-selected-text` = "All Initial Diagnosis"))

# Final Diagnosis
updatePickerInput(session, "filter_diagnosis_final",
                  choices =  sort(unique(redcap_f01f05_dta()$ho_final_diag)),
                  selected = sort(unique(redcap_f01f05_dta()$ho_final_diag)),
                  options = list(status = "primary",
                                 `selected-text-format` = paste0("count > ", length(unique(redcap_f01f05_dta()$ho_final_diag)) - 1),
                                 `count-selected-text` = "All Final Diagnosis"))

# Clinical Severity
updateSliderInput(session, "filter_severity_adult", "Adult qSOFA score", min = 0, max = 3, value = c(0, 3))
updatePrettySwitch(session, "filter_severity_child_0", label = "Include Child/Neonate with 0 severity criteria", value = TRUE)
updatePrettySwitch(session, "filter_severity_child_1", label = "Include Child/Neonate with ≥ 1 severity criteria", value = TRUE)

# Clinical/D28 Outcome
updatePrettySwitch(session, "filter_outcome_clinical", label = "Only with Clinical Outcome", value = FALSE)
updatePrettySwitch(session, "filter_outcome_d28", label = "Only with Day-28 Outcome", value = FALSE)
