output$box_filt_1 <- renderUI({
  div(id = "filter-1", class = "box_filter",
      prettyCheckboxGroup(inputId = "filter_type_ward", label = NULL, shape = "curve", status = "primary",
                  choices = c("Paediatrics", "PICU"), 
                  selected = c("Paediatrics", "PICU")),
  )
})

output$box_filt_2 <- renderUI({
  div(id = "filter-2", class = "box_filter",
      prettyCheckboxGroup("filter_sex", label = NULL,  shape = "curve", status = "primary",
                  choices = c("Male", "Female"), selected = c("Male", "Female"))
  )
})

output$box_filt_3 <- renderUI({
  div(id = "filter-3", class = "box_filter",
      prettyCheckboxGroup("filter_category", label = NULL,  status = "primary",
                          icon = icon("check"), animation = "tada", 
                  choices = c("Community Acquired Infections", "Hospital Acquired Infections"), 
                  selected = c("Community Acquired Infections", "Hospital Acquired Infections"))
  )
})

output$box_filt_4 <- renderUI({
  
})

output$box_filt_5 <- renderUI({
  div(class = "box_filter",
      p('Clinical or Day-28 Outcome'), 
      prettySwitch(inputId = "filter_outcome_clinical", label = "Select Only Patients with Clinical Outcome", status = "primary", value = FALSE),
      prettySwitch(inputId = "filter_outcome_d28", label = "Select Only Patients with Day-28 Outcome", status = "primary", value = FALSE)
  )
})