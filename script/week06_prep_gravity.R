library(tidyverse)
library(skimr)
library(janitor)

library(data.table)


gravity <- fread("D:/@Teaching/Econometrics II/resources/CEPII/Gravity_csv_V202211/Gravity_V202211.csv")

#gravity <- fread("C:/Users/Heechul/Documents/Gravity_csv_V202211/Gravity_V202211.csv")

gravity_small <- gravity |> 
  filter(year >= 1980, year <= 2020, country_exists_o == 1, country_exists_d == 1, country_id_o != country_id_d) |> 
  select(year, country_id_o, country_id_d, 
         contig, dist, comlang_off, gdp_o, gdp_d, fta_wto, 
         tradeflow_comtrade_o, tradeflow_comtrade_d)

# countries <- fread("D:/@Teaching/Econometrics II/resources/CEPII/Gravity_csv_V202211/Countries_V202211.csv")
# 
# countries <- countries |> 
#   select(country_id, country)
# 
# gravity_small <- gravity |> 
#   left_join(countries, by = c("country_id_o" = "country_id")) |> 
#   rename(country_o = country) |> 
#   left_join(countries, by = c("country_id_d" = "country_id")) |> 
#   rename(country_d = country) 
  
write_csv(gravity_small, "data/gravity_small.csv")



