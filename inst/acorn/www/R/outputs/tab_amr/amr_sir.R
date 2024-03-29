# Acinetobacter species ----
output$acinetobacter_sir <- renderHighchart({
  req(acorn_dta_filter())
  highchart_sir(data_input = acorn_dta_filter(), organism_input = "Acinetobacter sp", corresp = corresp_org_antibio(), 
                combine_SI = input$combine_SI, deduplication_method = input$deduplication_method)
})

output$acinetobacter_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Acinetobacter sp", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "acinetobacter_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$acinetobacter_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Acinetobacter sp", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method, exclude_antibio = input$acinetobacter_upset_antibio)
})

output$acinetobacter_sir_evolution <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Acinetobacter sp"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(),
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_acinetobacter_sir <- reactive({
  req(acorn_dta_filter())
  vec <- unique(acorn_dta_filter()$orgname)
  organism_input <- vec[str_detect(vec, "Acinetobacter")]
  
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname %in% organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_acinetobacter_sir", suspendWhenHidden = FALSE)

output$nb_isolates_acinetobacter <- renderText({
  req(acorn_dta_filter())
  vec <- unique(acorn_dta_filter()$orgname)
  organism_input <- vec[str_detect(vec, "Acinetobacter")]
  
  req(acorn_dta_filter() %>% filter(orgname %in% organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname %in% organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {paste(organism_input, collapse = ', ')}</em>"), "There are no isolates.")
})

# Escherichia coli ----
output$ecoli_sir <- renderHighchart({
  req(acorn_dta_filter())
  highchart_sir(data_input = acorn_dta_filter(), organism_input = "Escherichia coli", corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$ecoli_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Escherichia coli", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "ecoli_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$ecoli_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Escherichia coli", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method, exclude_antibio = input$ecoli_upset_antibio)
})

output$ecoli_sir_evolution <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Escherichia coli"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_ecoli_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Escherichia coli"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_ecoli_sir", suspendWhenHidden = FALSE)

output$ecoli_sir_evolution_ceph <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Escherichia coli"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$nb_isolates_ecoli <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Escherichia coli"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# Haemophilus Influenzae ----
output$haemophilus_influenzae_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Haemophilus influenzae"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                combine_SI = input$combine_SI, deduplication_method = input$deduplication_method)
})

output$haemophilus_influenzae_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Haemophilus influenzae", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "haemophilus_influenzae_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$haemophilus_influenzae_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Haemophilus influenzae", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$haemophilus_influenzae_upset_antibio)
})

output$test_haemophilus_influenzae_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Haemophilus influenzae"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_haemophilus_influenzae_sir", suspendWhenHidden = FALSE)

output$nb_isolates_haemophilus_influenzae <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Haemophilus influenzae"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# K. pneumoniae ----
output$kpneumoniae_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$kpneumoniae_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Klebsiella pneumoniae", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "kpneumoniae_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$kpneumoniae_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Klebsiella pneumoniae", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$kpneumoniae_upset_antibio)
})

output$kpneumoniae_sir_evolution <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_kpneumoniae_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Klebsiella pneumoniae"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_kpneumoniae_sir", suspendWhenHidden = FALSE)

output$kpneumoniae_sir_evolution_ceph <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$nb_isolates_kpneumoniae <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Klebsiella pneumoniae"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# Neisseria meningitidis ----
output$neisseria_meningitidis_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Neisseria meningitidis"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                combine_SI = input$combine_SI, deduplication_method = input$deduplication_method)
})

output$neisseria_meningitidis_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Neisseria meningitidis", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "neisseria_meningitidis_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$neisseria_meningitidis_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Neisseria meningitidis", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$neisseria_meningitidis_upset_antibio)
})

output$test_neisseria_meningitidis_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Neisseria meningitidis"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_neisseria_meningitidis_sir", suspendWhenHidden = FALSE)

output$nb_isolates_neisseria_meningitidis <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Neisseria meningitidis"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# Pseudomonas aeruginosa ----
output$pseudomonas_aeruginosa_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Pseudomonas aeruginosa"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                combine_SI = input$combine_SI, deduplication_method = input$deduplication_method)
})

output$pseudomonas_aeruginosa_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Pseudomonas aeruginosa", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "pseudomonas_aeruginosa_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$pseudomonas_aeruginosa_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Pseudomonas aeruginosa", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$pseudomonas_aeruginosa_upset_antibio)
})

output$pseudomonas_aeruginosa_sir_evolution <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Pseudomonas aeruginosa"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(),
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_pseudomonas_aeruginosa_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Pseudomonas aeruginosa"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_pseudomonas_aeruginosa_sir", suspendWhenHidden = FALSE)

