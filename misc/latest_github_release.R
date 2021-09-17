# https://stackoverflow.com/questions/69212782/is-it-possible-to-find-the-latest-github-release-of-a-repo-with-r/

# "gh" method
library(gh)

releases <- gh("GET /repos/{owner}/{repo}/releases", 
               owner = "acornamr",
               repo = "acorn-dashboard")

releases[[1]][["tag_name"]]


# "harvest" method
library(rvest)
library(stringr)

read_html("https://github.com/acornamr/acorn-dashboard/releases/latest") |> 
  html_element(".release-header .f1") |>
  html_text() |>
  str_trim()
  
