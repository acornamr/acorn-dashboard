output$box_filt_1 <- renderUI({
  div(id = "filter-1", class = "box_filter",
      pickerInput(
        inputId = "Id094",
        label = "Letters:", 
        choices = LETTERS[1:5],
        selected = LETTERS[1:5],
        options = list(
          `actions-box` = TRUE), 
        multiple = TRUE
      )
  )
})

output$box_filt_2 <- renderUI({
  div(id = "filter-2", class = "box_filter",
      awesomeCheckboxGroup("filter_sex", label = "Sex:",
                           choices = c("Male", "Female"), selected = c("Male", "Female"))
  )
})

output$box_filt_3 <- renderUI({
  div(class = "box_filter",
      prettyRadioButtons(inputId = "variable_2",
                         label = "Click me!",
                         choices = c("Click me !", "Me !", "Or me !")),
  )
})

output$box_filt_4 <- renderUI({
  div(class = "box_filter",
      checkboxGroupInput("variable_4", "Variables to show:",
                         c("Cylinders" = "cyl",
                           "Transmission" = "am",
                           "Gears" = "gear"))
  )
})

output$box_filt_5 <- renderUI({
  div(class = "box_filter",
      checkboxGroupInput("variable_5", "Variables to show:",
                         c("Cylinders" = "cyl",
                           "Transmission" = "am",
                           "Gears" = "gear"))
  )
})

output$box_filt_6 <- renderUI({
  div(class = "box_filter",
      checkboxGroupInput("variable_6", "Variables to show:",
                         c("Cylinders" = "cyl",
                           "Transmission" = "am",
                           "Gears" = "gear"))
  )
})