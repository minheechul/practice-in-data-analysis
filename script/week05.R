library(tidyverse)
library(skimr)
library(janitor)

df <- read_csv("data/수출입 총괄_03074745.csv",
               skip = 1,
               col_names = c("date", "export", "import"))

df <- df |> 
  mutate(date = ym(date)) |> 
  arrange(date)


# =====================================================================
# B. 수준 그림 그리기와 읽기
# =====================================================================
ggplot(df, aes(date, export)) +
  geom_line() +
  labs(title = "월별 수출액 (수준)", x = NULL, y = "수출액 (자료의 단위에 맞게 수정)")

# =====================================================================
# C. lag와 변환
# =====================================================================

# ---- C-1. lag() 도입 ----
# stats::lag 와 이름이 겹치므로 dplyr::lag 로 명시한다
df <- df |>
  mutate(export_l1  = lag(export),        # 1개월 전 값
         export_l12 = lag(export, 12))    # 12개월 전 값

head(df, 14)    

# ---- C-2. 증가율 ----
df <- df |>
  mutate(g_mom = (export / lag(export)     - 1) * 100,   # 전기(전월)대비
         g_yoy = (export / lag(export, 12) - 1) * 100)   # 전년동월대비

df |>
  select(date, g_mom, g_yoy) |>
  pivot_longer(-date, names_to = "type", values_to = "growth") |>
  ggplot(aes(date, growth)) +
  geom_line() +
  facet_wrap(~ type, ncol = 1,
             labeller = as_labeller(c(g_mom = "전월대비 (%)", g_yoy = "전년동월대비 (%)"))) +
  labs(x = NULL, y = NULL)
# 질문: 전년동월대비에서 계절 진동이 줄어드는 이유는?

# ---- C-3. 로그와 로그차분 ----
df <- df |>
  mutate(log_export = log(export),
         dlog      = (log_export - lag(log_export)) * 100)

# 로그차분은 전월대비 증가율의 근사: 증가율이 작을 때 거의 같고, 클수록 벌어진다
df |> select(date, g_mom, dlog) |> slice(2:8)
summary(df$g_mom - df$dlog)          # 차이의 크기

# 수준 / 로그 / 로그차분 나란히 비교
df |>
  select(date, level = export, log = log_export, dlog) |>
  pivot_longer(-date, names_to = "series", values_to = "x") |>
  mutate(series = factor(series, levels = c("level", "log", "dlog"))) |>
  ggplot(aes(date, x)) +
  geom_line() +
  facet_wrap(~ series, ncol = 1, scales = "free_y") +
  labs(x = NULL, y = NULL)
# 확인: 수준에서 커지던 변동폭이 로그에서는 어떻게 보이는가


df <- df |> 
  mutate(ddlog = dlog - lag(dlog))

df |> 
  filter(month(date) == 1) |> 
  select(date, ddlog) |> 
  print(n = 25)


|> 
  summarize(mean(ddlog < 0, na.rm = TRUE)) |> 
  print(digits = 2)
         



# =====================================================================
# D. 요약통계와 구간 비교
# =====================================================================

# 구간 구분 함수: 경계는 예시일 뿐이며 임의로 잡은 것이다
add_period <- function(df) {
  df |>
    mutate(period = case_when(
      date <  as.Date("2008-01-01") ~ "1.위기전",
      date <  as.Date("2010-01-01") ~ "2.금융위기",
      date <  as.Date("2020-01-01") ~ "3.안정기",
      TRUE                          ~ "4.코로나이후"
    ))
}

# ---- 수출액: 전년동월대비 증가율 ----
# 전체 기간
df |>
  drop_na(g_yoy) |>
  summarise(n = n(), mean = mean(g_yoy), sd = sd(g_yoy),
            min = min(g_yoy), max = max(g_yoy))

# 구간별 (NA는 C에서 만든 첫 12개월 때문에 생긴 것 -> drop_na로 제거)
df |>
  drop_na(g_yoy) |>
  add_period() |>
  summarise(n = n(), mean = mean(g_yoy), sd = sd(g_yoy),
            min = min(g_yoy), max = max(g_yoy), .by = period) |>
  arrange(period)

