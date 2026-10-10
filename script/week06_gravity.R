library(tidyverse)
library(skimr)
library(janitor)

gravity_small <- read_csv("data/gravity_small.csv")

# 1. 수출상대국 순위와 비중의 변화

gravity_small |> 
  filter(country_id_o == "KOR") |> 
  group_by(year) |> 
  slice_max(tradeflow_comtrade_o) |> 
  select(year, country_id_d) |> 
  print(n = Inf)


gravity_small |> 
  filter(country_id_o == "KOR") |> 
  group_by(year) |> 
  slice_max(tradeflow_comtrade_o, n = 3, with_ties = FALSE) |> # 상위 5개 추출
  mutate(rank = row_number()) |> # 1부터 5까지의 순번 부여
  select(year, rank, country_id_d) |> 
  pivot_wider(names_from = rank, values_from = country_id_d) |> 
  print(n = Inf)

gravity_small |> 
  filter(country_id_o == "KOR") |> 
  group_by(year) |> 
  # 1. 연도별 전체 수출액 합계와 1등 국가의 정보(이름, 수출액)를 함께 구함
  mutate(
    total_trade = sum(tradeflow_comtrade_o, na.rm = TRUE),
    share = (tradeflow_comtrade_o / total_trade) * 100 # 비중 계산 (%)
  ) |> 
  slice_max(tradeflow_comtrade_o, n = 1, with_ties = FALSE) |> 
  select(year, country_id_d, tradeflow_comtrade_o, share) |> 
  ggplot(aes(x = year, y = share)) +
  geom_point() +
  geom_line()

gravity_small |> 
  filter(country_id_o == "KOR") |> 
  group_by(year) |> 
  summarize(total = sum(tradeflow_comtrade_o, na.rm = T),
            hhi   = sum((tradeflow_comtrade_o/total)^2, na.rm = T)
  ) |> 
  ggplot(aes(x = year, y = hhi)) +
  geom_point() +
  geom_line()

  
