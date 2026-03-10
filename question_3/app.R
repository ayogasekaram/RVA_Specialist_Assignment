########################################################################
# Question 3: AE Severity {Shiny} Visualization
# Author: Abinaya Yogasekaram
#
# Purpose:
# Create an interactive {Shiny} dashboard visualizing the distribution
# of adverse events by System Organ Class and Severity.
#
# Users can filter results by Treatment Arm.
#
# Input:
#   pharmaverseadam::adae  (Adverse Events dataset)
#
# Key Clinical Rule:
# Each subject must be counted at most once per SOC and severity level.
#
# Output:
#   Interactive bar chart
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(shiny)
library(shinydashboard)
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(forcats)

# ---- Load Data ---------------------------------------------------------------

adae <- pharmaverseadam::adae

# ---- UI ----------------------------------------------------------------------

ui <- dashboardPage(
  
  dashboardHeader(title = "AE Summary Interactive Dashboard"),
  
  dashboardSidebar(
    width = 220,
    
    checkboxGroupInput(
      inputId = "arm_filter",
      label = "Select Treatment Arm(s)",
      choices = sort(unique(adae$ACTARM)),
      selected = sort(unique(adae$ACTARM))
    ),
    
    br(),
    
    actionButton("select_all", "Select All"),
    actionButton("clear_all", "Clear All")
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

# ---- Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # ---- Select All / Clear All Buttons ---------------------------------------
  
  observeEvent(input$select_all, {
    updateCheckboxGroupInput(
      session,
      "arm_filter",
      selected = sort(unique(adae$ACTARM))
    )
  })
  
  observeEvent(input$clear_all, {
    updateCheckboxGroupInput(
      session,
      "arm_filter",
      selected = character(0)
    )
  })
  
  # ---- Filter Data -----------------------------------------------------------
  
  filtered_data <- reactive({
    
    req(input$arm_filter)
    
    adae %>%
      filter(ACTARM %in% input$arm_filter)
    
  })
  
  # ---- Summarize Data --------------------------------------------------------
  
  summarized_data <- reactive({
    
    filtered_data() %>%
      
      # Each subject counted once per SOC and severity level
      distinct(USUBJID, AESOC, AESEV) %>%
      
      count(AESOC, AESEV, name = "n") %>%
      
      group_by(AESOC) %>%
      mutate(total_soc = sum(n)) %>%
      ungroup() %>%
      
      mutate(
        AESOC = fct_reorder(AESOC, total_soc),
        AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE"))
      )
    
  })
  
  # ---- Plot ------------------------------------------------------------------
  
  output$ae_barplot <- renderPlot({
    
    validate(
      need(length(input$arm_filter) > 0,
           "Please select a treatment arm to display the plot.")
    )
    
    df <- summarized_data()
    
    validate(
      need(nrow(df) > 0,
           "No adverse event data available for the selected filters.")
    )
    
    ggplot(df, aes(x = n, y = AESOC, fill = AESEV)) +
      geom_col(position = position_stack(reverse = TRUE)) +
      scale_fill_brewer(palette = "Greens") +
      labs(
        title = "Distribution of Adverse Events by SOC and Severity",
        x = "Number of Unique Subjects",
        y = "System Organ Class (SOC)",
        fill = "AE Severity"
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

# ---- Run App -----------------------------------------------------------------

shinyApp(ui, server)
