# RVA Specialist Coding Assessment
**Candidate:** @ayogasekaram  
**Date:** 2026-03-11  
**R version tested:** R 4.2.0+  

## Introduction
This repository contains my solutions to the **R Shiny Clinical Data Assessment**, demonstrating clinical data manipulation, reporting, visualization, and interactive dashboard development in R.

- **Datasets:** `pharmaverseadam::adsl`, `pharmaverseadam::adae`  
- **Core tools:** `{tidyverse}`, `{gtsummary}`, `{ggplot2}`, `{shiny}`  

## Repository Structure
```text
RVA_specialist_assessment/
├── R/
│   └── ae_severity_plot.R
├── question_1/
│   ├── question_1.R
│   └── teae_summary.html
├── question_2/
│   ├── question_2.R
│   └── ae_severity_plot.png
├── question_3/
│   └── question_3.R
└── README.md
```

**Shared code:** `R/ae_severity_plot.R` contains helper functions reused in **Question 2** and **Question 3** to ensure consistent derivations and plotting.

## Question 1: TEAE Summary Table
- **Objective:** Create a regulatory-compliant summary of treatment-emergent adverse events (TEAEs).  
- **Data:** `pharmaverseadam::adae` and `pharmaverseadam::adsl`  
- **Key requirements implemented:**
  - TEAE records only (`TRTEMFL == "Y"`)
  - Rows: `AESOC` and `AEDECOD`
  - Columns: `ACTARM`
  - Cell values: unique subject count and percentage using the **total ADSL population** as denominator
  - Includes a **Total TEAE** summary row at the top
- **Output:** `question_1/teae_summary.html`

## Question 2: AE Severity Visualization
- **Objective:** Publication-quality stacked bar chart of AE severity distribution.  
- **Data:** `pharmaverseadam::adae`  
- **Key requirements implemented:**
  - Counts **unique subjects per SOC per severity** (each subject counted once per `(AESOC, AESEV)`)
  - Y-axis: `AESOC`
  - Fill: `AESEV`
  - SOC ordering: increasing total frequency per SOC
- **Output:** `question_2/ae_severity_plot.png`

## Question 3: Interactive R Shiny Application
- **Objective:** Shiny dashboard integrating the visualization from Question 2.  
- **Key requirements implemented:**
  - Displays the SOC x Severity stacked bar chart
  - Filter by Treatment Arm (`ACTARM`)
  - Plot updates dynamically based on user selection
  - (If implemented) optional TEAE-only toggle (`TRTEMFL == "Y"`)
- **Run location:** `question_3/question_3.R`

## Getting Started

### 1) Install Required Packages
```r
install.packages(c(
  "pharmaverseadam",
  "tidyverse",
  "gtsummary",
  "ggplot2",
  "shiny",
  "shinydashboard",
  "forcats"
))
```

### 2) Run scripts (recommended from repo root)
```r
source("question_1/question_1.R")
source("question_2/question_2.R")
```

### 3) Run the Shiny App (recommended from repo root)
```r
shiny::runApp("question_3")
```

## Repo Walk-Through Video
Video walk through can be found [here](https://drive.google.com/file/d/1BSVvzmRXWbwLwqbHwTl66RFy2O-yd3JI/view?usp=drive_link)

The video covers:
- repository structure
- approach and design decisions
- demonstration of outputs for each question
- challenges and learnings