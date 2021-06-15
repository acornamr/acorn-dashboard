output$nb_enrolments <- renderText({
  prop <- round(100 * redcap_f01f05_dta_filter() %>% nrow() / redcap_f01f05_dta() %>% nrow(), 1)
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", redcap_f01f05_dta_filter() %>% nrow()), 
        span(class = "smallcaps", "Patient enrolments"),
        span(class = "badge badge-light f-100 right", ifelse(prop < 100, glue("{prop}% of {redcap_f01f05_dta() %>% nrow()}"), ""))
    )
  )
})

output$nb_patients_microbiology <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "numb", "145"), 
        span(class = "smallcaps", "enrolments With Microbiology"),
        span(class = "badge badge-light f-100 right", "81% of 180")
    )
  )
})

output$nb_specimens <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "numb", "98"), 
        span(class = "smallcaps", "Specimens Collected"),
        span("1.43 per enrolment"),
        span(class = "badge badge-light f-100 right", "98% of 180")
    )
  )
})

output$nb_isolates <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "numb", "10"), 
        span(class = "smallcaps", "Isolates"),
        span("from cultures that have growth"),
        span(class = "badge badge-light f-100 right", "5 of Target Pathogens")
    )
  )
})
