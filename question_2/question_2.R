########################################################################
# Question 2: AE Severity Visualization
# Author: Abinaya Yogasekaram
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
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(forcats)

# ---- Load Data ---------------------------------------------------------------
adae <- pharmaverseadam::adae

# ---- Prepare Data ------------------------------------------------------------
# Count unique subjects per SOC per severity
ae_summary <- adae %>%
  distinct(USUBJID, AESOC, AESEV) %>% # each subject counted at most once per severity per SOC
  count(AESOC, AESEV, name = "n") %>%
  group_by(AESOC) %>%
  mutate(total_soc = sum(n)) %>%   # total subjects per SOC for ordering
  ungroup() %>%
  mutate(
    AESOC = fct_reorder(AESOC, total_soc), # order the AESOC by their total counts
    AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE"))
  )

# ---- Create Plot -------------------------------------------------------------
ae_severity_plot <- ggplot(ae_summary, aes(x = n, y = AESOC, fill = AESEV)) +
  geom_col(position = position_stack(reverse = TRUE)) + # Ensure the highest density severity is closest to the y axis
  scale_fill_brewer(palette = "Greens") +
  labs(
    title = "Distribution of Adverse Events by Severity and SOC",
    x = "Number of Unique Subjects",
    y = "System Organ Class (SOC)",
    fill = "AE Severity"
  ) +
  theme_minimal(base_size = 10)

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
