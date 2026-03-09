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
# 1. Data Preprocessing : 
# 2. Create Visualizations
#
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
# Deduplicated: each subject counted at most once per severity per SOC
ae_summary_dedup <- adae %>%
  distinct(AESOC, AESEV, USUBJID) %>%  # ensure each subject counted once per SOC + severity
  count(AESOC, AESEV, name = "Count") %>%
  mutate(
    AESOC = forcats::fct_reorder(AESOC, Count, .fun = sum),  # order by total unique subjects
    AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE"))
  )

# Compute total per SOC for ordering
soc_totals_dedup <- ae_summary_dedup %>%
  group_by(AESOC) %>%
  summarise(Total = sum(Count)) %>%
  arrange(Total)

# ---- Create Plot -------------------------------------------------------------

p <- ggplot(ae_summary_dedup, aes(x = Count, y = AESOC, fill = AESEV)) +
  geom_col(position = position_stack(reverse = TRUE)) +
  scale_fill_brewer(palette = "Greens") +  
  labs(
    x = "Number of Unique Subjects",
    y = "System Organ Class (SOC)",
    fill = "AE Severity",
    title = "Unique Subjects per SOC and Severity Level"
  ) +
  theme_minimal(base_size = 8) +
  theme(
    axis.text.y = element_text(size = 8),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8)
  )

p
# ---- Save Plot ---------------------------------------------------------------
ggsave("adverse_events_distribution.png", p, width = 10, height = 8, dpi = 300)
