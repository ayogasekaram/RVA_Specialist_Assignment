########################################################################
# Question 1: TEAE Summary Table
# Author: Abinaya Yogasekaram
# Purpose: Create a regulatory compliant summary table of Treatment-Emergent 
#          Adverse Events
#          using ADAE dataset and {gtsummary.
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
#    - Rows: AEDECOD or AESOC
#    - Columns: Treatment groups (ACTARM)
#    - Include counts, percentages, total row
########################################################################

# ---- Load Libraries ----------------------------------------------------------
library(dplyr)
library(gtsummary)
library(crane)

# ---- Load data ---------------------------------------------------------------
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# ---- Data Pre-Processing -----------------------------------------------------

# Setting the table rendering theme to "Roche" from {crane}. 
crane::theme_gtsummary_roche()

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
    id = USUBJID,
    denominator = adsl, # subject level dataset for the denominator
    statistic = everything() ~ "{n} ({p}%)", 
    overall_row = TRUE, # Add a row with all subjects
    label = list("..ard_hierarchical_overall.." ~ "Treatment Emergent Adverse Events", # label the overall row
    AESOC = "System Organ Class",
    AEDECOD = "Preferred Term")
  ) |>
  sort_hierarchical() |> # sorting by descending frequency
  modify_caption("Summary of Treatment-Emergent Adverse Events (Safety Population)") # adding a title

tbl

# ---- Export to html ----------------------------------------------------------
tbl |>
  as_gt() |>
  gt::gtsave("teae_summary_table.html")
