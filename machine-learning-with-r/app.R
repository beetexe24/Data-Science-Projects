# California Housing Dashboard — Shiny App
# ---------------------------------------------------------
# Dataset: housing.csv (from "Machine Learning in R" / California Housing data)
# Visualizations:
#   1. Count of homes by ocean_proximity category
#   2. Population vs Households (scatter)
#   3. Total Rooms vs Total Bedrooms (scatter)
# Interactive functions: ocean_proximity filter, point-opacity/sample-size
# slider, and a toggle for adding a linear trend line to the scatter plots.
# ---------------------------------------------------------

# Install packages if needed:
# install.packages(c("shiny", "shinydashboard", "ggplot2"))

library(shiny)
library(shinydashboard)
library(ggplot2)

housing <- read.csv("housing.csv", stringsAsFactors = FALSE)
housing$ocean_proximity <- as.factor(housing$ocean_proximity)
proximity_levels <- levels(housing$ocean_proximity)

# ---------------------------
# UI
# ---------------------------
ui <- dashboardPage(
  dashboardHeader(title = "California Housing Dashboard"),

  dashboardSidebar(
    selectInput(
      inputId = "proximity_filter",
      label = "Filter by Ocean Proximity:",
      choices = c("All", proximity_levels),
      selected = "All"
    ),
    sliderInput(
      inputId = "point_alpha",
      label = "Scatter plot point opacity:",
      min = 0.05, max = 1, value = 0.3, step = 0.05
    ),
    checkboxInput(
      inputId = "show_trend",
      label = "Show linear trend line",
      value = TRUE
    )
  ),

  dashboardBody(
    fluidRow(
      box(title = "Homes by Ocean Proximity", status = "primary", solidHeader = TRUE,
          plotOutput("proximityBar"), width = 12)
    ),
    fluidRow(
      box(title = "Population vs Households", status = "primary", solidHeader = TRUE,
          plotOutput("popHouseholdPlot"), width = 6),
      box(title = "Total Rooms vs Total Bedrooms", status = "primary", solidHeader = TRUE,
          plotOutput("roomsBedroomsPlot"), width = 6)
    ),
    fluidRow(
      box(title = "Summary Statistics", status = "info", solidHeader = TRUE,
          tableOutput("summaryTable"), width = 12)
    )
  )
)

# ---------------------------
# Server
# ---------------------------
server <- function(input, output) {

  # Reactive: filter by ocean proximity
  filteredData <- reactive({
    if (input$proximity_filter == "All") {
      housing
    } else {
      subset(housing, ocean_proximity == input$proximity_filter)
    }
  })

  # Visualization 1: Count of homes by ocean_proximity
  output$proximityBar <- renderPlot({
    ggplot(housing, aes(x = ocean_proximity, fill = ocean_proximity)) +
      geom_bar() +
      geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.4, size = 4.5) +
      theme_minimal(base_size = 14) +
      labs(title = "Number of Homes by Ocean Proximity",
           x = "Ocean Proximity", y = "Number of Homes") +
      theme(legend.position = "none")
  })

  # Visualization 2: Population vs Households
  output$popHouseholdPlot <- renderPlot({
    p <- ggplot(filteredData(), aes(x = households, y = population, color = ocean_proximity)) +
      geom_point(alpha = input$point_alpha) +
      theme_minimal(base_size = 14) +
      labs(title = "Population vs Households", x = "Households", y = "Population")

    if (input$show_trend) {
      p <- p + geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.8)
    }
    p
  })

  # Visualization 3: Total Rooms vs Total Bedrooms
  output$roomsBedroomsPlot <- renderPlot({
    p <- ggplot(filteredData(), aes(x = total_rooms, y = total_bedrooms, color = ocean_proximity)) +
      geom_point(alpha = input$point_alpha) +
      theme_minimal(base_size = 14) +
      labs(title = "Total Rooms vs Total Bedrooms", x = "Total Rooms", y = "Total Bedrooms")

    if (input$show_trend) {
      p <- p + geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.8)
    }
    p
  })

  # Summary table
  output$summaryTable <- renderTable({
    df <- filteredData()
    data.frame(
      Metric = c("Number of Homes", "Avg Population", "Avg Households",
                 "Avg Total Rooms", "Avg Total Bedrooms", "Avg Median House Value"),
      Value = c(
        nrow(df),
        round(mean(df$population, na.rm = TRUE), 1),
        round(mean(df$households, na.rm = TRUE), 1),
        round(mean(df$total_rooms, na.rm = TRUE), 1),
        round(mean(df$total_bedrooms, na.rm = TRUE), 1),
        round(mean(df$median_house_value, na.rm = TRUE), 2)
      )
    )
  })
}

# ---------------------------
# Run app
# ---------------------------
shinyApp(ui = ui, server = server)
