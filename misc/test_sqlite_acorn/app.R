library(shiny)

ui <- fluidPage(
    titlePanel("SQLite ACORN"),

    sidebarLayout(
        sidebarPanel(
          fileInput("file_lab_sql", NULL,  buttonLabel = "Browse for sqlite file", accept = c(".sqlite3", ".sqlite", ".db"))
        ),
        mainPanel(
          DT::dataTableOutput("str")
        )
    )
)

server <- function(input, output) {
  
  dta <- reactive({
    req(input$file_lab_sql)
    path_lab_file <- input$file_lab_sql[[1, 'datapath']]
    dta <- DBI::dbConnect(RSQLite::SQLite(), path_lab_file)
    dta <- as.data.frame(DBI::dbReadTable(dta, "Isolates"))
    return(dta)
  }
  )

  output$str <- DT::renderDT({
    DT::datatable(
    data.frame(
      colnames = names(dta()),
      type     = apply(dta(), 2, typeof),
      random_val_1 = apply(dta(), 2, sample, size = 1),
      random_val_2 = apply(dta(), 2, sample, size = 1)
    ),
    rownames = FALSE,
    filter = "top",
    style = "bootstrap",
    options = list(scrollX = TRUE, scrollY = 600, paging = FALSE, dom = "lrtip")
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
