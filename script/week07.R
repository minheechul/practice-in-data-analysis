library(tidyverse)
library(skimr)
library(janitor)
library(broom)      # 회귀분석 결과를 데이터 프레임으로 정리
library(gapminder)

# =====================================================================
# A. 단순회귀: 1인당 GDP와 기대수명 (gapminder, 2007)
# =====================================================================

g07 <- gapminder |>
  filter(year == 2007)

# ---- A-1. 산점도와 회귀선 ----
g07 |>
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "1인당 GDP와 기대수명 (2007)",
       x = "1인당 GDP (달러)", y = "기대수명 (세)")

g07 |>
  ggplot(aes(x = log(gdpPercap), y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "로그 1인당 GDP와 기대수명 (2007)",
       x = "로그 1인당 GDP", y = "기대수명 (세)")

# ---- A-2. 추정 ----
fit1 <- lm(lifeExp ~ log(gdpPercap), data = g07)

fit1                          # 계수만 간단히 출력
summary(fit1)                 # 표준오차, t값, p값, R제곱 등
coef(fit1)                    # 계수 벡터
confint(fit1)                 # 계수의 95% 신뢰구간

tidy(fit1, conf.int = TRUE)   # 계수 표 (데이터 프레임)
glance(fit1)                  # 모형 전체의 요약 (R제곱, 관측치 수 등)

# ---- A-3. 해석을 위한 계산 ----
b <- coef(fit1)[["log(gdpPercap)"]]
b * log(2)                    # 1인당 GDP가 2배가 되면 기대수명은 몇 세 증가?
b * log(1.1)                  # 1인당 GDP가 10% 증가하면?

# ---- A-4. 적합값과 잔차 ----
g07_fit <- augment(fit1, data = g07)   # .fitted, .resid 등이 추가됨

g07_fit |>
  select(country, continent, lifeExp, .fitted, .resid) |>
  slice_min(.resid, n = 5)             # 모형이 가장 과대예측한 국가들

g07_fit |>
  select(country, continent, lifeExp, .fitted, .resid) |>
  slice_max(.resid, n = 5)             # 모형이 가장 과소예측한 국가들

# ---- A-5. 예측 ----
new_gdp <- tibble(gdpPercap = c(1000, 10000, 40000))

predict(fit1, newdata = new_gdp)                           # 점예측
predict(fit1, newdata = new_gdp, interval = "confidence")  # 평균에 대한 신뢰구간
predict(fit1, newdata = new_gdp, interval = "prediction")  # 개별 관측치에 대한 예측구간

# 예측 결과를 그래프로: 신뢰구간(진한 띠)과 예측구간(옅은 띠)
grid <- tibble(gdpPercap = exp(seq(log(300), log(50000), length.out = 100)))

pred <- bind_cols(
  grid,
  as_tibble(predict(fit1, grid, interval = "confidence")),
  as_tibble(predict(fit1, grid, interval = "prediction")) |>
    select(pred_lwr = lwr, pred_upr = upr)
)

ggplot() +
  geom_ribbon(data = pred, aes(x = log(gdpPercap), ymin = pred_lwr, ymax = pred_upr),
              alpha = 0.15) +
  geom_ribbon(data = pred, aes(x = log(gdpPercap), ymin = lwr, ymax = upr),
              alpha = 0.4) +
  geom_line(data = pred, aes(x = log(gdpPercap), y = fit)) +
  geom_point(data = g07, aes(x = log(gdpPercap), y = lifeExp)) +
  labs(x = "로그 1인당 GDP", y = "기대수명 (세)")

# ---- A-6. 잔차 진단 ----
g07_fit |>
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "적합값", y = "잔차")

g07_fit |>
  ggplot(aes(sample = .std.resid)) +
  stat_qq() +
  stat_qq_line() +
  labs(x = "이론적 분위수", y = "표준화 잔차")

# =====================================================================
# B. 다중회귀: KLIPS 임금 (4주차 데이터)
# =====================================================================

klips <- read_csv("data/klips27p_small.csv") |>
  mutate(
    gender    = fct_relevel(gender, "Female", "Male"),
    age_group = fct_relevel(age_group, "Below 30", "30s", "40s", "Above 50"),
    education = fct_relevel(education, "High School", "College"),
    job_type  = fct_relevel(job_type, "Regular", "Non-regular"),
    log_wage  = log(wage)
  )

# ---- B-1. 범주형 변수 하나: 성별 ----
m0 <- lm(wage ~ gender, data = klips)
tidy(m0)                         # 4주차 t-test의 평균 차이와 같은 값
t.test(wage ~ gender, data = klips)

m1 <- lm(log_wage ~ gender, data = klips)
tidy(m1, conf.int = TRUE)
exp(coef(m1)[["genderMale"]]) - 1      # 남성 임금이 약 몇 % 높은가

# ---- B-2. 통제변수 추가 ----
m2 <- lm(log_wage ~ gender + age_group + education + job_type, data = klips)
summary(m2)
tidy(m2, conf.int = TRUE)
glance(m2)

# 계수를 % 단위로 환산
tidy(m2, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(pct = (exp(estimate) - 1) * 100) |>
  select(term, estimate, pct, p.value)

# ---- B-3. 계수 그림 ----
tidy(m2, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  ggplot(aes(x = estimate, y = fct_reorder(term, estimate))) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "계수 (로그 임금)", y = NULL)

# ---- B-4. 모형 비교 ----
bind_rows(
  glance(m1) |> mutate(model = "성별만"),
  glance(m2) |> mutate(model = "성별 + 연령 + 학력 + 고용형태")
) |>
  select(model, r.squared, adj.r.squared, sigma, nobs)

# ---- B-5. 상호작용: 성별 임금격차가 연령대마다 다른가 ----
m3 <- lm(log_wage ~ gender * age_group + education + job_type, data = klips)
tidy(m3)
anova(m2, m3)                  # 상호작용항이 필요한지 F-검정

# ---- B-6. 예측 ----
new_people <- tibble(
  gender    = c("Female", "Male"),
  age_group = "30s",
  education = "College",
  job_type  = "Regular"
)

new_people |>
  bind_cols(as_tibble(predict(m2, new_people, interval = "confidence"))) |>
  mutate(across(c(fit, lwr, upr), exp))     # 로그 임금 -> 임금(만원)

# 예측 그래프: 성별 x 연령대 (학력 = College, 정규직)
grid <- expand_grid(
  gender    = levels(klips$gender),
  age_group = levels(klips$age_group),
  education = "College",
  job_type  = "Regular"
) |>
  mutate(age_group = factor(age_group, levels = levels(klips$age_group)))

grid |>
  bind_cols(as_tibble(predict(m3, grid, interval = "confidence"))) |>
  ggplot(aes(x = age_group, y = exp(fit), color = gender, group = gender)) +
  geom_pointrange(aes(ymin = exp(lwr), ymax = exp(upr)),
                  position = position_dodge(width = 0.2)) +
  geom_line(position = position_dodge(width = 0.2)) +
  labs(title = "예측 임금 (대졸, 정규직)",
       x = "연령 그룹", y = "예측 임금 (만원)", color = "성별")

# ---- B-7. 잔차 진단 ----
augment(m2) |>
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "적합값", y = "잔차")
