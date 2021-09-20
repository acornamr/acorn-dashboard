output$app_github_versions <- renderText({
  
  try(
    version_github <- read_html("https://github.com/acornamr/acorn-dashboard/releases/latest") |> 
      html_element(".release-header .f1") |>
      html_text() |>
      str_trim(),
    silent = TRUE
  )
  
  if(! exists("version_github")) return(NULL)
  
  v_app_version <- glue("v{app_version}")
  
  if(exists("version_github") & version_github == v_app_version) return(paste0("<div class='cl-success'><i class='fa fa-check'></i>", 
                                                                             i18n$t("You are using the latest version of the ACORN Dashboard!"), 
                                                                             "</div>"))

  if(exists("version_github") & version_github != v_app_version) return(paste0("<div class='cl-warning'><i class='fa fa-exclamation-triangle'></i>", 
                                                                             i18n$t("You are running an older version of the ACORN dashboard"),
                                                                             " (", v_app_version, "). ",
                                                                             "<a href = https://github.com/acornamr/acorn-dashboard/releases/latest target='_blank'>",
                                                                             i18n$t("Get the latest version on GitHub"), 
                                                                             " (", version_github, ").", 
                                                                             "</a></div>"))
})