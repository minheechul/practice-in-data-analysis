library(tidyverse)
library(skimr)
library(readxl)

klips27p <- read_excel("data/klips27p.xlsx")

klips27p_small_before_na.omit <- klips27p |> 
  mutate(wage = p271642,
         gender = case_when(
           p270101 == 1 ~ "Male",
           p270101 == 2 ~ "Female",
           .default = NA_character_
         ),
         age = p270107,
         age_group = case_when(
           age >= 1 & age < 30 ~ "Below 30",
           age >= 30 & age < 40 ~ "30s",
           age >= 40 & age < 50 ~ "40s",
           age >= 50 ~ "Above 50",
           .default = NA_character_
         ),
         education = case_when(
           p270110 >= 1 & p270110 <= 5 ~ "High School",
           p270110 >= 6 ~ "College",
           .default = NA_character_
         ),
         job_type = case_when(
           p270317 == 1 ~ "Regular",
           p270317 == 2 ~ "Non-regular",
           .default = NA_character_
         ),
         firm_size = case_when(
           p270403 >= 1 & p270403 <= 4 ~ "Small",
           p270403 >= 5 & p270403 <= 7 ~ "Medium",
           p270403 >= 8 & p270403 <= 10 ~ "Large",
           .default = NA_character_           
         )
  ) |> 
  select(pid, jobclass, wage, gender, age_group, education, job_type)

klips27p_small <- klips27p_small_before_na.omit |> na.omit()

skim(klips27p_small_before)
skim(klips27p_small)
