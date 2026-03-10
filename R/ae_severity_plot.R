# Utilities for AE severity SOC plot (Q2 + Q3)

library(dplyr)
library(ggplot2)
library(forcats)

prep_ae_soc_sev <- function(adae, actarm = NULL, teae_only = FALSE) {
  df <- adae
  
  if (!is.null(actarm)) {
    df <- df %>% filter(ACTARM %in% actarm)
  }
  
  if (teae_only) {
    df <- df %>% filter(TRTEMFL == "Y")
  }
  
  df %>%
    distinct(USUBJID, AESOC, AESEV) %>%
    mutate(
      AESEV = fct_explicit_na(AESEV, na_level = "MISSING"),
      AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE", "MISSING"))
    ) %>%
    count(AESOC, AESEV, name = "n") %>%
    group_by(AESOC) %>%
    mutate(total_soc = sum(n)) %>%
    ungroup() %>%
    mutate(AESOC = fct_reorder(AESOC, total_soc))
}

plot_ae_soc_sev <- function(ae_summary) {
  ggplot(ae_summary, aes(x = n, y = AESOC, fill = AESEV)) +
    geom_col(position = position_stack(reverse = TRUE)) +
    scale_fill_manual(
      values = c(
        "MILD" = "#C7E9C0",
        "MODERATE" = "#74C476",
        "SEVERE" = "#238B45",
        "MISSING" = "grey70"
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