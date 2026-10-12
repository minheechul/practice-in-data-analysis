library(tidyverse)
library(skimr)
library(janitor)

gravity_small <- read_csv("data/gravity_small.csv")

df_kor <- gravity_small |> 
  filter(country_id_o == "KOR")

df_kor_2020 <- df_kor |> 
  filter(year == 2020) 

# 0. 미러 불일치

# 실습에 쓰실 때의 한 줄
# 한국 기준으로는 217개 상대국이 있지만, 상대국도 보고한 135개만 
# 이 그림에 나온다"는 문장을 실습 코드 위에 넣어 두면 충분합니다. 
# 결측이 임의로 생긴 것이 아니라 상대국의 보고 여부에 따라 생긴다는 
# 점이 학생에게 자료 읽기의 좋은 소재가 됩니다.

skim(df_kor_2020)

df_kor_2020 |> 
  ggplot(aes(x = tradeflow_comtrade_o,
             y = tradeflow_comtrade_d)
  ) +
  scale_x_log10() +
  scale_y_log10() +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  coord_cartesian(xlim = c(1e2, 1e9), ylim = c(1e2, 1e9)) +
  labs(
    x = "한국 보고 수출액 (천 달러)",
    y = "상대국 보고 수입국 (천 달러)"
  )

df_kor_2020 |> 
  mutate(gap = log(tradeflow_comtrade_d/tradeflow_comtrade_o)) |> 
  ggplot(aes(x = gap)) +
  geom_histogram()

df_kor_2020 |> 
  mutate(gap = log(tradeflow_comtrade_d/tradeflow_comtrade_o)) |> 
  select(gap) |> 
  skim()

## 수입국 보고액이 수출국 보고액보다 낮은 국가

## 과제?

## 차트에 없는 국가는 어떤 특징?

df_kor_2020 |> 
  mutate(o_na = is.na(tradeflow_comtrade_o),
         d_na = is.na(tradeflow_comtrade_d)) |> 
  tabyl(o_na, d_na)

df_kor_2020 |> 
  filter(is.na(tradeflow_comtrade_o) | 
         is.na(tradeflow_comtrade_d)) |> 
  pull(country_id_d)

# 1. 수출상대국 순위와 비중의 변화

## 한국의 수출상대국 1위가 매년 어떻게 바뀌었는가?

df_kor |> 
  group_by(year) |> 
  slice_max(tradeflow_comtrade_o) |> 
  select(year, country_id_d) |> 
  print(n = Inf)

## 한국의 수출상대국 top3의 변화

df_kor |> 
  group_by(year) |> 
  slice_max(tradeflow_comtrade_o, n = 3, with_ties = FALSE) |> # 상위 3개 추출
  mutate(rank = row_number()) |> # 1부터 3까지의 순번 부여
  select(year, rank, country_id_d) |> 
  pivot_wider(names_from = rank, values_from = country_id_d) |> 
  print(n = Inf)

## 수출액 1위와 수출 비중, HHI

df_kor_summary <- df_kor |> 
  group_by(year) |> 
  mutate(
    total_trade = sum(tradeflow_comtrade_o, na.rm = TRUE),
    share = (tradeflow_comtrade_o / total_trade) * 100,
    hhi = sum(share^2, na.rm = TRUE)
  ) |> 
  slice_max(tradeflow_comtrade_o, n = 1, with_ties = FALSE) |> 
  select(year, country_id_d, tradeflow_comtrade_o, share, hhi)

df_kor_summary |> 
  ggplot(aes(x = year, y = share)) +
  geom_point() +
  geom_line() +
  labs(title = "Top Partner Trade Share", y = "Share (%)", x = "Year") 


df_kor_summary |> 
  ggplot(aes(x = year, y = hhi)) +
  geom_point() +
  geom_line() +
  labs(title = "Export Market Concentration (HHI)", y = "HHI", x = "Year")

## 미국, 중국, 일본 대상 수출액 비중의 변화

df_kor |> 
  group_by(year) |> 
  mutate(
    total_trade = sum(tradeflow_comtrade_o, na.rm = TRUE),
    share = (tradeflow_comtrade_o / total_trade) * 100) |> 
  filter(country_id_d %in% c("USA", "JPN", "CHN", "VNM.2")) |> 
  ggplot(aes(x = year, y = share, color = country_id_d)) +
  geom_point() +
  geom_line() +
  labs(
    title = "Export Share for Major Partners",
    x = "Year",
    y = "Share (%)",
    color = "Country"
  )

# 00. 2009년 경제 위기 시 상대국별 수출 변화

# 2. Gravity

df_kor_2020 |> 
  ggplot(aes(x = dist, y = tradeflow_comtrade_o)) +
  geom_point() +
  scale_x_log10()+
  scale_y_log10() +
  labs(
    title = "거리별 한국의 수출액",
    x = "거리 (km)",
    y = "수출액 (천 달러)"
  )

df_kor_2020 |> 
  ggplot(aes(x = gdp_d, y = tradeflow_comtrade_o)) +
  geom_point() +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "상대국 GDP별 한국의 수출액",
    x = "상대국 GDP (천 달러)",
    y = "수출액 (천 달러)"
  )  


# 3. Aside (interactive chart: plotly)

library(plotly)

## Hover
  
p1 <- df_kor_2020 |> 
  ggplot(aes(x = gdp_d, y = tradeflow_comtrade_o, text = country_id_d)) +
  geom_point() +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "상대국 GDP별 한국의 수출액",
    x = "상대국 GDP (천 달러)",
    y = "수출액 (천 달러)"
  ) 

ggplotly(p1, tooltip = "text")

## Toggling legends

p2 <- df_kor |> 
  filter(year %in% seq(1980, 2020, by = 20)) |> 
  ggplot(aes(x = gdp_d, y = tradeflow_comtrade_o, color = as.factor(year))) +
  geom_point() +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "연도별 상대국 GDP와 한국의 수출액",
    x = "상대국 GDP (천 달러)",
    y = "수출액 (천 달러)",
    color = "연도"
  ) 
  
ggplotly(p2)

## Animation

p3 <- df_kor |> 
  filter(country_id_d %in% c("USA","CHN","JPN"), year >= 1990) |> 
  ggplot(aes(x = gdp_d, y = tradeflow_comtrade_o, frame = year, 
             ids = country_id_d, color = country_id_d)) +
  geom_point() +
#  scale_x_log10() +
#  scale_y_log10() +  
  labs(
    title = "미국, 중국, 일본의 GDP와 한국의 수출액 (1990 ~ 2020)",
    x = "상대국 GDP (천 달러)",
    y = "수출액 (천 달러)",
    color = "상대국"
  ) 

ggplotly(p3)


# FTA

df_kor_2020 |> 
  tabyl(fta_wto)

df_kor_2020 |> 
  group_by(fta_wto) |> 
  summarize(
    mean = mean(log(tradeflow_comtrade_o), na.rm = TRUE)
  )

t.test(log(tradeflow_comtrade_o)~fta_wto, data = df_kor_2020)  
