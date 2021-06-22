output$hai_rate_ward <- renderPlot({
  req(input$filter_ward_type)
  req(redcap_hai_dta_filter())
  req(nrow(redcap_hai_dta_filter() > 0))
  
  left_join(
    redcap_hai_dta_filter() %>%
      mutate(occupancy = round(100*ward_patients / ward_beds)) %>%
      rename(date_enrolment = survey_date) %>%
      group_by(date_enrolment, ward_type) %>%
      summarise(total_patients = sum(ward_patients), .groups = "drop") %>%
      complete(ward_type, date_enrolment, fill = list(total_patients = 9999999999)),
    redcap_f01f05_dta() %>%
      filter(surveillance_category == "HAI") %>%
      group_by(date_enrolment, ward_type) %>%
      summarise(hai_patients = n(), .groups = "drop") %>%
      complete(ward_type, date_enrolment, fill = list(hai_patients = 0)),
    by = c("date_enrolment", "ward_type")) %>%
    mutate(infection_rate = round(100*hai_patients/total_patients, 1)) %>%
    filter(!is.na(infection_rate)) %>%
    ggplot(aes(x = date_enrolment, y = infection_rate)) +
    geom_line() + geom_point() +
    geom_hline(yintercept = 5, col = "red", lty = 2) +
    lims(y = c(0, NA))  +
    labs(title = "HAI point prevalence by type of ward", x= "Date of enrolment/Survey", y = "Prevalence of HAI (% of total patients)") +
    facet_wrap(vars(ward_type)) +
    theme_light(base_size = 15)
})
