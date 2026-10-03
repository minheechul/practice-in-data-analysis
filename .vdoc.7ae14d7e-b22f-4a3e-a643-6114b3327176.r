#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| eval: false
#| echo: true
#| code-fold: true
#| code-summary: "R 스크립트 코드 보기/접기"


x <- c(10, 2, 6, 1, 5)
y <- c("apple", "banana", "cranberry", "durian")
z <- c(TRUE, FALSE, TRUE, TRUE)
w <- as.factor(y)

class(x)
class(y)
class(z)
class(w)

length(x)
length(y)
#
#
#
#
#
#
#
#
#
#
#| eval: false
#| echo: true
#| code-fold: true
#| code-summary: "R 스크립트 코드 보기/접기"
#| collpase: true

y[2]
y[c(2, 4)]
y[-3]
y[z]
x[x < 3]
which(y == "banana")
"fig" %in% y
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
library(tidyverse)
library(skimr)
library(janitor)
df <- read_csv("data/수출입 총괄_03074745.csv",
               skip = 1,
               col_names = c("date", "export"))

df <- df |> 
  mutate(date = ym(date)) |> 
  arrange(date)
#
#
#
#
#
#
#
df |>
ggplot(aes(date, export)) +
  geom_line() +
  labs(title = "월별 수출액 (2000년 1월 ~ 2025년 12월)", x = NULL, y = "수출액 (천불)")
#
#
#
#
#
#
#
#
#
#| echo: false
#| 
df2 <- read_csv("data/시장금리(월,분기,년)_03075635.csv",
               skip = 1,
               col_names = c("date", "ktb3y"))

df2 <- df2 |> 
  mutate(date = ym(date)) |> 
  arrange(date)

df2 |>
ggplot(aes(date, ktb3y)) +
  geom_line() +
  labs(title = "국고채 3년 금리 (월평균, 2000년 1월 ~ 2025년 12월)", x = NULL, y = "연 %")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
df <- df |>
  mutate(export_l1  = lag(export),        # 1개월 전 값
         export_l12 = lag(export, 12))    # 12개월 전 값

head(df, 14)    
#
#
#
#
#
df <- df |>
  mutate(g_mom = (export / lag(export)     - 1) * 100) 

df |>
  ggplot(aes(date, g_mom)) +
    geom_line() +
    labs(title = "월별 수출액 증가율", x = NULL, y = "증가율(%)")
#
#
#
#
#
#
#
#
df <- df |>
  mutate(log_export = log(export),
         dlog      = (log_export - lag(log_export)) * 100)

df |>
  ggplot(aes(date, dlog)) +
    geom_line() +
    labs(title = "월별 수출액 로그변화율 (전월 대비)", x = NULL, y = "로그변화율(%)")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
df |>
    mutate(period = case_when(
      date <  as.Date("2008-01-01") ~ "1.위기전",
      date <  as.Date("2010-01-01") ~ "2.금융위기",
      date <  as.Date("2020-01-01") ~ "3.위기후",
      .default = "4.코로나이후"
    )) |>
  group_by(period) |>
  summarise(n = n(), mean = mean(dlog, na.rm = TRUE), sd = sd(dlog, na.rm = TRUE)) |>
  arrange(period)
#
#
#
#
#
#
#
#
#
#
#
#

df |>
  mutate(year = year(date), month = month(date, label = TRUE)) |>
#  filter(year >= max(year) - 9) |>   # 최근 10년 (2016~2025)
  group_by(year) |>
  mutate(dev = (log(export) - mean(log(export))) * 100) |>
  ggplot(aes(month, dev, group = year, color = factor(year))) +
  geom_line() +
  labs(x = NULL, y = "연평균 대비 (%, 로그 기준)") +
  theme(legend.position = "none")  
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
