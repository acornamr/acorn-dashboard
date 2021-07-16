output$isolates_growth_pct <- renderText({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n <- acorn_dta_filter() %>%
    fun_filter_growth_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  total <- acorn_dta_filter() %>%
    fun_filter_cultured_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  paste(br(), br(), h4(paste0(round(100 * n / total, 1), "%")), span("of cultures have growth."))
})