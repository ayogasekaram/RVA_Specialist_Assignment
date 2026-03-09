# RVA Specialist Coding Assessment
**Candidate:** @ayogasekaram\
**Date:** 2026-03-11
---

## Introduction
This repository contains my solutions to the R Shiny Clinical Data Assessment,
demonstrating skills in clinical data manipulation, reporting, visualization, and interactive dashboards using R.

Datasets used: `pharmaverseadam::ADSL` and `pharmaverseadam::ADAE`
Core tools: {tidyverse}, {gtsummary}, {ggplot2}, {shiny}
---

## Repository Structure
``` text
RVA_Assessment/
├── question_1/
│ ├── question_1.R # Regulatory-compliant TEAE summary table
│ └── teae_summary.html # Output HTML table
├── question_2/
│ ├── question_2.R # AE severity bar chart code
│ └── AE_severity_plot.png # Publication-quality plot
├── question_3/
│ ├── question_3.R # Shiny app integrating AE severity plot
│ └── www/ #static resources (images, CSS)
├── README.md # This file
```

---

## Question 1: TEAE Summary Table
- **Objective:** Create a regulatory-compliant summary of treatment-emergent adverse events (TEAEs).  
- **Data:** `pharmaverseadam::adae` and `pharmaverseadam::adsl`  
- **Requirements:**
  - Include only TEAE records (`TRTEMFL == "Y"`)
  - Rows: System Organ Class (`AESOC`) and Preferred Term (`AEDECOD`)
  - Columns: Treatment groups (`ACTARM`)
  - Cell values: Subject count and percentage of total study population
  - Total row: Summary of all TEAEs at the top
- **Output:** HTML file 

---

## Question 2: AE Severity Visualization
- **Objective:** Generate a publication-quality stacked bar chart of adverse event severity.  
- **Data:** `pharmaverseadam::adae`  
- **Requirements:**
  - X-axis: Count of **unique subjects per SOC per severity** (each subject counted once per severity per SOC)
  - Y-axis: System Organ Class term (`AESOC`)
  - Color/Fill: AE Severity (`AESEV`)
  - Bars stacked and ordered by increasing total frequency per SOC
- **Output:** PNG file created with `{ggplot2}`

---

## Question 3: Interactive R Shiny Application
- **Objective:** Build a Shiny dashboard integrating the AE severity visualization from Question 2.  
- **Requirements:**
  - Display the stacked bar chart from Question 2
  - Add a **Treatment Arm (`ACTARM`) filter** via `selectInput` or `checkboxGroupInput`
  - Chart updates dynamically based on user selection
- **Output:** Interactive Shiny app implemented using `{shiny}`

---

## Getting Started
1. **Install Required Packages**
```r
install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "ggplot2", "shiny"))
```

2. **Run Shiny App**
```r
# From question_3 folder
shiny::runApp("question_3.R")
```

------------------------------------------------------------------------

# Repo Walk-Through Video

Video can be found [here](https://drive.google.com/file/d/1BSVvzmRXWbwLwqbHwTl66RFy2O-yd3JI/view?usp=drive_link)

Explains design decisions and coding approach

Demonstrates the outputs for each question

Discusses challenges and learnings