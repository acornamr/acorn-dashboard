on_acorn_load <- function(session) {
  nav_show("tabs", target = "overview")
  nav_show("tabs", target = "follow_up")
  nav_show("tabs", target = "hai")
  nav_show("tabs", target = "microbiology")
  nav_show("tabs", target = "amr")
  
  
  updateRadioGroupButtons(session = session, "choice_datamanagement", i18n$t("What do you want to do?"),
                          choiceValues = c("generate", "load_cloud", "load_local", "info"),
                          choiceNames = choices_datamanagement,
                          selected = "info", status = "success",
                          checkIcon = list(yes = icon("hand-point-right")))
}