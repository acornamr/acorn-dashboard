output$bsi_summary <- renderText({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)

  ecoli_bsi <- acorn_dta_filter() %>% fun_filter_blood_only() %>% filter(bsi_pahtogen == "ECOLI") %>% pull(redcap_id) %>% n_distinct()
  staph_bsi <- acorn_dta_filter() %>% fun_filter_blood_only() %>% filter(bsi_pahtogen == "STAPH") %>% pull(redcap_id) %>% n_distinct()
  
  ecoli_lab <- acorn_dta_filter() %>% fun_filter_blood_only() %>% filter(orgname == "Escherichia coli") %>% nrow()
  staph_lab <- acorn_dta_filter() %>% fun_filter_blood_only() %>% filter(orgname == "Staphylococcus aureus") %>% nrow()
  
  
  glue("{i18n$t('Records in Lab data and BSI forms:')}</br></br>
       <ul>
       <li><em>Escherichia coli</em>: {ecoli_lab} in Lab data and {ecoli_bsi} in BSI forms.</li>
       <li><em>Staphylococcus aureus</em>: {staph_lab} in Lab data and {staph_bsi} in BSI forms.</li>
       </ul>")
})