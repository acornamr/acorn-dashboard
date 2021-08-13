output$about <- renderText({
  
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
        # TODO: comment in production
        hr(), actionLink("debug", label = "(Debug, developer only)")
  )
})