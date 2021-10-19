output$profile_blood_culture_gauge <- flexdashboard::renderflexdashboard::gauge({
  req(acorn_dta_filter())
  req(redcap_f01f05_dta_filter())
  
  n_blood_culture <- acorn_dta_filter() %>%
    fun_filter_blood_only() %>%
    pull(redcap_id) %>%
    n_distinct()
  
  total <- redcap_f01f05_dta_filter() %>% 
    pull(redcap_id) %>%
    n_distinct()
  
  flexdashboard::gauge(n_blood_culture, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#e31a1c"))
})

output$profile_blood_culture_pct <- renderText({
  req(acorn_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n_blood_culture <- acorn_dta_filter() %>%
    fun_filter_blood_only() %>%
    pull(redcap_id) %>%
    n_distinct()
  
  total <- redcap_f01f05_dta_filter()  %>%
    pull(redcap_id) %>%
    n_distinct()
  
  paste(br(), h3(paste0(round(100*n_blood_culture/total, 1), "%")), span(i18n$t("of enrolments with blood culture.")))
})