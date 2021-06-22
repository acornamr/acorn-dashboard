output$bed_occupancy_ward <- renderPlot({
  req(input$filter_ward_type)
  req(redcap_hai_dta_filter())
  req(nrow(redcap_hai_dta_filter() > 0))
  
  redcap_hai_dta_filter() %>% 
    mutate(survey_month = floor_date(survey_date, "month")) %>%
    mutate(occupancy = round(100 * ward_patients / ward_beds)) %>%
  ggplot(aes(x = survey_month, y = occupancy, group = survey_month)) +
    geom_boxplot() +
    lims(y = c(0, 100)) +
    labs(title = "Occupancy rate per type of ward per month", x = "Date of Survey", y = "Occupancy (%)") +
    facet_wrap(vars(ward_type)) +
    theme_light(base_size = 15)
})