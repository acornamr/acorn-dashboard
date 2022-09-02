# Remove the warning message when using shiny::icon():
# This Font Awesome icon ('cog') does not exist:
#  * if providing a custom `html_dependency` these `name` checks can 
# be deactivated with `verify_fa = FALSE`

icon <- function(...)  shiny::icon(..., verify_fa = FALSE)