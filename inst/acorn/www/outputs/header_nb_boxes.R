output$nb_enrollments <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "badge badge-primary f-115", "300"), 
        span(class = "smallcaps", "Total Enrollments"),
        span(class = "badge badge-light f-100 right", "75% of 400")
    )
  )
})

output$nb_patients_distinct <- renderText({
  as.character(
    div(class = "box_summary", 
          span(class = "badge badge-primary f-115", "168"), 
          span(class = "smallcaps", "Distinct Patients"), 
          span(class = "badge badge-light f-100 right", "93% of 180")
    )
  )
})

output$nb_patients_microbiology <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "badge badge-primary f-115", "145"), 
        span(class = "smallcaps", "Enrollnets With Microbiology"),
        span(class = "badge badge-light f-100 right", "81% of 180")
    )
  )
})

output$nb_specimens <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "badge badge-primary f-115", "98"), 
        span(class = "smallcaps", "Specimens Collected"),
        span("1.43 per Enrollment"),
        span(class = "badge badge-light f-100 right", "98% of 180")
    )
  )
})

output$nb_isolates <- renderText({
  as.character(
    div(class = "box_summary", 
        span(class = "badge badge-primary f-115", "10"), 
        span(class = "smallcaps", "Isolates"),
        span("from cultures that have growth"),
        span(class = "badge badge-light f-100 right", "5 of Target Pathogens")
    )
  )
})