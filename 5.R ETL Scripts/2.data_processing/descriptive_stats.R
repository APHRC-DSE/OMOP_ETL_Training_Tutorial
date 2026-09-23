library(dplyr)
library(gtsummary)

my_gtsummary_theme

gtsummary_compact_theme

## Descriptive statistics

descriptive_stats <- 
  gtsummary::tbl_summary(df_clean
                         , include = !c("pid", "wave_id", "interview_date", "date_of_birth", "producer", "interviewer_id")
                         , type = list(
                           all_dichotomous() ~ "categorical"
                           ,all_continuous() ~ "continuous2"
                         )
                         , statistic = list(
                           all_continuous(continuous2 = TRUE) ~ c(
                             "{mean} ({sd})",
                             "{median} ({p25}, {p75})",
                             "{min}, {max}" ),
                           all_categorical() ~ "{n}" #"{n} ({p}%)", "({p}%)"
                         )
                         , digits = list(all_continuous(continuous2 = TRUE) ~ 1, 
                                         all_categorical() ~ c(0, 1)
                         )
                         , percent = "column" #"column", "row", or "cell"
                         , missing = "ifany" #list missing data separately #ifany #no #always
                         , missing_text = "Missing"
                         ) %>% 
  modify_header(label = "**Variables**", all_stat_cols() ~ "**{level}**\n N = {n}"
                # update the column header
                ) %>% 
  bold_labels() %>%
  italicize_levels() %>% 
  add_n( statistic = "{N_nonmiss}", col_label = "**n**", last = FALSE, footnote = FALSE
         # add column with total number of non-missing observations 
         ) %>%
  modify_caption("") %>%
  modify_footnote(all_stat_cols() ~ "n (%); Mean (SD); Median (IQR); Range") %>%
  gtsummary::as_flex_table() 

print(descriptive_stats)

