# install.packages("ComplexUpset")
library(ggplot2)
library(ComplexUpset)

# - Upsets plot - complex upset R package. Knowing taht a bug is resistant but when it comes to 
# coming with a guideline, the upset plot become useful. 
# We want to see the co-resistance. Heat map will not provide this kind of co-resistance.
# https://krassowski.github.io/complex-upset/articles/Examples_R.html

load(file = "/Users/olivier/Documents/Projets/ACORN/Data/acorn_data_2021-11-10_13H24.acorn")

dta <- acorn$acorn_dta
corresp <- acorn$corresp_org_antibio

find_name <- function(x) {
  ifelse (x %in% corresp$antibio_code,
          corresp$antibio_name[which(corresp$antibio_code == x)],
          x)
}

vec_find_names <- Vectorize(find_name)

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I and R


organism_input <- "Staphylococcus aureus"
organism_input <- "Escherichia coli"


matching_name_column <- "all_other_organisms"  # default
if(organism_input == "Acinetobacter sp")            matching_name_column <- "acinetobacter_species"
if(organism_input == "Escherichia coli")            matching_name_column <- "e_coli"
if(organism_input == "Haemophilus influenzae")      matching_name_column <- "haemophilus_influenzae"
if(organism_input == "Klebsiella pneumoniae")       matching_name_column <- "k_pneumoniae"
if(organism_input == "Neisseria meningitidis")      matching_name_column <- "neisseria_meningitidis"
if(organism_input == "Pseudomonas aeruginosa")      matching_name_column <- "pseudomonas_aeruginosa"
if(str_detect(organism_input, "Salmonella"))        matching_name_column <- "salmonella_species"
if(organism_input == "Staphylococcus aureus")       matching_name_column <- "s_aureus"
if(organism_input == "Streptococcus pneumoniae")    matching_name_column <- "s_pneumoniae"



dta2 <- dta |> 
  filter(orgname == organism_input) |> 
  select(c("specid", any_of(corresp$antibio_code))) |> 
  select(where(~ !all(is.na(.x)))) |> 
  mutate(across(any_of(corresp$antibio_code), ~ . == "R")) |> 
  rename_with(vec_find_names, -specid)

upset(dta2, colnames(dta2)[-1], name = "", width_ratio = 0.2, keep_empty_groups = TRUE,
      base_annotations = list(
        'Intersection size' = (
          intersection_size() + 
            theme(plot.background = element_rect(fill = "#E5D3B3")) + 
            ylab("Observations in intersection"))
      ),
      matrix = (
        intersection_matrix() +
          scale_color_manual(
            values = c("TRUE" = cols_sir[3], "FALSE" = cols_sir[1]),
            labels = c('TRUE' = "Resistant", "FALSE" = "Susceptible / Intermediate / Non Tested"),
            breaks = c("TRUE", "FALSE"),
            name = NULL
          )
      )
) +
  ggtitle(paste0(organism_input, " co-resistance")) +
  theme(legend.position = "bottom")
