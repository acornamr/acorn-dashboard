focus_analysis <- function() {
  showTab("tabs", target = "overview")
  showTab("tabs", target = "follow_up")
  showTab("tabs", target = "hai")
  showTab("tabs", target = "microbiology")
  showTab("tabs", target = "amr")
  
  # updateTabsetPanel(inputId = "tabs", selected = "overview")
  # Sys.sleep(1)
  runjs('document.getElementById("anchor_header").scrollIntoView();')
}