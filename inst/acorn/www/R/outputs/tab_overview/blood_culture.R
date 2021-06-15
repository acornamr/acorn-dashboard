output$profile_blood_culture_gauge <- renderGauge({
  req(microbio())
  req(redcap_f01f05_dta_filter())
  
  n_blood_culture <- acorn_dta_filter() %>%
    fun_filter_blood_only() %>%
    group_by(episode_id) %>%
    slice(1) %>%
    nrow()
  
  total <- redcap_f01f05_dta_filter() %>% nrow()
  
  gauge(n_blood_culture, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#e31a1c"))
})

output$profile_blood_culture_pct <- renderText({
  req(microbio())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n_blood_culture <- acorn_dta_filter() %>%
    fun_filter_blood_only() %>%
    group_by(episode_id) %>%
    slice(1) %>%
    nrow()
  
  total <- redcap_f01f05_dta_filter() %>% nrow()
  
  paste(br(),br(), h4(paste0(round(100*n_blood_culture/total, 1), "%")), span("of patients with blood culture."))
})