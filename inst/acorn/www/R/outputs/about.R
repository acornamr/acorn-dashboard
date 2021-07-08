output$about <- renderText({
  
  # report <- ifelse(pandoc_available(),
  #                  paste(tagList(downloadLink("report", label = span(icon("file-word"), "Generate Report (.docx)")))),
  #                  paste(tagList(span("To generate a report", a("install pandoc", href = "https://pandoc.org/installing.html", target = "_blank"), " and restart the app."))))
  
  
  about_data <- ifelse(is.null(meta()),
                       "No data available",
                       glue("Data generated on the {meta()$time_generation}; </br> 
                            - ACORN App version {meta()$app_version};</br>
                            - ACORN site: {meta()$site}</br> 
                            - ACORN user: {meta()$user}</br> 
                            - Comments: {meta()$comment}")
  )
  
  paste(p(glue("App version: {app_version}")), 
        about_data,
        br(), br(),
        p("Questions about the App? ", actionLink("show_faq", "explore the FAQ.")),
        p(a("Learn more about the ACORN project", href = "https://acornamr.net/", target = "_blank"), 
          " and ", 
          a("contact us.", href = "https://acornamr.net/#/contact.md", target = "_blank")),
        hr(), actionLink("debug", label = "(Debug, developer only)")
  )
})