output$nb_isolates_pseudomonas_aeruginosa <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Pseudomonas aeruginosa"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# S. aureus ----
output$saureus_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Staphylococcus aureus"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$saureus_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Staphylococcus aureus", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "saureus_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$saureus_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Staphylococcus aureus", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$saureus_upset_antibio)
})

output$saureus_sir_evolution <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Staphylococcus aureus"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Oxacillin",
                          deduplication_method = input$deduplication_method)
})

output$test_saureus_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Staphylococcus aureus"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_saureus_sir", suspendWhenHidden = FALSE)

output$nb_isolates_saureus <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Staphylococcus aureus"
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# S. pneumoniae ----
output$spneumoniae_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Streptococcus pneumoniae"
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$spneumoniae_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = "Streptococcus pneumoniae", 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "spneumoniae_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$spneumoniae_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = "Streptococcus pneumoniae", corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$spneumoniae_upset_antibio)
})

output$spneumoniae_sir_evolution_pen <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Streptococcus pneumoniae"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Penicillin G",
                          deduplication_method = input$deduplication_method)
})

output$spneumoniae_sir_evolution_pen_men <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- "Streptococcus pneumoniae"
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Penicillin G - meningitis",
                          deduplication_method = input$deduplication_method)
})

output$test_spneumoniae_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- "Streptococcus pneumoniae"
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_spneumoniae_sir", suspendWhenHidden = FALSE)

output$nb_isolates_spneumoniae <- renderText({
  req(acorn_dta_filter())
  organism_input <- "Streptococcus pneumoniae"
  req(acorn_dta_filter() %>% filter(orgname == organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

# Salmonella ----
output$salmonella_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$salmonella_upset_antibio <- renderUI({
  req(acorn_dta_filter())
  antibio <- upset_antibiotics(
    data_input = acorn_dta_filter(), 
    organism_input = input$select_salmonella, 
    corresp = corresp_org_antibio(), 
    deduplication_method = input$deduplication_method
  )
  
  tagList(
    fluidRow(
      column(
        width = 4,
        "Exclude antibiotic(s):"
      ),
      column(
        width = 8,
        pickerInput(
          "salmonella_upset_antibio", 
          NULL, 
          multiple = TRUE,
          choices = antibio, 
          selected = NULL
        )
      )
    ),
    tags$small(text$co_resistance)
  )
})

output$salmonella_co_resistance <- renderPlot({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  upset_co_resistance(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                      deduplication_method = input$deduplication_method,
                      exclude_antibio = input$salmonella_upset_antibio)
})

output$salmonella_sir_evolution_ceph <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$salmonella_sir_evolution_fluo <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  highchart_sir_evolution(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate Fluoroquinolones",
                          deduplication_method = input$deduplication_method)
})

# Salmonella sp (not S. Typhi or S. Paratyphi) ----
output$test_salmonella_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  
  if(organism_input == "Salmonella sp (not S. Typhi or S. Paratyphi)") {
    vec <- unique(acorn_dta_filter()$orgname)
    organism_input <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella Typhi" & !str_detect(vec, "Salmonella Paratyphi")]
  }
  
  ifelse (nrow(acorn_dta_filter() %>% filter(orgname %in% organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_salmonella_sir", suspendWhenHidden = FALSE)

output$nb_isolates_salmonella <- renderText({
  req(acorn_dta_filter())
  organism_input <- input$select_salmonella
  
  if(organism_input == "Salmonella sp (not S. Typhi or S. Paratyphi)") {
    vec <- unique(acorn_dta_filter()$orgname)
    organism_input <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella Typhi" & !str_detect(vec, "Salmonella Paratyphi")]
  }
  
  req(acorn_dta_filter() %>% filter(orgname %in% organism_input))
  nb <- acorn_dta_filter() %>% filter(orgname %in% organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})


# Other Organism ----
output$other_organism_sir <- renderHighchart({
  req(acorn_dta_filter())
  organism_input <- input$other_organism
  highchart_sir(data_input = acorn_dta_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$test_other_sir <- reactive({
  req(acorn_dta_filter())
  organism_input <- input$other_organism
  ifelse (nrow(acorn_dta_filter() %>% 
                 filter(orgname == organism_input) %>% 
                 fun_deduplication(method = input$deduplication_method) %>% 
                 filter_at(vars(any_of(corresp_org_antibio()$antibio_code)), any_vars(!is.na(.)))) == 0, FALSE, TRUE)
})
outputOptions(output, "test_other_sir", suspendWhenHidden = FALSE)

output$nb_isolates_other <- renderText({
  req(acorn_dta_filter())
  organism_input <- input$other_organism
  req(acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method))
  nb <- acorn_dta_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("<em>Total of {nb} isolate(s) for {organism_input}</em>"), "There are no isolates.")
})

