updateDateRangeInput(session, "filter_date_enrolment",
                     start = min(redcap_f01f05_dta()$date_episode_enrolment, na.rm = TRUE),
                     end = max(redcap_f01f05_dta()$date_episode_enrolment, na.rm = TRUE))
