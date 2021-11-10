updateCheckboxGroupButtons(session, "filter_enrolments",
                           choices = c("Surveillance Category", "Type of Ward", "Date of Enrolment/Survey", "Age Category", 
                                       "Initial Diagnosis", "Final Diagnosis", "Clinical Severity", "uCCI", "Clinical/D28 Outcome",
                                       "Transfer"),
                           selected = NULL,
                           status = "light", size = "sm",
                           checkIcon = list(yes = icon("filter")))