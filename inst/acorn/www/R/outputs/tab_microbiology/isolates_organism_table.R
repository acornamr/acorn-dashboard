output$isolates_organism_table <- renderDT({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% 
      replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  dta <- dta %>%
    fun_filter_growth_only() %>%
    fun_filter_signifgrowth_only() %>%
    filter(orgname != "Mixed growth", orgname != "Not cultured") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(orgname) %>%
    summarise(N = n(), .groups = "drop") %>%
    mutate(Frequency = N / sum(N)) %>%
    rename(Organism = orgname) %>%
    arrange(desc(N))
  
  datatable(dta,
            rownames = FALSE,
            filter = "top",
            style = "bootstrap",
            options = list(scrollX = TRUE, scrollY = 300, paging = FALSE, dom = "lrtip")) %>%
    formatPercentage('Frequency', digits = 1)
})