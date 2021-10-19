output$isolates_growth_gauge <- flexdashboard::renderflexdashboard::gauge({
    req(acorn_dta_filter())
    req(nrow(acorn_dta_filter()) > 0)

    ifelse(input$filter_rm_contaminant, 
           dta <- acorn_dta_filter() %>% filter(contaminant == "No"),
           dta <- acorn_dta_filter() 
    )
  
  n <- dta %>%
    fun_filter_cultured_only() %>%
    fun_filter_growth_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% n_distinct()
  
  total <- dta %>%
    fun_filter_cultured_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% n_distinct()
  
  flexdashboard::gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})
