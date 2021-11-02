output$info_data <- renderText({
  about_data <- ifelse(is_empty(meta()),
                       "No data available at this moment.",
                       glue("Data generated on the {meta()$time_generation} with the following: 
                            <ul>
                            <li>Used dashboard version: {meta()$app_version}</li>
                            <li>Site: {meta()$site}</li>
                            <li>User: {meta()$user}</li>
                            <li>Comments: {meta()$comment}</li>
                            </ul>
                            Download loaded data in 
                            {downloadLink('download_data_acorn_format', 'acorn')} or
                            {downloadLink('download_data_excel_format', 'Excel')} format. 
                            Or start exploring the data (Tabs Overview, Follow-up...)."))
  
  paste(HTML(about_data))
})