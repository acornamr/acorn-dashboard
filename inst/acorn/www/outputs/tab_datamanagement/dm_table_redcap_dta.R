output$table_redcap_dta <- renderDT({
  req(redcap_dta())
  
  dta <- redcap_dta()[, 1:5]
  
  
  datatable(dta, 
            escape = FALSE, selection = "single", rownames = FALSE, 
            options = list(pageLength = 5)
  )
})