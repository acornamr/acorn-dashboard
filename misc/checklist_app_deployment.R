# run once:
# renv::init()

# deploy on dev URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2-dev", 
                     account = "moru")


# if it works:
# take a snapshot of installated package
renv::snapshot()

# deploy on production URL
rsconnect::deployApp(appDir = "./inst/acorn/", 
                     appName = "acorn2",
                     account = "moru")
