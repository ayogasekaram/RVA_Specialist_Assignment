########################################################################
# Question 1: TEAE Summary Table
# Author: Abinaya Yogasekaram
# Date: 2026-03-11
# Purpose: Create a regulatory compliant summary table of Treatment-Emergent 
#          Adverse Events
#          using ADAE dataset and {gtsummary}.
# Input:
#   - pharmaverseadam::adae  : Adverse Events dataset
#   - pharmaverseadam::adsl  : Subject-Level dataset
# Output:
#   - AE summary table (HTML)
#
# Workflow:
# 1. Summary Table
#    - Create a treatment-emergent AE (TEAE) table using {gtsummary}
#    - Filter: TRTEMFL == "Y"
#    - Rows: AEDECOD and AESOC
#    - Columns: Treatment groups (ACTARM)
#    - Include counts, percentages, total row
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(pharmaverseadam)
library(dplyr)
library(gtsummary)
library(crane)

# Setting the table rendering theme to "Roche" from {crane}. 
crane::theme_gtsummary_roche()

# ---- Load data ---------------------------------------------------------------
adsl <- pharmaverseadam::adsl # subject level data for denominator
adae <- pharmaverseadam::adae

# ---- Data Preparation --------------------------------------------------------

adae_sub <- adae |>
  filter(
    # safety population
    SAFFL == "Y",
    # treatment emergent adverse events
    TRTEMFL == "Y"
  )

# ---- Create the table --------------------------------------------------------
tbl <- adae_sub |>
  tbl_hierarchical(
    variables = c(AESOC, AEDECOD),
    by = ACTARM,
    id = USUBJID, # counts represent unique subjects
    denominator = adsl, # subject level data set for the denominator
    statistic = everything() ~ "{n} ({p}%)", 
    overall_row = TRUE, # Add a row with all subjects
    label = list(
      "..ard_hierarchical_overall.." ~ "Treatment Emergent Adverse Events", # label the overall row
      AESOC = "System Organ Class",
      AEDECOD = "Preferred Term"
      )
  ) |>
  sort_hierarchical() |> # sorting by descending frequency
  modify_caption("Summary of Treatment-Emergent Adverse Events by System Organ Class and Preferred Term (Safety Population)") |>
  modify_footnote(
    everything() ~ "n = number of subjects with at least one event; percentages based on total subjects in the safety population."
  )

tbl

# ---- Export to html ----------------------------------------------------------
tbl |>
  as_gt() |>
  gt::gtsave("../question_1/teae_summary.html")
