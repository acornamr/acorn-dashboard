output$profile_antibiotics <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)

redcap_f01f05_dta_filter() %>% 
  select(antibiotic_j01gb06:antibiotic_other_text) %>%
  pivot_longer(antibiotic_j01gb06:antibiotic_other_text, names_to = "antibiotic_code", values_to = "antibiotic") %>%
  filter(antibiotic != "") %>%
  count(antibiotic) %>%
  arrange(desc(n)) %>%
hchart(type = "bar", hcaes(x = "antibiotic", y = "n")) %>%
  hc_yAxis(title = "") %>% hc_xAxis(title = "") %>%
  hc_colors("#a6cee3") %>%
  hc_tooltip(headerFormat = "",
             pointFormat = "{point.n} patients have taken {point.antibiotic}") %>%
  hc_plotOptions(series = list(stacking = 'normal')) %>%
  hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
