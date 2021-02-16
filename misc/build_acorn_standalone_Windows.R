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
# needs Rtools for Windows for compilation of package 'comoOdeCpp'
# library(devtools)
# Sys.setenv(PATH = paste("C:/Rtools/bin", Sys.getenv("PATH"), sep=";"))

# remotes::install_github("ocelhay/comoOdeCpp", subdir = "comoOdeCpp")
# remotes::install_github("ocelhay/como", ref = "dev")
# como::run_app_standalone()

# needs Rtools for Windows for compilation of package 'comoOdeCpp'
# make sure that Rtools in the PATH
# https://stackoverflow.com/questions/47539125/how-to-add-rtools-bin-to-the-system-path-in-r

time <- format(Sys.time(), "%Y-%m-%d_%H%M%S")
build_path <- paste0("C:/Users/olivi/Desktop/", time)
dir.create(build_path)

# Remove any folder 'app_name' on build_path.

shinybox(
  app_name = "ACORN",
  author = "Olivier Celhay, Paul Turner",
  description = "A Dashboard for ACORN AMR Data",
  semantic_version = "v0.0.1", # format vx.y.z
  mran_date = "2020-12-01",
  cran_like_url = NULL,
  mac_url = NULL,
  git_host = "github",
  git_repo = "acornamr/acorn-dashboard",
  function_name = "run_app",
  local_package_path = NULL,
  package_install_opts = list(type = "binary"),
  build_path = build_path,
  rtools_path_win = "C:\\rtools40\\usr\\bin",
  nodejs_path = "C:/Program Files/nodejs/",
  nodejs_version = "v14.7.0",
  permission = TRUE,
  run_build = TRUE)


## Build the release.
# run_build_release(
#   nodejs_path = nodejs_path,
#   app_path = file.path(build_path, app_name),
#   nodejs_version = nodejs_version)
