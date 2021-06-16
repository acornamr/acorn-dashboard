output$table_enrolment_log <- renderDT({
  req(redcap_f01f05_dta())
  req(enrolment_log())
  
  datatable(enrolment_log(), 
            escape = FALSE, selection = "single", rownames = FALSE, 
            options = list(scrollX = TRUE, scrollY = 300, paging = FALSE, dom = "lrtip")
  )
})