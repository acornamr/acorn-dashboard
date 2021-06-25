output$about <- renderText({
  
  # report <- ifelse(pandoc_available(),
  #                  paste(tagList(downloadLink("report", label = span(icon("file-word"), "Generate Report (.docx)")))),
  #                  paste(tagList(span("To generate a report", a("install pandoc", href = "https://pandoc.org/installing.html", target = "_blank"), " and restart the app."))))
  
  
  about_data <- ifelse(is.null(meta()),
                       "No data available",
                       glue("Data generated on the {meta()$time_generation}; by {meta()$user}. {meta()$comment}")
  )
  
  paste(glue("ACORN App {app_version}"), 
        br(),
        about_data,
        br(), br(),
        span("Questions about the App? ", actionLink("show_faq", "explore the FAQ.")),
        br(), br(),
        span(a("Learn more about the ACORN project", href = "https://acornamr.net/", target = "_blank"), 
             " and ", 
             a("contact us.", href = "https://acornamr.net/#/contact.md", target = "_blank")),
        
        br(), br(),
        actionLink("debug", label = "(Debug, developer only)")
  )
})