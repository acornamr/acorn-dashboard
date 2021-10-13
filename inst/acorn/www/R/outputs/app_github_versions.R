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
  
  if(exists("version_github") & version_github == v_app_version) return(paste0("<div class='alert alert-success'><i class='fa fa-check'></i>&nbsp;", 
                                                                             i18n$t("Your ACORN Dashboard is up to date."), 
                                                                             "</div>"))

  if(exists("version_github") & version_github != v_app_version) return(paste0("<div class='alert alert-warning'><i class='fa fa-exclamation-triangle'></i>&nbsp;", 
                                                                             i18n$t("You are running ACORN dashboard"),
                                                                             " ", v_app_version, " ",
                                                                             "<a href = https://github.com/acornamr/acorn-dashboard/releases/latest target='_blank' class = 'alert-link'>",
                                                                             i18n$t("Get the latest production release"), 
                                                                             " (", version_github, ").", 
                                                                             "</a></div>"))
})