output$table_enrolment_log <- renderDT({
  req(redcap_dta())
  req(enrolment_log())
  
  datatable(enrolment_log(), 
            escape = FALSE, selection = "single", rownames = FALSE, 
            options = list(pageLength = 5, scrollX = TRUE)
  )
})