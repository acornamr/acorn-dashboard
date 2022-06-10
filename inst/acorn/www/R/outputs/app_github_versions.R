output$app_github_versions <- renderText({
  version_github <- NA
  
  try(
    version_github <- rvest::read_html("https://github.com/acornamr/acorn-dashboard/releases/latest") |> 
      rvest::html_element("h1.d-inline") |>
      rvest::html_text() |>
      str_trim() |> 
      sub(pattern = "v", replacement = ""),
    silent = TRUE
  )
  
  compare_version <- utils::compareVersion(app_version, version_github)
  v_app_version <- glue("v{app_version}")
  v_version_github <- glue("v{version_github}")
  
  if(is.na(version_github))  return(HTML(i18n$t("You are running ACORN dashboard"), " ", 
                                         v_app_version))
  
  if(compare_version == 0 | compare_version == 1) return(HTML("<div class='alert alert-success'><i class='fa fa-check'></i>&nbsp;", 
                                       i18n$t("Your ACORN dashboard is up to date"), " (", v_app_version, ")", "</div>"))

  if(compare_version == -1) return(HTML("<div class='alert alert-warning'><i class='fa fa-exclamation-triangle'></i>&nbsp;", 
                                                                             i18n$t("You are running ACORN dashboard"),
                                                                             " ", v_app_version, ".</br>",
                                                                             "Double click on 'UpdateACORN.cmd' in your app folder to update.</div>"))
})