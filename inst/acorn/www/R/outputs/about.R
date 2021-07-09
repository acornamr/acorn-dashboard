output$about <- renderText({
  
  # report <- ifelse(pandoc_available(),
  #                  paste(tagList(downloadLink("report", label = span(icon("file-word"), "Generate Report (.docx)")))),
  #                  paste(tagList(span("To generate a report", a("install pandoc", href = "https://pandoc.org/installing.html", target = "_blank"), " and restart the app."))))
  
  about_data <- ifelse(is.null(meta()),
                       "No data available.<br><br>",
                       glue("Data generated on the {meta()$time_generation}: 
                            <ul>
                            <li>App version: {meta()$app_version}</li>
                            <li>Site: {meta()$site}</li>
                            <li>User: {meta()$user}</li>
                            <li>Comments: {meta()$comment}</li></ul>")
  )
  
  paste(p(glue("App version: {app_version}")), 
        about_data,
        p("Questions about the App? ", actionLink("show_faq", "explore the FAQ."), "You can learn more about ACORN ", a("on the project website", href = "https://acornamr.net/", target = "_blank"), 
          " and ",  a("contact us.", href = "https://acornamr.net/#/contact.md", target = "_blank")),
        hr(), actionLink("debug", label = "(Debug, developer only)")
  )
})