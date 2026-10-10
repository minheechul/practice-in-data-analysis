library(tidyverse)
library(skimr)
library(janitor)

library(data.table)


#gravity <- fread("D:/@Teaching/Econometrics II/resources/CEPII/Gravity_csv_V202211/Gravity_V202211.csv")

gravity <- fread("C:/Users/Heechul/Documents/Gravity_csv_V202211/Gravity_V202211.csv")

gravity_small <- gravity |> 
  filter(year >= 1980, year <= 2020, country_exists_o == 1, country_exists_d == 1) |> 
  select(year, country_id_o, country_id_d, 
         contig, dist, comlang_off, gdp_o, gdp_d, fta_wto, 
         tradeflow_comtrade_o, tradeflow_comtrade_d)

write_csv(gravity_small, "data/gravity_small.csv")



