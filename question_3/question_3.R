########################################################################
# Question 3: AE Severity {Shiny} Visualization
# Author: Abinaya Yogasekaram
# Date: 2026-03-10
#
# Purpose:
# Interactive {Shiny} dashboard visualizing distribution of adverse events
# by System Organ Class (AESOC) and Severity (AESEV).
#
# Users can filter by Treatment Arm (ACTARM) and optionally restrict to
# Treatment-Emergent AEs (TRTEMFL == "Y").
#
# Input:
#   pharmaverseadam::adae
#
# Key Clinical Rule:
# Each subject must be counted at most once per SOC and severity level.
#
# Shared helpers:
#   prep_ae_soc_sev(), plot_ae_soc_sev() are sourced from:
#     R/ae_severity_plot.R
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(shiny)
library(shinydashboard)
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(forcats)

# ---- Source Shared Helpers ---------------------------------------------------
source("../R/ae_severity_plot.R")

# ---- Load Data ---------------------------------------------------------------
adae <- pharmaverseadam::adae

# ---- UI ----------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "AE Summary Interactive Dashboard"),
  
  dashboardSidebar(
    width = 260,
    
    # arm filter
    checkboxGroupInput(
      inputId = "arm_filter",
      label = "Select Treatment Arm(s)",
      choices = sort(unique(adae$ACTARM)),
      selected = sort(unique(adae$ACTARM))
    ),
    
    # filter treatment emergent only
    checkboxInput(
      inputId = "teae_only",
      label = "Treatment-emergent only (TRTEMFL == 'Y')",
      value = FALSE
    ),
    
    br(),
    
    # buttons to clear all or select all arms
    fluidRow(
      column(width = 6, actionButton("select_all", "Select All")),
      column(width = 6, actionButton("clear_all", "Clear All"))
    ),
    
    br(),
    
    # button to download the plot
    downloadButton("download_png", "Download plot (PNG)")
  ),
  
  # header widgets, number of subjects, socs and rows displayed in the current plot.
  dashboardBody(
    fluidRow(
      valueBoxOutput("n_subjects", width = 4),
      valueBoxOutput("n_socs", width = 4),
      valueBoxOutput("n_rows", width = 4)
    ),
    
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
    updateCheckboxGroupInput(session, "arm_filter", selected = character(0))
  })
  
  # ---- Summarize Data (Reactive) ---------------------------------------------
  summarized_data <- reactive({
    arms <- input$arm_filter
    
    # If none selected, return an empty tibble with expected columns
    if (is.null(arms) || length(arms) == 0) {
      return(tibble(
        AESOC = character(0),
        AESEV = factor(levels = c("MILD", "MODERATE", "SEVERE", "MISSING")),
        n = integer(0),
        total_soc = integer(0)
      ))
    }
    
    # reuse data preparation function from Q2
    prep_ae_soc_sev(
      adae = adae,
      actarm = arms,
      teae_only = input$teae_only
    )
  })
  
  # ---- Value Boxes  ----------------------------------------------------------
  # summarize filtered data for widgets
  # unique subjects
  output$n_subjects <- renderValueBox({
    arms <- input$arm_filter
    if (is.null(arms) || length(arms) == 0) {
      return(valueBox(value = 0, subtitle = "Unique Subjects", icon = icon("users")))
    }
    
    df <- adae %>% filter(ACTARM %in% arms)
    if (isTRUE(input$teae_only)) df <- df %>% filter(TRTEMFL == "Y")
    
    n_subj <- dplyr::n_distinct(df$USUBJID)
    valueBox(value = n_subj, subtitle = "Unique Subjects", icon = icon("users"))
  })
  
  # unique SOCs
  output$n_socs <- renderValueBox({
    df <- summarized_data()
    valueBox(value = dplyr::n_distinct(df$AESOC), subtitle = "SOCs (filtered)", icon = icon("list"))
  })
  
  # number of AEs
  output$n_rows <- renderValueBox({
    df <- summarized_data()
    valueBox(value = nrow(df), subtitle = "SOC x Severity rows", icon = icon("table"))
  })
  
  # ---- Plot ------------------------------------------------------------------
  output$ae_barplot <- renderPlot({
    validate(
      need(!is.null(input$arm_filter) && length(input$arm_filter) > 0,
           "Please select at least one treatment arm to display the plot.")
    )
    
    df <- summarized_data()
    
    validate(
      need(nrow(df) > 0,
           "No adverse event data available for the selected filters.")
    )
    
    # reuse plot function from Q2
    plot_ae_soc_sev(df)
  })
  
  # ---- Download Handler ------------------------------------------------------
  output$download_png <- downloadHandler(
    filename = function() {
      paste0("ae_severity_plot_", Sys.Date(), ".png")
    },
    
    content = function(file) {
      df <- summarized_data()
      
      if (nrow(df) == 0) {
        p <- ggplot() + theme_void() + labs(title = "No data to display for selected filters")
      } else {
        p <- plot_ae_soc_sev(df)
      }
      
      ggsave(
        filename = file,
        plot = p,
        width = 17,
        height = 8,
        dpi = 300
      )
    }
  )
}

# ---- Run App -----------------------------------------------------------------
shinyApp(ui, server)
