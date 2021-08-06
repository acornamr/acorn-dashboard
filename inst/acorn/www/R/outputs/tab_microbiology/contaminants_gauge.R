output$contaminants_gauge <- renderGauge({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter()
  })
    
  n <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    filter(specgroup == "Blood", contaminant != "No") %>%
    nrow()
  
  total <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    filter(specgroup == "Blood") %>%
    nrow()
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})
