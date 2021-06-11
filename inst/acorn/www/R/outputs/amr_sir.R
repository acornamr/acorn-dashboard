# A. baumannii ----

output$abaumannii_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Acinetobacter baumannii"
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$abaumannii_sir_evolution <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Acinetobacter baumannii"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_group = "Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_abaumannii_sir <- reactive({
  req(microbio_filter())
  organism_input <- "Acinetobacter baumannii"
  ifelse (nrow(microbio_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_abaumannii_sir", suspendWhenHidden = FALSE)

output$nb_isolates_abaumannii <- renderText({
  req(microbio_filter())
  organism_input <- "Acinetobacter baumannii"
  req(microbio_filter() %>% filter(orgname == organism_input))
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, glue("Total of {nb} isolate(s) for {organism_input}"), HTML("There are no isolates for {organism_input}"))
})


# Escherichia coli ----

output$ecoli_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Escherichia coli"
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$ecoli_sir_evolution <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Escherichia coli"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_group = "Carbapenems",
                          deduplication_method = input$deduplication_method)
})

output$test_ecoli_sir <- reactive({
  req(microbio_filter())
  organism_input <- "Escherichia coli"
  ifelse (nrow(microbio_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_ecoli_sir", suspendWhenHidden = FALSE)

output$ecoli_sir_evolution_ceph <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Escherichia coli"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$nb_isolates_ecoli <- renderText({
  req(microbio_filter())
  organism_input <- "Escherichia coli"
  req(microbio_filter() %>% filter(orgname == organism_input))
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span("Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})

# K. pneumoniae ----

output$kpneumoniae_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$kpneumoniae_sir_evolution <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_group = "Carbapenems",
                          deduplication_method = input$deduplication_method)
})


output$test_kpneumoniae_sir <- reactive({
  req(microbio_filter())
  organism_input <- "Klebsiella pneumoniae"
  ifelse (nrow(microbio_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_kpneumoniae_sir", suspendWhenHidden = FALSE)

output$kpneumoniae_sir_evolution_ceph <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Klebsiella pneumoniae"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$nb_isolates_kpneumoniae <- renderText({
  req(microbio_filter())
  organism_input <- "Klebsiella pneumoniae"
  req(microbio_filter() %>% filter(orgname == organism_input))
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span("Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})

# S. aureus ----
output$saureus_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Staphylococcus aureus"
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$saureus_sir_evolution <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Staphylococcus aureus"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Oxacillin",
                          deduplication_method = input$deduplication_method)
})

output$test_saureus_sir <- reactive({
  req(microbio_filter())
  organism_input <- "Staphylococcus aureus"
  ifelse (nrow(microbio_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_saureus_sir", suspendWhenHidden = FALSE)

output$nb_isolates_saureus <- renderText({
  req(microbio_filter())
  organism_input <- "Staphylococcus aureus"
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span("Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})

# S. pneumoniae ----

output$spneumoniae_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Streptococcus pneumoniae"
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$spneumoniae_sir_evolution <- renderHighchart({
  req(microbio_filter())
  organism_input <- "Streptococcus pneumoniae"
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_group = "Penicillins",
                          deduplication_method = input$deduplication_method)
})

output$test_spneumoniae_sir <- reactive({
  req(microbio_filter())
  organism_input <- "Streptococcus pneumoniae"
  ifelse (nrow(microbio_filter() %>% filter(orgname == organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_spneumoniae_sir", suspendWhenHidden = FALSE)

output$nb_isolates_spneumoniae <- renderText({
  req(microbio_filter())
  organism_input <- "Streptococcus pneumoniae"
  req(microbio_filter() %>% filter(orgname == organism_input))
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span("Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})

# Salmonella ----

output$salmonella_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- input$select_salmonella
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$salmonella_sir_evolution_ceph <- renderHighchart({
  req(microbio_filter())
  organism_input <- input$select_salmonella
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_antibio = "Aggregate 3rd gen. ceph.",
                          deduplication_method = input$deduplication_method)
})

output$salmonella_sir_evolution_fluo <- renderHighchart({
  req(microbio_filter())
  organism_input <- input$select_salmonella
  highchart_sir_evolution(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), 
                          combine_SI = input$combine_SI, filter_group = "Fluoroquinolones",
                          deduplication_method = input$deduplication_method)
})

output$test_salmonella_sir <- reactive({
  req(microbio_filter())
  organism_input <- input$select_salmonella
  
  if(organism_input == "Salmonella sp (not S. typhi or S. paratyphi)") {
    vec <- unique(microbio_filter()$organism)
    organism_input <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella typhi" & vec != "Salmonella paratyphi"]
  }
  
  ifelse (nrow(microbio_filter() %>% filter(orgname %in% organism_input)) == 0, FALSE, TRUE)
})
outputOptions(output, "test_salmonella_sir", suspendWhenHidden = FALSE)

output$nb_isolates_salmonella <- renderText({
  req(microbio_filter())
  organism_input <- input$select_salmonella
  
  if(organism_input == "Salmonella sp (not S. typhi or S. paratyphi)") {
    vec <- unique(microbio_filter()$organism)
    organism_input <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella typhi" & vec != "Salmonella paratyphi"]
  }
  
  req(microbio_filter() %>% filter(orgname %in% organism_input))
  nb <- microbio_filter() %>% filter(orgname %in% organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span("Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})


# Other Organism ----
output$other_organism_sir <- renderHighchart({
  req(microbio_filter())
  organism_input <- input$other_organism
  highchart_sir(data_input = microbio_filter(), organism_input = organism_input, corresp = corresp_org_antibio(), combine_SI = input$combine_SI,
                deduplication_method = input$deduplication_method)
})

output$test_other_sir <- reactive({
  req(microbio_filter())
  organism_input <- input$other_organism
  ifelse (nrow(microbio_filter() %>% 
                 filter(orgname == organism_input) %>% 
                 fun_deduplication(method = input$deduplication_method) %>% 
                 filter_at(vars(AMK:thirdgenceph), any_vars(!is.na(.)))) == 0, FALSE, TRUE)
})
outputOptions(output, "test_other_sir", suspendWhenHidden = FALSE)

output$nb_isolates_other <- renderText({
  req(microbio_filter())
  organism_input <- input$other_organism
  req(microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method))
  nb <- microbio_filter() %>% filter(orgname == organism_input) %>% fun_deduplication(method = input$deduplication_method) %>% nrow()
  ifelse (nb != 0, paste0(span(strong(organism_input), br(), "Total of ", br(), nb, " isolates")), HTML("There are no isolates"))
})

