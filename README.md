[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R-CMD-check](https://github.com/acornamr/acorn-dashboard/workflows/R-CMD-check/badge.svg)](https://github.com/acornamr/acorn-dashboard/actions)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/acornamr/acorn-dashboard)
[![DOI](https://zenodo.org/badge/339463770.svg)](https://zenodo.org/badge/latestdoi/339463770)

> ACORN | A Clinically Oriented antimicrobial Resistance Network

# ACORN Dashboard

The ACORN Dashboard is a tool to connect, visualise and analyse ACORN collected data.
Detailed information can be found on [ACORN project website.](https://acornamr.net)

# Use case

There are three ways to access the ACORN dashboard:

- online via: https://moru.shinyapps.io/acorn2/ (stable), https://moru.shinyapps.io/acorn2-dev/ (development)
- with the standalone app for Windows by installing the latest release (.exe file in the Assets section): https://github.com/acornamr/acorn-dashboard/releases/latest/
- using the `acorn-dashboard` R package:

1. Download and install R 4.2.0 https://cran.r-project.org/bin/windows/base/R-4.2.0-win.exe
2. **The first time**, open R and copy/paste in the console:
```r
if(!require(remotes)){
    install.packages("remotes", repos = "https://cloud.r-project.org/")
}
remotes::install_github("acornamr/acorn-dashboard", ref = "master", upgrade = "never")
```
3. **From then on**, open R and copy/paste in the console: `acorn::run_app()` every time you want to run the ACORN Dashboard.

Close your browser and quit R at the end of your ACORN session, clicking 'No' when prompted 'Save workspace image?' 