# ---- 주가: 일별 수익률 ----
kospi |>
  drop_na(ret) |>
  add_period() |>
  summarise(n = n(), mean = mean(ret), sd = sd(ret),
            min = min(ret), max = max(ret), .by = period) |>
  arrange(period)

# (선택) 연도별 표준편차: 변동성이 해마다 달라지는 모습
kospi |>
  drop_na(ret) |>
  mutate(year = year(date)) |>
  summarise(sd = sd(ret), .by = year) |>
  ggplot(aes(year, sd)) +
  geom_col() +
  labs(x = NULL, y = "일별 수익률의 표준편차 (%)")


# =====================================================================
# E. 계절성 확인
# =====================================================================

# 월별 평균 전월대비 증가율
df |>
  drop_na(g_mom) |>
  mutate(month = month(date, label = TRUE)) |>
  summarise(mean_g = mean(g_mom), .by = month) |>
  ggplot(aes(month, mean_g)) +
  geom_col() +
  labs(x = NULL, y = "월별 평균 전월대비 증가율 (%)")

# seasonal plot: 연도별 선을 겹쳐 그린다 (최근 10년)
df |>
  mutate(year = year(date), month = month(date, label = TRUE)) |>
  filter(year >= max(year) - 9) |>
  ggplot(aes(month, value, group = year, color = factor(year))) +
  geom_line() +
  labs(x = NULL, y = "수출액", color = "연도")


# =====================================================================
# F. 자기상관
# =====================================================================

# ---- F-1. lag plot: 전월대비 증가율의 lag 1, lag 12 ----
lagdat <- df |>
  mutate(g_l1  = dplyr::lag(g_mom),
         g_l12 = dplyr::lag(g_mom, 12)) |>
  drop_na(g_mom, g_l1, g_l12)          # 세 열 모두 있는 행만 남겨 표본을 맞춘다

lagdat |>
  pivot_longer(c(g_l1, g_l12), names_to = "lag", values_to = "g_lag") |>
  ggplot(aes(g_lag, g_mom)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
  facet_wrap(~ lag, labeller = as_labeller(c(g_l1 = "lag 1", g_l12 = "lag 12"))) +
  labs(x = "과거 값", y = "현재 값")

cor(lagdat$g_mom, lagdat$g_l1)
cor(lagdat$g_mom, lagdat$g_l12)        # 계절 구조가 있으면 lag 12에서 상관이 큼

# ---- F-2. ACF ----
g_mom_vec <- df |> drop_na(g_mom) |> pull(g_mom)
acf(g_mom_vec, lag.max = 36, main = "수출액 전월대비 증가율의 ACF")
# 숫자 벡터를 넣었으므로 x축 lag는 관측치(=개월) 단위: 12, 24, 36 근처에서 튀는가

# ---- F-3. 수준 / 증가율 / 변동성의 대비 ----
# 매크로: 수출액 수준 vs 증가율
level_vec <- df$value
par(mfrow = c(1, 2))
acf(level_vec,   lag.max = 36, main = "수출액 수준")
acf(g_mom_vec,   lag.max = 36, main = "전월대비 증가율")

# 주가: 수준 / 수익률 / 절대수익률
kospi_level <- kospi$value
ret_vec     <- kospi |> drop_na(ret) |> pull(ret)
par(mfrow = c(1, 3))
acf(kospi_level,  lag.max = 60, main = "주가 수준")
acf(ret_vec,      lag.max = 60, main = "수익률")
acf(abs(ret_vec), lag.max = 60, main = "절대수익률")
par(mfrow = c(1, 1))

# (선택) 수익률 히스토그램 + 정규분포 밀도: 두꺼운 꼬리 확인
m <- mean(ret_vec); s <- sd(ret_vec)
kospi |>
  drop_na(ret) |>
  ggplot(aes(ret)) +
  geom_histogram(aes(y = after_stat(density)), bins = 80) +
  stat_function(fun = dnorm, args = list(mean = m, sd = s), color = "red") +
  labs(x = "일별 수익률 (%)", y = "밀도")



