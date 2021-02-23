output$box_rows_acorn_filt <- renderUI({
  req(acorn_dta_filter())
  n_row <- format(nrow(acorn_dta()), big.mark = ",")
  
  div(class = "card card-inverse card-primary",
      strong(span(class = "f-150", n_row),  "Elements"),
      p("In dataset.")
  )
})

output$box_rows_acorn_filt_dup <- renderUI({
  req(acorn_dta_filter())
  n_row <- format(nrow(acorn_dta_filter()), big.mark = ",")
  
  div(class = "card card-inverse card-warning",
      strong(span(class = "f-150", n_row),  "Elements"),
      p("In FILTERED dataset.")
  )
})

output$plot_date_admission <- renderPlot({
  req(acorn_dta_filter())
  
  dta <- acorn_dta_filter() %>% 
    group_by(date_admission) %>%
    summarise(nb_patients = n(), .groups = "drop")
  
  ggplot(dta, aes(x = date_admission, y = nb_patients)) +
    geom_col()
})