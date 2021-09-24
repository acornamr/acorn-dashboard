output$about <- renderText({
  
  about_data <- ifelse(is_empty(meta()),
                       "No data available.",
                       glue("Data generated on the {meta()$time_generation}: 
                            <ul>
                            <li>App version: {meta()$app_version}</li>
                            <li>Site: {meta()$site}</li>
                            <li>User: {meta()$user}</li>
                            <li>Comments: {meta()$comment}</li></ul>")
  )
  
  paste(
    div(class = "alert alert-primary",
      p(glue("App version: {app_version}")), HTML(about_data)
      )
  )
})