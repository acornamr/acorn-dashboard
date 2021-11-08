output$info_data <- renderText({
  
  about_data <- ifelse(is_empty(meta()),
                       "No data available at this moment.",
                       {
                         time_generation <- meta()$time_generation |> as_datetime(format = "%Y-%m-%d_%HH%M") |> format("%d %B %Y at %H:%M")
                         ifelse(input$cred_site == "Run Demo",
                                glue(
                                  "Data generated on the {time_generation} (local time) with: 
                                  <ul>
                                  <li>Dashboard version: {meta()$app_version}</li>
                                  <li>Site: {meta()$site}</li>
                                  <li>User: {meta()$user}</li>
                                  <li>Comments: {meta()$comment}</li>
                                  </ul>"),
                            glue(
                              "Data generated on the {time_generation} (local time) with: 
                              <ul>
                              <li>Dashboard version: {meta()$app_version}</li>
                              <li>Site: {meta()$site}</li>
                              <li>User: {meta()$user}</li>
                              <li>Comments: {meta()$comment}</li>
                              </ul>
                              Download loaded data in 
                              {downloadLink('download_data_acorn_format', 'acorn')} or
                              {downloadLink('download_data_excel_format', 'Excel')} format. 
                              Or start exploring the data (Tabs Overview, Follow-up...).")
                         )
                       })
  
  paste(HTML(about_data))
})