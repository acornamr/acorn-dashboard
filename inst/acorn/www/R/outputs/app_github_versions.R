output$app_github_versions <- renderText({
  version_github <- NA
  
  try(
    version_github <- rvest::read_html("https://github.com/acornamr/acorn-dashboard/releases/latest") |> 
      rvest::html_element("h1.d-inline") |>
      rvest::html_text() |>
      str_trim(),
    silent = TRUE
  )
  
  v_app_version <- glue("v{app_version}")
  
  if(is.na(version_github))  return(HTML(i18n$t("You are running ACORN dashboard"), " ", v_app_version, " ", "<a href = https://github.com/acornamr/acorn-dashboard/releases/latest target='_blank' class = 'alert-link'>", i18n$t("You can check here if it's the latest production release.")))
  
  if(version_github == v_app_version) return(HTML("<div class='alert alert-success'><i class='fa fa-check'></i>&nbsp;", 
                                                                             i18n$t("Your ACORN dashboard is up to date."), "</div>"))

  if(version_github != v_app_version) return(HTML("<div class='alert alert-warning'><i class='fa fa-exclamation-triangle'></i>&nbsp;", 
                                                                             i18n$t("You are running ACORN dashboard"),
                                                                             " ", v_app_version, " ",
                                                                             "<a href = https://github.com/acornamr/acorn-dashboard/releases/latest target='_blank' class = 'alert-link'>",
                                                                             i18n$t("Get the latest production release"), 
                                                                             " (", version_github, ").", "</a></div>"))
})