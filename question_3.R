# Load libraries
library(shiny)
library(pharmaverseadam)  # adae dataset
library(dplyr)
library(ggplot2)
library(forcats)

# Define UI
ui <- fluidPage(
  titlePanel("Adverse Events by SOC and Severity"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        inputId = "arm_filter",
        label = "Select Treatment Arm(s):",
        choices = unique(adae$ACTARM),
        selected = unique(adae$ACTARM)
      )
    ),
    mainPanel(
      plotOutput("ae_barplot", height = "600px")
    )
  )
)

# Define server
server <- function(input, output, session) {
  
  # Reactive dataset filtered by Treatment Arm
  filtered_data <- reactive({
    req(input$arm_filter)
    adae %>% filter(ACTARM %in% input$arm_filter)
  })
  
  # Reactive summarized data for plotting
  summarized_data <- reactive({
    filtered_data() %>%
      group_by(AESOC, AESEV, USUBJID) %>%
      summarise(.groups = "drop") %>%               # ensure each subject counted once per severity per SOC
      group_by(AESOC, AESEV) %>%
      summarise(Count = n_distinct(USUBJID), .groups = "drop") %>%
      ungroup() %>%
      mutate(AESOC = factor(AESOC, levels = (
        group_by(., AESOC) %>% 
          summarise(Total = sum(Count)) %>% 
          arrange(Total) %>% 
          pull(AESOC)
      )))
  })
  
  # Render reactive plot
  output$ae_barplot <- renderPlot({
    ggplot(summarized_data(), aes(x = Count, y = AESOC, fill = AESEV)) +
      geom_col() +
      scale_fill_brewer(palette = "Set2") +
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

# Run the app
shinyApp(ui, server)
