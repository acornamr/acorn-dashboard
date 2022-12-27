upset_co_resistance <- function(data_input, organism_input, corresp, deduplication_method) {
  
  find_name <- function(x) {
    ifelse (x %in% corresp$antibio_code,
            corresp$antibio_name[which(corresp$antibio_code == x)],
            x)
  }
  vec_find_names <- Vectorize(find_name)
  
  # Column in the Organism-Antibiotic matrix
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
  
  
  # Treatment of species
  organism_filter <- organism_input
  
  if(organism_input == "Acinetobacter sp") {
    vec <- unique(data_input$orgname)
    organism_filter <- vec[str_detect(vec, "Acinetobacter")]
  }
  
  if(organism_input == "Salmonella sp (not S. Typhi or S. Paratyphi)") {
    vec <- unique(data_input$orgname)
    organism_filter <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella Typhi" & !str_detect(vec, "Salmonella Paratyphi")]
  }
  
  antibio_to_show <- corresp |> filter(!!sym(matching_name_column) == "show") |> pull(antibio_code)
  
  dta <- data_input |> 
    filter(orgname %in% organism_filter) %>%
    fun_deduplication(method = deduplication_method) |> 
    select(c("specid", any_of(antibio_to_show))) |> 
    # remove columns that contains only NA:
    select(where(~ !all(is.na(.x)))) |>
    # remove rows that contains only NA (apart from specid):
    filter(if_any(!contains("specid"), ~ !is.na(.))) |> 
    mutate(across(any_of(antibio_to_show), ~ . == "R"))
  
  if (! any(dta[, -1]))  return({
    plot(c(0, 1), c(0, 1), ann = F, bty = "n", type = "n", xaxt = "n", yaxt = "n")
    text(x = 0.5, y = 0.5, paste("There are no resistant."), cex = 1.6, col = "black")
  })
  
  dta <- dta |> 
    rename_with(vec_find_names, -specid)
  
  ComplexUpset::upset(
    data = dta, 
    intersect = colnames(dta)[-1], 
    name = " ", 
    width_ratio = 0.2, 
    stripes = "white",
    keep_empty_groups = TRUE,
    themes = ComplexUpset::upset_default_themes(
      text = element_text(size = 14), 
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 0), 
      legend.position = "none"
    ),
    base_annotations = list(
      "Intersection size" = (
        ComplexUpset::intersection_size() + 
          xlab(NULL) +
          scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
      )
    ),
    set_sizes = ComplexUpset::upset_set_size(position = "right") +
      ylab(NULL) +
      geom_label(aes(label = ..count..), fill = cols_sir[3], color = "white", hjust = 1.1, stat = "count") +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1))))),
    matrix = (
      ComplexUpset::intersection_matrix(
        geom = geom_point(size = 4), 
        segment = geom_segment(linetype = 'dotted')
      ) +
        scale_color_manual(values = c(
          "TRUE" = cols_sir[3], 
          "FALSE" = cols_sir[1])
        )
    )
  )
}
