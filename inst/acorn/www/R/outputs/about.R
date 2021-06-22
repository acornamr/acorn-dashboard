output$about <- renderText({
  
  # report <- ifelse(pandoc_available(),
  #                  paste(tagList(downloadLink("report", label = span(icon("file-word"), "Generate Report (.docx)")))),
  #                  paste(tagList(span("To generate a report", a("install pandoc", href = "https://pandoc.org/installing.html", target = "_blank"), " and restart the app."))))
  
  
  paste(glue("App version {app_version}"), br(),
        a("ACORN Project website", href = "https://acornamr.net/", class='js-external-link', target="_blank"), br(), br(),
        # report,
        actionLink("debug", label = "(Debug)"),
        p("TODO: link ./www/markdown/about_uCCI.md")
        # includeMarkdown("./www/markdown/about_uCCI.md")
  )
})