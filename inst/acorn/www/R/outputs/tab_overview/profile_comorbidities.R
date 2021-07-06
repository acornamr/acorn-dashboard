output$profile_comorbidities <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  if(! input$comorbidities_combinations) return({
    tibble(
      symptom = c("AIDS", "Cancer / leukaemia", "Chronic pulmonary disease", "Congestive heart failure", 
                  "Connective tissue / rheumatologic disease", "Dementia", "Diabetes", "Diabetes with end organ damage",
                  "Hemi- or paraplegia", "HIV on ART", "HIV without ART", "Malaria", "Malnutrition", "Metastatic solid tumour",
                  "Mild liver disease", "Moderate or severe liver disease", "Peptic ulcer", "Renal disease", "Tuberculosis"),
      patients = map_int(redcap_f01f05_dta_filter() %>% select(cmb_aids:cmb_tub), ~ sum(!is.na(.)))) %>%
      arrange(desc(patients)) %>%
      filter(patients >= 1) %>%
      hchart(type = "bar", hcaes(x = "symptom", y = "patients")) %>%
      hc_yAxis(title = "") %>% hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.patients} patients with {point.symptom}") %>%
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
  
  if(input$comorbidities_combinations) return({
    redcap_f01f05_dta_filter() %>% 
      count(comorbidities) %>% 
      filter(comorbidities != "") %>%
      arrange(desc(n)) %>%
      hchart(type = "bar", hcaes(x = "comorbidities", y = "n")) %>%
      hc_yAxis(title = "") %>% hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.n} patients with {point.comorbidities}") %>%
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
})
