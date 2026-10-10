library(tidyverse)
library(skimr)
library(janitor)

library(data.table)


gravity <- fread("D:/@Teaching/Econometrics II/resources/CEPII/Gravity_csv_V202211/Gravity_V202211.csv")

gravity_small <- gravity |> 
  filter(year >= 2000) |> 
  select(year, country_id_o, country_id_d, country_exists_o, country_exists_d,
         contig, dist, comlang_off, 
         pop_o, pop_d, gdp_o, gdp_d, gdpcap_o, gdpcap_d,
         fta_wto, rta_type,
         tradeflow_comtrade_o, tradeflow_comtrade_d)

write_csv(gravity_small, "data/gravity_small.csv")