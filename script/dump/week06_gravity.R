library(tidyverse)
library(skimr)
library(janitor)

# 2.1 데이터 준비

gravity_small <- read_csv("large_data/gravity_small.csv")

df_kor <- gravity_small |> 
  filter(country_id_o == "KOR")

df_kor_2020 <- gravity_small |> 
  filter(country_id_o == "KOR", year == 2020) 

skim(df_kor)
skim(df_kor_2020)

# 2.2 미러 불일치

df_kor_2020 |> 
  ggplot(aes(x = tradeflow_comtrade_o,
             y = tradeflow_comtrade_d)
  ) +
  scale_x_log10() +
  scale_y_log10() +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  coord_cartesian(xlim = c(1e+1, 1e9), ylim = c(1e+1, 1e9)) +
  labs(
    title = "우리나라 보고 수출액과 상대국 보고 수입액의 비교",
    x = "한국 보고 수출액 (천 달러)",
    y = "상대국 보고 수입액 (천 달러)"
  )

df_kor_2020 |> 
  mutate(gap = log(tradeflow_comtrade_d/tradeflow_comtrade_o)) |> 
  ggplot(aes(x = gap)) +
  geom_histogram(breaks = seq(-6, 4, by = 0.5)) +
  labs(
    title = "거울 데이터 불일치 (Gap)의 분포",
    x = "Gap: 로그(상대국수입액/한국수출액)",
  )

df_kor_2020 |> 
  mutate(gap = log(tradeflow_comtrade_d/tradeflow_comtrade_o)) |> 
  select(gap) |> 
  skim()

# df_kor_2020 |> 
#   mutate(o_na = is.na(tradeflow_comtrade_o),
#          d_na = is.na(tradeflow_comtrade_d)) |> 
#   tabyl(o_na, d_na)

# df_kor_2020 |> 
#   filter(is.na(tradeflow_comtrade_o) | 
#          is.na(tradeflow_comtrade_d)) |> 
#   pull(country_id_d)  


# 2.3 우리나라의 주요 수출 상대국의 변화

df_kor |> 
  group_by(year) |> 
  slice_max(tradeflow_comtrade_o, n = 3, with_ties = FALSE) |> # 상위 3개 추출
  mutate(rank = row_number()) |> # 1부터 3까지의 순번 부여
  select(year, rank, country_id_d) |> 
  pivot_wider(names_from = rank, values_from = country_id_d) |> 
  print(n = Inf)


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

df_kor |> 
  group_by(year) |> 
  mutate(
    total_trade = sum(tradeflow_comtrade_o, na.rm = TRUE),
    share = (tradeflow_comtrade_o / total_trade) * 100 ) |> 
  summarize(hhi = sum(share^2, na.rm = TRUE)) |>
  ggplot(aes(x = year, y = hhi)) +
  geom_point() +
  geom_line() +
  labs(title = "Export Market Concentration (HHI)", y = "HHI", x = "Year")

# 2.4 중력모형의 기본 형태

df_kor_2020 |> 
  ggplot(aes(x = log(gdp_d), y = log(tradeflow_comtrade_o))) +
  geom_point() +
  labs(
    title = "상대국 GDP별 한국의 수출액",
    x = "상대국 로그 GDP",
    y = "로그 수출액"
  )  


df_kor_2020 |> 
  ggplot(aes(x = log(dist), y = log(tradeflow_comtrade_o))) +
  geom_point() +
  labs(
    title = "거리별 한국의 수출액",
    x = "로그 거리",
    y = "로그 수출액"
  )


# 2.5 plotly

library(plotly)

## Hover

p1 <- df_kor_2020 |> 
  ggplot(aes(x = log(gdp_d), y = log(tradeflow_comtrade_o), text = country_id_d)) +
  geom_point() +
  labs(
    title = "상대국 GDP별 한국의 수출액",
    x = "상대국 로그 GDP",
    y = "로그 수출액"
  ) 

ggplotly(p1, tooltip = "text")

## Toggling legends

p2 <- df_kor |> 
  filter(year %in% c(1980, 2000, 2020)) |>
  ggplot(aes(x = log(gdp_d), y = log(tradeflow_comtrade_o), color = as.factor(year))) +
  geom_point() +
  labs(
    title = "연도별 상대국 GDP와 한국의 수출액",
    x = "상대국 로그 GDP",
    y = "로그 수출액",
    color = "연도"
  ) 

