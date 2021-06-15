output$evolution_blood_culture <- renderHighchart({
  req(acorn_dta_filter())
  req(acorn_dta_filter() %>% nrow() > 0)
  
  dta <- left_join(
    redcap_f01f05_dta_filter() %>%
      group_by(month = floor_date(date_enrolment, "month")) %>%
      summarise(all = n_distinct(redcap_id), .groups = "drop"),  # Number of episodes per month of enrolment
    acorn_dta() %>%
      filter(specgroup == "Blood") %>%
      group_by(month = floor_date(date_enrolment, "month")) %>%
      summarise(blood = n_distinct(redcap_id), .groups = "drop"),  # Number of blood specimen per month of enrolment
    by = "month") %>%
    mutate(blood = replace_na(blood, 0)) %>%
    mutate(month = substr(as.character(month), 1, 7),
           percent = round(100 * blood/all, 1)) %>%
    filter(!is.na(month))
  
  hchart(dta, type = "column", hcaes(x = "month", y = "percent"), color = "#e74c3c") %>%
    hc_yAxis(title = list(text = "% with BC", rotation = 0), max = 100) %>% hc_xAxis(title = "Month of enrolment") %>% 
    hc_tooltip(pointFormat = "{point.percent}% of enrolments with BC<br> ({point.blood} of {point.all} enrolments)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})