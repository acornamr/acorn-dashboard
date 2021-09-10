# work on 2021-09-10
# Perform (once per machine) a manual installation of nodejs (https://nodejs.org/en/).

# Install latest version of shinybox.
if(FALSE) {
  rm(list = ls())
  remove.packages("shinybox")
  detach("package:shinybox", unload = TRUE)
  remotes::install_github("ocelhay/shinybox", auth_token = "")
}
library(shinybox)

# Check that the package is working.
remotes::install_github("acornamr/acorn-dashboard", ref = "master")
acorn::run_app()
# if needed rebuild NAMSEPACE (somehow macOS is less stringent about this)

# Create a directory for the app.
time <- format(Sys.time(), "%Y-%m-%d_%H%M%S")
build_path <- paste0("C:/Users/olivi/Desktop/", time)
dir.create(build_path)

shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description = "A Dashboard for ACORN AMR Data",
  semantic_version = "v2.0.3", # format vx.y.z
  cran_like_url = "https://cran.microsoft.com/snapshot/2021-09-04",  # too old snapshots can have package issues
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard",
  function_name = "run_app", 
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = "C:\\rtools40\\usr\\bin",
  nodejs_path = "C:/Program Files/nodejs/",
  run_build = TRUE)
