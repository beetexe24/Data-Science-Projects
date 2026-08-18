# Iris Dashboard — Shiny App
# ---------------------------------------------------------
# A dashboard for the built-in `iris` dataset featuring:
#   1. Scatter plot (with interactive X/Y variable selection)
#   2. Histogram (with interactive bin count slider)
#   3. Boxplot by Species
#   4. A summary table of species means
# Interactive function: species filter + variable selectors + bin slider
# ---------------------------------------------------------

# Install packages if needed:
# install.packages(c("shiny", "shinydashboard", "ggplot2"))

library(shiny)
library(shinydashboard)
library(ggplot2)

data(iris)
numeric_vars <- names(iris)[1:4]

# ---------------------------
# UI
# ---------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Iris Dataset Dashboard"),

  dashboardSidebar(
    selectInput(
      inputId = "species_filter",
      label = "Filter by Species:",
      choices = c("All", levels(iris$Species)),
      selected = "All"
    ),
    selectInput(
      inputId = "xvar",
      label = "X-axis variable:",
      choices = numeric_vars,
      selected = "Sepal.Length"
    ),
    selectInput(
      inputId = "yvar",
      label = "Y-axis variable:",
      choices = numeric_vars,
      selected = "Sepal.Width"
    ),
    sliderInput(
      inputId = "bins",
      label = "Histogram bin count:",
      min = 5, max = 50, value = 20
    )
  ),

  dashboardBody(
    fluidRow(
      box(title = "Scatter Plot", status = "primary", solidHeader = TRUE,
          plotOutput("scatterPlot"), width = 6),
      box(title = "Histogram", status = "primary", solidHeader = TRUE,
          plotOutput("histPlot"), width = 6)
    ),
    fluidRow(
      box(title = "Boxplot by Species", status = "primary", solidHeader = TRUE,
          plotOutput("boxPlot"), width = 12)
    ),
    fluidRow(
      box(title = "Summary Statistics (Mean by Species)", status = "info",
          solidHeader = TRUE, tableOutput("summaryTable"), width = 12)
    )
  )
)

# ---------------------------
# Server
# ---------------------------
server <- function(input, output) {

  # Reactive: filters data based on selected species
  filteredData <- reactive({
    if (input$species_filter == "All") {
      iris
    } else {
      subset(iris, Species == input$species_filter)
    }
  })

  # Visualization 1: Scatter plot
  output$scatterPlot <- renderPlot({
    ggplot(filteredData(), aes_string(x = input$xvar, y = input$yvar, color = "Species")) +
      geom_point(size = 3, alpha = 0.75) +
      theme_minimal(base_size = 14) +
      labs(title = paste(input$yvar, "vs", input$xvar))
  })

  # Visualization 2: Histogram
  output$histPlot <- renderPlot({
    ggplot(filteredData(), aes_string(x = input$xvar, fill = "Species")) +
      geom_histogram(bins = input$bins, alpha = 0.75, position = "identity") +
      theme_minimal(base_size = 14) +
      labs(title = paste("Distribution of", input$xvar))
  })

  # Visualization 3: Boxplot
  output$boxPlot <- renderPlot({
    ggplot(filteredData(), aes(x = Species, y = .data[[input$yvar]], fill = Species)) +
      geom_boxplot() +
      theme_minimal(base_size = 14) +
      labs(title = paste("Boxplot of", input$yvar, "by Species"))
  })

  # Summary table
  output$summaryTable <- renderTable({
    agg <- aggregate(filteredData()[, numeric_vars],
                      by = list(Species = filteredData()$Species),
                      FUN = mean)
    agg
  })
}

# ---------------------------
# Run app
# ---------------------------
shinyApp(ui = ui, server = server)
