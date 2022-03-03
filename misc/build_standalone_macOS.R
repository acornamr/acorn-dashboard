# Install and load the latest version of shinybox
remove.packages("shinybox")
detach("package:shinybox", unload = TRUE)
remotes::install_github("ocelhay/shinybox", ref = "master", upgrade = "never")
library(shinybox)


# NOT SURE IF NEEDED: remove the acorn package
remotes::install_github("ocelhay/shinybox@dev", upgrade = "never")
remove.packages("acorn")
detach("package:acorn", unload = TRUE)


# NEED to be working in a RStudio session without renv.
# add renv::deactivate()? https://cran.r-project.org/web/packages/renv/vignettes/renv.html


# Check that the package is working.
# remotes::install_github("acornamr/acorn-dashboard", ref = "master")
# acorn::run_app()
# if needed rebuild NAMSEPACE (somehow macOS is less stringent about this)

# Create a directory for the app.
build_path <- glue::glue("/Users/olivier/Desktop/shinybox_{format(Sys.time(), '%Y-%m-%d_%H%M')}")
dir.create(build_path)

shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description =  "A Dashboard for ACORN AMR Data",
  semantic_version = "v2.2.8",
  cran_like_url = "https://cran.r-project.org",  # "https://cran.microsoft.com/snapshot/2021-01-10",
  # mac_file = "/Users/olivier/Documents/Ressources Pro/R/macOS targz/R-4.1-branch.tar.gz",
  mac_r_url = "https://mac.r-project.org/high-sierra/R-4.1-branch/x86_64/R-4.1-branch.tar.gz", # only used if mac_file is NULL
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard@development",
  function_name = "run_app", 
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = NULL,
  nodejs_path = "/usr/local/bin/",
  run_build = TRUE)
