# Install and load the latest version of shinybox
remove.packages("shinybox")
detach("package:shinybox", unload = TRUE)
remotes::install_github("ocelhay/shinybox", ref = "master", upgrade = "never")
library(shinybox)

# Check that the package is working.
# remotes::install_github("acornamr/acorn-dashboard", ref = "master")
# acorn::run_app()

# Create a directory for the app.
build_path <- glue::glue("/Users/olivier/Desktop/shinybox_{format(Sys.time(), '%Y-%m-%d_%H%M')}")
dir.create(build_path)

# !!! Make sure NOT to be working in a RStudio session with 'renv' activated.
shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description =  "A Dashboard for ACORN AMR Data",
  semantic_version = "v2.3.0",
  cran_like_url = "https://cran.r-project.org",
  mac_r_url = "https://mac.r-project.org/high-sierra/R-4.1-branch/x86_64/R-4.1-branch.tar.gz",
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard@development",
  function_name = "run_app", 
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = NULL,
  nodejs_path = "/usr/local/bin/",
  run_build = TRUE)
