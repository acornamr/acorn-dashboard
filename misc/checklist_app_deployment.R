# run once:
# renv::init()

# (1) deploy on dev URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2-dev", 
                     account = "moru",
                     forceUpdate = TRUE)

# visit: https://moru.shinyapps.io/acorn2-dev/


# (2) if the deployment on the dev URL works:
# take a snapshot of installed packages
renv::snapshot()

# (3) commit to GitHub

# (4) generate and test standalone apps
# the generated standalone app should be tested independently as there might not be using the same set of packages.

# (5) deploy on production URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2",
                     account = "moru")
