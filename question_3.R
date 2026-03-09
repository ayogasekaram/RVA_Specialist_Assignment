########################################################################
# Question 3: AE Severity {Shiny} Visualization
# Author: Abinaya Yogasekaram
# Purpose: Create an interactive {Shiny} dashboard with a quality bar 
#          chart visualizing the distribution of adverse events using 
#          {ggplot2}. Allow for filtering by treatment arm.
# Input:
#   - pharmaverseadam::adae  : Adverse Events dataset
#
# Output:
#   - AE visualization
#
# Workflow:
# 1. Set up dashboard UI
# 2. Set up dashboard server
########################################################################

# Load libraries
library(shiny)
library(shinydashboard)
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(forcats)

# UI
ui <- dashboardPage(
  
  dashboardHeader(title = "AE Summary Interactive Dashboard"),
  
  dashboardSidebar( # Set treatment arm filter in the sidebar
    width = 220,
    
    checkboxGroupInput(
      inputId = "arm_filter",
      label = "Select Treatment Arm(s)",
      choices = unique(adae$ACTARM),
      selected = unique(adae$ACTARM)
    )
  ),
  
  dashboardBody(
    
    fluidRow(
      box(
        width = 12,
        title = "Adverse Events by SOC and Severity",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        plotOutput("ae_barplot", height = "700px")
      )
    )
    
  )
)

# Server
server <- function(input, output, session) {
  
  # Filter data based on selected treatment arms
  filtered_data <- reactive({
    req(input$arm_filter)
    adae %>%
      filter(ACTARM %in% input$arm_filter)
  })
  
  # Summarize filtered AE data
  summarized_data <- reactive({
    
    filtered_data() %>%
      distinct(AESOC, AESEV, USUBJID) %>%
      count(AESOC, AESEV, name = "Count") %>%
      mutate(AESOC = fct_reorder(AESOC, Count, .fun = sum))
    
  })
  
  # Plot
  output$ae_barplot <- renderPlot({
    
    # return a message if no treatment arm selected
    validate(
      need(length(input$arm_filter) > 0,
           "Please select a Treatment arm to display the plot")
    )
    
    df <- summarized_data()
    
    # message if filters result in no data
    validate(
      need(nrow(df) > 0,
           "No adverse event data available for the selected filters")
    )
    
    ggplot(df, aes(x = Count, y = AESOC, fill = AESEV)) +
      geom_col(position = position_stack(reverse = TRUE)) +
      scale_fill_brewer(palette = "Greens") +
      labs(
        x = "Number of Unique Subjects",
        y = "System Organ Class (SOC)",
        fill = "AE Severity",
        title = "Distribution of Adverse Events by SOC and Severity"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 11)
      )
  })
}

# Run app
shinyApp(ui, server)
