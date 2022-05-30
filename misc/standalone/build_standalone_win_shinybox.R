# Install and load the latest version of shinybox
remove.packages("shinybox")
detach("package:shinybox", unload = TRUE)
remotes::install_github("ocelhay/shinybox", ref = "master", upgrade = "never")
library(shinybox)

# Check that the package is working.
# remotes::install_github("acornamr/acorn-dashboard", ref = "master")
# acorn::run_app()

# Create a directory for the app.
build_path <- paste0("C:/Users/olivi/Desktop/", format(Sys.time(), "%Y-%m-%d_%H%M%S"))
dir.create(build_path)

shinybox::shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description = "A Dashboard for ACORN AMR Data",
  semantic_version = "v2.4.0",
  cran_like_url = "https://cran.r-project.org/",
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard@development",
  function_name = "run_app", 
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = "C:/rtools40/usr/bin",
  nodejs_path = "C:/Program Files/nodejs/",
  run_build = TRUE)