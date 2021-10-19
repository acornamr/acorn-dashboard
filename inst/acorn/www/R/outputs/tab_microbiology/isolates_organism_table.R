output$isolates_organism_table <- DT::renderDT({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  dta <- dta %>%
    fun_filter_growth_only() %>%
    fun_filter_signifgrowth_only() %>%
    filter(orgname != "Mixed growth", orgname != "Not cultured") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(orgname, contaminant) %>%
    summarise(N = n(), .groups = "drop") %>%
    mutate(Frequency = N / sum(N)) %>%
    rename(Organism = orgname, Contaminant = contaminant) %>%
    arrange(desc(N))
  
  DT::datatable(dta,
            rownames = FALSE,
            filter = "top",
            style = "bootstrap",
            options = list(scrollX = TRUE, scrollY = 300, paging = FALSE, dom = "lrtip")) %>%
    DT::formatPercentage('Frequency', digits = 1)
})