load("/Users/olivier/Documents/Projets/ACORN/Data/acorn_data_2021-11-10_13H24.acorn")


dic <- full_join(
  acorn$redcap_f01f05_dta |> names() |> as_tibble() |> mutate(redcap_f01f05_dta = "Yes"),
  acorn$acorn_dta |> names() |> as_tibble() |> mutate(redcap_acorn_dta = "Yes")
)

dic <- full_join(dic,
          acorn$redcap_hai_dta |> names() |> as_tibble() |> mutate(redcap_hai_dta = "Yes"))

dic <- full_join(dic,
          acorn$lab_dta |> names() |> as_tibble() |> mutate(redcap_lab_dta = "Yes"))


write_excel_csv(dic, file = "/Users/olivier/Documents/Projets/ACORN/Data/variables_dic.csv", delim = ";")

