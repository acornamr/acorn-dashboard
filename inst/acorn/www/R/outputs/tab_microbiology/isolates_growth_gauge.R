output$isolates_growth_gauge <- renderGauge({
    req(acorn_dta_filter())
    req(nrow(acorn_dta_filter()) > 0)
  
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
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})
