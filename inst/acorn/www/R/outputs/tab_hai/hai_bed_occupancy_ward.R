output$bed_occupancy_ward_title <- renderText({
  req(input$filter_type_ward)
  req(redcap_hai_dta_filter())
  req(nrow(redcap_hai_dta_filter() > 0))
  
  return(paste0(br(), p("All ", paste0(input$filter_type_ward, collapse = " & "), 
                        " wards. Use filters to narrow by date range, type of ward or ward.")))
})

output$bed_occupancy_ward <- renderPlot({
  req(input$filter_type_ward)
  req(redcap_hai_dta_filter())
  req(nrow(redcap_hai_dta_filter() > 0))
  
  dta <- redcap_hai_dta_filter() %>%
    mutate(occupancy = round(100*ward_patients / ward_beds)) %>%
    select(-ward) %>%
    rename(date_enrolment = date_survey, ward = ward_type)

  ggplot(dta, aes(x = date_enrolment, y = occupancy, group = date_enrolment)) +
    geom_boxplot() +
    lims(y = c(0, 100)) +
    labs(title = "Occupancy rate per type of ward", x = "Date Survey", y = "Occupancy") +
    facet_wrap(~ward) +
    theme_light(base_size = 15)
})