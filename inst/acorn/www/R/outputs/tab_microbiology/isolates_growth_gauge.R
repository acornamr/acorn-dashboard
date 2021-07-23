output$isolates_growth_gauge <- renderGauge({
    req(acorn_dta_filter())
    req(nrow(acorn_dta_filter()) > 0)
    
    ifelse(input$filter_rm_contaminant, {
      dta <- acorn_dta_filter() %>% 
        replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
    }, 
    {
      dta <- acorn_dta_filter() 
    })
  
  n <- dta %>%
    fun_filter_growth_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  total <- dta %>%
    fun_filter_cultured_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})
