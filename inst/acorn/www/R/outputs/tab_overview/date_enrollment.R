output$profile_date_enrolment <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  
  if(input$show_date_week) return({
  df <- redcap_f01f05_dta_filter() %>%
    mutate(date_enrolment = floor_date(date_enrolment, "week")) %>%
    group_by(date_enrolment) %>%
    count() %>%
    mutate(week = paste0(year(date_enrolment), " - Week ", week(date_enrolment)))
  
  hchart(df, "line", hcaes(x = date_enrolment, y = n)) %>%
    hc_yAxis(title = "") %>% hc_xAxis(title = "") %>%
    hc_colors("#969696") %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.week}: <br>{point.n} patients") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
  
  if(! input$show_date_week) return({
    df <- redcap_f01f05_dta_filter() %>%
      mutate(date_enrolment = floor_date(date_enrolment, "month")) %>%
      group_by(date_enrolment) %>%
      count() %>%
      mutate(month = paste0(year(date_enrolment), " ", month(date_enrolment)))
    
    hchart(df, "line", hcaes(x = date_enrolment, y = n)) %>%
      hc_yAxis(title = "") %>% hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "", pointFormat = "{point.month}: <br>{point.n} patients") %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
})