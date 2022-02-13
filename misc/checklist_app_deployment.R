# run once:
# renv::init()

# deploy on dev URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2-dev", 
                     account = "moru",
                     forceUpdate = TRUE)


# if the deployment on the dev URL works:
# take a snapshot of installed packages
renv::snapshot()

# commit to GitHub

# generate and test standalone Windows app

# deploy on production URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2",
                     account = "moru")


# the generated standalone app should be tested independently
# as it's not using the same set of packages.
