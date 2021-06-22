# Perform (once per machine) a manual installation of nodejs (https://nodejs.org/en/).

# Install latest version of shinybox
if(FALSE) {
rm(list = ls())
remove.packages("shinybox")
detach("package:shinybox", unload = TRUE)
remotes::install_github("ocelhay/shinybox")
}

# Check that the package is working
if(FALSE) {
  remove.packages('acorn')
  library(remotes)
  install_github("acornamr/acorn-dashboard@dev")
  library(acorn)
  acorn::run_app()
}


# Create a directory for the app
time <- format(Sys.time(), "%Y-%m-%d_%H%M")
(build_path <- paste0("/Users/olivier/Documents/Projets/ACORN/acorn-standalone_", time))
dir.create(build_path)

library(shinybox)
shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description = "A Dashboard for ACORN AMR Data",
  semantic_version = "v0.0.1", # format vx.y.z
  cran_like_url = "https://cran.microsoft.com/snapshot/2021-02-11",
  mac_file = "/Users/olivier/Documents/Projets/Standalone R Shiny/R/macOS/2021-02-11/R-4.0-branch.tar.gz",
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard@dev",
  function_name = "run_app", 
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = NULL,
  nodejs_path = "/usr/local/bin/",
  run_build = TRUE)
