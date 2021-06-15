output$hai_rate_ward <- renderPlot({
  req(input$filter_type_ward)
  req(hai_surveys_filter())
  req(nrow(hai_surveys_filter() > 0))
  
  dta <- left_join(
    hai_surveys_filter() %>%
      mutate(beds = as.numeric(beds),
             patients = as.numeric(patients)) %>%
      mutate(occupancy = round(100*patients / beds)) %>%
      select(-ward) %>%
      rename(date_enrolment = date_survey, ward = ward_type) %>%
      group_by(date_enrolment, ward) %>%
      summarise(total_patients = sum(patients), .groups = "drop") %>%
      complete(ward, date_enrolment, fill = list(total_patients = 9999999999)),
    redcap_f01f05_dta() %>%
      filter(surveillance_cat == "HAI") %>%
      group_by(date_enrolment, ward) %>%
      summarise(hai_patients = n(), .groups = "drop") %>%
      complete(ward, date_enrolment, fill = list(hai_patients = 0)),
    by = c("date_enrolment", "ward")) %>%
    mutate(infection_rate = round(100*hai_patients/total_patients, 1))
  
  
  ggplot(dta, aes(x = date_enrolment, y = infection_rate)) +
    geom_line() + geom_point() +
    geom_hline(yintercept = 5, col = "red", lty = 2) +
    lims(y = c(0, NA))  +
    labs(title = "HAI point prevalence by type of ward", x= "Date of enrolment/Survey", y = "Prevalence of HAI (% of total patients)") +
    facet_wrap(~ward) +
    theme_light(base_size = 15)
})
