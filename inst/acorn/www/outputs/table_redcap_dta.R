output$table_redcap_dta <- renderDT({
  req(redcap_dta())
  
  datatable(redcap_dta(), escape = FALSE, selection = "single", rownames = FALSE)
})