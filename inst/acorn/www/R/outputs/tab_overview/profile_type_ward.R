output$profile_type_ward <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  

  if(input$show_ward_breakdown) return({
    df <- redcap_f01f05_dta_filter() %>%
      group_by(ward) %>%
      summarise(patients = n(), .groups = "drop") %>%
      arrange(desc(patients))
    
    hchart(df, type = "bar", hcaes(x = "ward", y = "patients")) %>%
      hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
      hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.patients} patients in {point.ward}.") %>%
      
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
  
  if(! input$show_ward_breakdown) return({
    df <- redcap_f01f05_dta_filter() %>%
      group_by(ward_type) %>%
      summarise(patients = n(), .groups = "drop") %>%
      arrange(desc(patients))
    
    hchart(df, type = "bar", hcaes(x = "ward_type", y = "patients")) %>%
      hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
      hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.patients} patients in {point.ward_type}.") %>%
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
})