ggplotly(p2)

## Animation

p3 <- df_kor |> 
  filter(country_id_d %in% c("USA","CHN","JPN"), year >= 1990) |> 
  ggplot(aes(x = gdp_d, y = tradeflow_comtrade_o, frame = year, 
             ids = country_id_d, color = country_id_d)) +
  geom_point() +
  labs(
    title = "미국, 중국, 일본의 GDP와 한국의 수출액 (1990 ~ 2020)",
    x = "상대국 GDP (천 달러)",
    y = "한국의 수출액 (천 달러)",
    color = "상대국"
  ) 

ggplotly(p3)


# 2.6 FTA

df_fta <- df_kor_2020 |> 
  mutate(fta_wto = factor(fta_wto, levels = c(0, 1), labels = c("미체결", "체결")),
         tradeflow_filled_o = replace_na(tradeflow_comtrade_o, 0)
  ) 

df_fta |>
  tabyl(fta_wto) |>
  adorn_pct_formatting(digits = 1) 

df_fta |>
  group_by(fta_wto) |> 
  summarize(
    n_raw = sum(!is.na(tradeflow_comtrade_o)),
    mean_raw = mean(tradeflow_comtrade_o, na.rm = TRUE),
    n_filled = sum(!is.na(tradeflow_filled_o)),
    mean_filled = mean(tradeflow_filled_o, na.rm = TRUE)
  ) 

t.test(tradeflow_comtrade_o~fta_wto, data = df_fta)  
t.test(tradeflow_filled_o~fta_wto, data = df_fta)  


# 3.1 데이터 준비

df <- read_csv("data/baci_kor_import_hs2.csv",
               col_types = "iiicd") # t, i, j (integer), hs2 (character), v (double)

hs2_label <- tribble(
  ~hs2, ~hs2_label,
  "29", "유기화학물",
  "39", "플라스틱",
  "72", "철강",
  "84", "일반기계",
  "85", "전기전자",
  "90", "정밀기기"
)


# 3.2 대일 수입 품목의 구성과 비중

df_jpn <- df |>
  filter(i == 392)     # 일본 국가기호: 392

yrs <- c(1995, 2000, 2005, 2010, 2015, 2020, 2024)

df_jpn |> 
  filter(t %in% yrs) |> 
  left_join(hs2_label, by = "hs2") |> 
  group_by(t) |>
  mutate(share = v / sum(v)) |> 
  slice_max(v, n = 5, with_ties = FALSE) |>
  mutate(rank = row_number()) |>
  select(t, rank, hs2_label) |> 
  pivot_wider(names_from = rank, values_from = hs2_label, names_prefix = "rank") 

df_jpn |> 
  group_by(t) |>
  mutate(share = v / sum(v) * 100) |> 
  slice_max(v, n = 5, with_ties = FALSE) |>
  summarize(cum_share = sum(share),
            cum_value = sum(v)) |> 
  ggplot(aes(x = t, y = cum_share)) +
  geom_line() +
  geom_point() +
  labs(title = "대일 수입 상위 5개 품목의 점유율 합계 (HS1992 2자리 기준)",
       x = "연도",
       y = "상위 5개 품목 점유율 합계 (%)"
  )

# 3.3 품목별 수입의 대일 의존도

top5 <- df |>
  filter(i == 392, t == 2024) |>
  slice_max(v, n = 5, with_ties = FALSE) |>
  pull(hs2)

df_dep <- df |>
  filter(hs2 %in% top5) |>
  group_by(t, hs2) |> 
  summarise(v_all     = sum(v),
            v_jpn     = sum(v[i == 392]),
            share_jpn = v_jpn / v_all * 100) |> 
  left_join(hs2_label, by = "hs2") 

df_dep |> 
  ggplot(aes(x = t, y = share_jpn, color = hs2_label)) +
  geom_line() +
  geom_point() +
  labs(
    title = "품목별 대일 의존도의 변화",
    y = "품목별 일본산 수입 / 전체 수입 (%)",
    x = "연도",
    color = "품목"
  )  

