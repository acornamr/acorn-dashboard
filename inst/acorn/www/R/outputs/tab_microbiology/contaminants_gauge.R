output$contaminants_gauge <- renderGauge({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, 
         dta <- acorn_dta_filter() %>% filter(contaminant == "No"),
         dta <- acorn_dta_filter()
  )
  
  n <- dta %>%
    filter(specgroup == "Blood") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    filter(all(contaminant != "No")) %>%
    ungroup() %>%
    pull(specid) %>% n_distinct()
  
  total <- dta %>%
    filter(specgroup == "Blood") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% n_distinct()
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})
