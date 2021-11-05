on_acorn_load <- function(session) {
  nav_select("data_management_tabs", selected = "info")
  
  nav_show("tabs", target = "overview")
  nav_show("tabs", target = "follow_up")
  nav_show("tabs", target = "hai")
  nav_show("tabs", target = "microbiology")
  nav_show("tabs", target = "amr")
}