output$nb_enrolments <- renderText({
  req(acorn_dta())
  nb_enrolments <-  n_distinct(redcap_f01f05_dta()$redcap_id)
  nb_enrolments_filter <- n_distinct(redcap_f01f05_dta_filter()$redcap_id)
  
  prop <- round(100 * nb_enrolments_filter / nb_enrolments, 1)
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", nb_enrolments_filter), 
        span(class = "smallcaps", i18n$t("Patient enrolments")),
        span(class = "badge badge-light f-100 right", ifelse(prop < 100, glue("{prop}% of {nb_enrolments} total"), ""))
    )
  )
})

output$nb_patients_microbiology <- renderText({
  req(acorn_dta())
  nb_enrolments_filter <- n_distinct(redcap_f01f05_dta_filter()$redcap_id)
  nb_microbiology_filter <- n_distinct(acorn_dta_filter()$redcap_id)
  
  prop <- round(100 * nb_microbiology_filter / nb_enrolments_filter, 1)
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", nb_microbiology_filter), 
        span(class = "smallcaps", i18n$t("With Microbiology")),
        span(class = "badge badge-light f-100 right", glue("{prop}% of {nb_enrolments_filter}"))
    )
  )
})

output$nb_specimens <- renderText({
  req(acorn_dta())
  
  nb_specimens <- n_distinct(acorn_dta_filter()$specid)
  nb_enrolments_filter <- n_distinct(redcap_f01f05_dta_filter()$redcap_id)
  nb_per <- round(nb_specimens / nb_enrolments_filter, 1)
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", nb_specimens), 
        span(class = "smallcaps", i18n$t("Specimens Collected")),
        span(class = "badge badge-light f-100 right", paste(nb_per, i18n$t("specimens per enrolment")))
    )
  )
})

output$nb_isolates_growth <- renderText({
  req(acorn_dta())
  nb_isolates <- acorn_dta_filter() %>% 
    fun_filter_growth_only() %>% 
    fun_deduplication(method = input$deduplication_method) %>% 
    pull(isolateid) %>% 
    n_distinct()
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", nb_isolates), 
        span(class = "smallcaps", i18n$t("Isolates")),
        span(i18n$t("from cultures that have growth"))
    )
  )
})

output$nb_isolates_target <- renderText({
  req(acorn_dta())
  nb_isolates <- acorn_dta_filter() %>% 
    fun_filter_target_pathogens() %>% 
    nrow()
  
  as.character(
    div(class = "box_summary", 
        span(class = "numb", nb_isolates), 
        span(class = "smallcaps", i18n$t("Isolates")),
        span(i18n$t("of Target Pathogens"))
    )
  )
})
