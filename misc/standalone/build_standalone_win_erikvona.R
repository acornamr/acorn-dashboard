# Install and load the latest version of erikvona/electricShine
remotes::install_github("erikvona/electricShine", ref = "master", upgrade = "never")
library(electricShine)

# Check that the package is working.
# remotes::install_github("acornamr/acorn-dashboard", ref = "master")
# acorn::run_app()

# Create a directory for the app.
# buildPath <- paste0("/Users/olivier/Desktop/standalone_", format(Sys.time(), "%Y-%m-%d_%H%M%S"))

dir.create(buildPath)

electricShine::electrify(app_name = "ACORN",
                         short_description = "A Dashboard for ACORN AMR Data",
                         semantic_version = "2.4.1",
                         build_path = buildPath,
                         mran_date = NULL,
                         cran_like_url = "https://cran.r-project.org",
                         function_name = "run_app",
                         git_host = "github",
                         git_repo = "",
                         local_package_path = NULL,
                         package_install_opts = list(type = "binary"),
                         run_build = TRUE)
