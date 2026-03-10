# Helpers for AE SOC x Severity plot (Q2 + Q3)
# Deduplication: count each subject once per (AESOC, AESEV). Optional ACTARM + TEAE filters.

library(dplyr)
library(ggplot2)
library(forcats)

#' Summarize unique-subject counts by SOC and severity
#' @param adae ADAE-like data frame with USUBJID, AESOC, AESEV (+ ACTARM/TRTEMFL if filtering)
#' @param actarm Optional vector of ACTARM values to keep
#' @param teae_only If TRUE, keep TRTEMFL == "Y"
#' @return Tibble with AESOC, AESEV, n, total_soc (AESOC reordered by total_soc)
prep_ae_soc_sev <- function(adae, actarm = NULL, teae_only = FALSE) {
  df <- adae
  
  if (!is.null(actarm)) df <- df %>% filter(ACTARM %in% actarm)
  if (isTRUE(teae_only)) df <- df %>% filter(TRTEMFL == "Y")
  
  df %>%
    distinct(USUBJID, AESOC, AESEV) %>%
    mutate(
      AESEV = fct_explicit_na(AESEV, "MISSING"), # making NAs explicit 
      AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE", "MISSING"))
    ) %>%
    count(AESOC, AESEV, name = "n") %>%
    group_by(AESOC) %>%
    mutate(total_soc = sum(n)) %>%
    ungroup() %>%
    mutate(AESOC = fct_reorder(AESOC, total_soc))
}

#' Plot SOC x severity stacked bars
#' @param ae_summary Output of prep_ae_soc_sev()
#' @return ggplot plot
plot_ae_soc_sev <- function(ae_summary) {
  ggplot(ae_summary, aes(x = n, y = AESOC, fill = AESEV)) +
    geom_col(position = position_stack(reverse = TRUE)) +
    scale_fill_manual(
      values = c(
        MILD = "#C7E9C0",
        MODERATE = "#74C476",
        SEVERE = "#238B45",
        MISSING = "grey70"
      ),
      drop = FALSE
    ) +
    labs(
      title = "Distribution of Adverse Events by SOC and Severity",
      x = "Number of Unique Subjects",
      y = "System Organ Class (SOC)",
      fill = "AE Severity"
    ) +
    theme_minimal(base_size = 12)
}