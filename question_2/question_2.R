########################################################################
# Question 2: AE Severity Visualization
# Author: Abinaya Yogasekaram
# Date: 2026-03-11
# Purpose: Create a publication quality bar chart visualizing the
#          distribution of adverse events using {ggplot2}.
# Input:
#   - pharmaverseadam::adae  : Adverse Events dataset
#
# Output:
#   - AE visualization (PNG file)
#
# Workflow:
# 1. Data Preprocessing
#.    Deduplicate data to ensure each subject is only counted once per (AESOC, AESEV) pair
#     Order the data by highest to lowest count per SOC
#     Summarize the total counts per AESOC for plotting
# 2. Create Visualization
#
# Shared helpers:
#   prep_ae_soc_sev(), plot_ae_soc_sev() are sourced from:
#     R/ae_severity_plot.R
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(forcats)

# ---- Load Data ---------------------------------------------------------------
adae <- pharmaverseadam::adae

# ---- Source Shared Helpers ---------------------------------------------------
source("R/ae_severity_plot.R")

# ---- Prepare Data ------------------------------------------------------------
ae_summary <- prep_ae_soc_sev(adae, teae_only = FALSE)

# ---- Create Plot -------------------------------------------------------------
ae_severity_plot <- plot_ae_soc_sev(ae_summary)

# ---- Display Plot -------------------------------------------------------------
ae_severity_plot

# ---- Save Plot ---------------------------------------------------------------
ggsave(
  filename = "question_2/ae_severity_plot.png", 
  plot = ae_severity_plot, 
  width = 17, 
  height = 8, 
  dpi = 300
  )
