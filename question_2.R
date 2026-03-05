########################################################################
# Question 4: TLG - Adverse Events Reporting
# Author: Abinaya Yogasekaram
# Purpose: Create Graphs for Adverse Events
#          using ADAE dataset and {ggplot2}.
# Input:
#   - pharmaverseadam::adae  : Adverse Events dataset

# Output:
#   - AE visualizations (PNG files)
#
# Workflow:
# 1. Data Preprocessing
# 2. Visualizations
#    - Plot 1: AE severity distribution by treatment (bar chart / heatmap)
#    - Plot 2: Top 10 most frequent AEs with 95% CI for incidence rates
########################################################################

# ====================================================================
# PLOT 1: Stacked Bar Chart - Count (uses nestcolor)
# ====================================================================
# Objective: Create a plot for AE severity distribution by treatment 

# ---- Load Libraries ----------------------------------------------------------
library(ggplot2)
library(dplyr)
library(pharmaverseadam)
library(nestcolor)
library(forcats)

# ---- Load Data ---------------------------------------------------------------
adae <- pharmaverseadam::adae

# ---- Prepare Data ------------------------------------------------------------

# Prepare data for visualization: Within each arm, tally the event severities
ae_severity_summary <- adae %>%
  count(ACTARM, AESEV) %>%
  group_by(ACTARM) %>%
  mutate( # Calculate the count and percentage for each severity, using ACTARM as the denominator
    total = sum(n),
    percentage = (n / total) * 100
  ) %>% 
  ungroup()

# Also calculate overall counts per treatment arm for labels
treatment_totals <- adae %>%
  count(ACTARM, name = "total_aes")

# ---- Create Plot -------------------------------------------------------------

# ====================================================================
# PLOT 1: AE Frequency with 95% CIs
# ====================================================================
# Objective: A plot showing Top 10 most frequent AEs (with 95% CI for incidence rates)

# ---- Load Data ---------------------------------------------------------------
adae <- pharmaverseadam::adae

# ---- Calculate Incidence Rates -----------------------------------------------

# total number of subjects
n_total <- n_distinct(adae$USUBJID)

# incidence rates by AETERM
ae_incidence <- adae %>%
  distinct(USUBJID, AETERM) %>%        # count each subject only once per AE
  count(AETERM, name = "n_events") %>%
  rowwise() %>%
  mutate(
    # Calculate Clopper-Pearson CIs
    bt = list(binom.test(n_events, n_total)), 
    incidence = n_events / n_total,
    ci_lower = bt$conf.int[1],
    ci_upper = bt$conf.int[2],
    incidence_pct = incidence * 100,
    ci_lower_pct = ci_lower * 100,
    ci_upper_pct = ci_upper * 100
  ) %>%
  ungroup() %>%
  select(-bt)

# Select Top 10 AEs by overall incidence
top10_aes <- ae_incidence %>%
  arrange(desc(incidence_pct)) %>%
  slice_head(n = 10) %>% 
  mutate(AETERM = forcats::fct_reorder(AETERM, incidence_pct))  # lowest at bottom

# ---- Create Plot -------------------------------------------------------------

plot2 <- ggplot(top10_aes, aes(x = incidence_pct, y = AETERM)) +
  geom_point(size = 4) +
  geom_errorbarh(aes(xmin = ci_lower_pct, xmax = ci_upper_pct), 
                 width = 0.3, size = 1) +
  geom_text(aes(label = sprintf("%.1f%% (%.1f, %.1f)", 
                                incidence_pct, ci_lower_pct, ci_upper_pct)),
            nudge_x = 2, vjust = -1.0, size = 3.5) +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = sprintf("95%% Clopper-Pearson Confidence Intervals, n = %d subjects", n_total),
    x = "Percentage of Patients (%)",
    y = "Adverse Event Term"
  ) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +  # padding for text
  nestcolor::theme_nest() + # this is used to maintain Roche/NEST aesthetics, if not installed, please comment this line out
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0),
    plot.subtitle = element_text(size = 11, hjust = 0),
    axis.text.y = element_text(size = 10),
    panel.grid.major.y = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )

plot2

# ---- Save Plot ---------------------------------------------------------------
ggsave("top_10_aeterm.png", plot2, 
       width = 10, height = 6, dpi = 300)



# Load required libraries
library(pharmaverseadam)  # for adae dataset
library(dplyr)
library(ggplot2)
library(forcats)

# Step 1: Summarize data
# Count unique subjects per SOC per severity
ae_summary <- adae %>%
  group_by(AESOC, AESEV, USUBJID) %>%
  summarise(.groups = "drop") %>%         # ensure each subject counted once per severity per SOC
  group_by(AESOC, AESEV) %>%
  summarise(Count = n_distinct(USUBJID), .groups = "drop") %>%
  ungroup()

# Step 2: Compute total per SOC for ordering
soc_totals <- ae_summary %>%
  group_by(AESOC) %>%
  summarise(Total = sum(Count)) %>%
  arrange(Total)

# Step 3: Convert AESOC to factor ordered by increasing total
ae_summary <- ae_summary %>%
  mutate(AESOC = factor(AESOC, levels = soc_totals$AESOC))

# Step 4: Create stacked bar chart
p <- ggplot(ae_summary, aes(x = Count, y = AESOC, fill = AESEV)) +
  geom_col() +
  scale_fill_brewer(palette = "Set2") +  # good publication-quality colors
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

# Step 5: Save as PNG
ggsave("adverse_events_distribution.png", p, width = 10, height = 8, dpi = 300)
