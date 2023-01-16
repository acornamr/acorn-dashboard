load("/Users/olivier/Desktop/NP001_2022-11-14_09H21.acorn")


acorn$about
acorn$meta
acorn$redcap_hai_dta |> View()

acorn$redcap_f01f05_dta |> View()
acorn$lab_dta |> View()
acorn$acorn_dta |> View()

acorn$acorn_dta |> names()

acorn$redcap_f01f05_dta |> nrow()
acorn$lab_dta |> nrow()
acorn$acorn_dta |> nrow()
