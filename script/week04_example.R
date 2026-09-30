# 패키지 준비
library(tidyverse)
library(skimr)
library(janitor)
library(ineq)      # 나중에 지니계수 구할 때만 한번 사용

# 데이터 불러오기
klips27p_small <- read_csv("data/klips27p_small.csv")


# 데이터의 구조와 변수의 개요
skim(klips27p_small)


### 3.2 임금 변수의 분포

# 임금의 히스토그램"
klips27p_small |> 
  ggplot(aes(x = wage)) +
  geom_histogram() +
  labs(x = "임금 (만원)")

# 임금의 상자그림
klips27p_small |> 
  ggplot(aes(x = wage)) +
  geom_boxplot() +
  labs(x = "임금 (만원)")       

# 임금의 히스토그램 (로그 스케일)
klips27p_small |> 
  ggplot(aes(x = wage)) +
  geom_histogram() +
  labs(x = "임금 (만원)") +
  scale_x_log10()
  
# 임금의 상자그림 (0 - 1,000만원 구간 확대)
klips27p_small |> 
  ggplot(aes(x = wage)) +
  geom_boxplot() +
  labs(x = "임금 (만원)") +
  coord_cartesian(xlim = c(0, 1000))       


# 임금의 분위수 배율 및 분위 평균 배율
klips27p_small |> 
  summarize(
    p10 = quantile(wage, probs = 0.1),
    p90 = quantile(wage, probs = 0.9),
    
    mean_10 = mean(wage[wage <= p10]),
    mean_90 = mean(wage[wage >= p90]),
    
    ratio_cutoff = p90 / p10,
    ratio_mean = mean_90 / mean_10
  ) 

# 임금의 지니계수
klips27p_small |> 
  summarize(
    gini = ineq(wage)
  ) 


### 3.3 남녀 임금 분포의 비교

# 성별에 따른 임금 통계량 비교
klips27p_small |> 
  group_by(gender) |> 
  skim(wage)

# 성별에 따른 임금 통계량 비교
klips27p_small |> 
  group_by(gender) |> 
  summarize(
    mean = mean(wage),
    sd = sd(wage)
  ) |>
  # 아래 일곱 줄은 번거로우면 무시해도 됩니다   
  pivot_wider(
    names_from  = gender,
    values_from = c(mean, sd)
  ) |>
  mutate(
    ratio_mean = (mean_Male / mean_Female),
    ratio_sd = (sd_Male / sd_Female)    
  ) 

# T-test
t.test(wage ~ gender, data = klips27p_small)

# 성별에 따른 임금의 상자그림
p1 <- klips27p_small |> 
  ggplot(aes(x = wage, y = gender)) +
  geom_boxplot()
p1

# 성별에 따른 임금의 상자그림 (0 - 1,000만원 구간 확대)
p1 + coord_cartesian(xlim = c(0, 1000))


### 3.4 연령 그룹별 남녀 임금 분포의 비교

# age_group 레벨의 순서를 다시 정렬
klips27p_small <- klips27p_small |> 
  mutate(age_group = fct_relevel(age_group, "Below 30", "30s", "40s", "Above 50")) 

# 연령 그룹별 남녀 임금 통계량 비교
klips27p_small |> 
  group_by(gender, age_group) |> 
  summarize(mean_wage = mean(wage),
            n = n()) |> 
  pivot_wider(
    names_from  = gender,
    values_from = c(mean_wage, n)
  ) |> 
  mutate(
    male_to_female_ratio = (mean_wage_Male / mean_wage_Female) 
  ) 

# 성별에 따른 임금의 상자그림 (0 - 1,000만원 구간 확대)
p2 <- klips27p_small |> 
  ggplot(aes(x = wage, y = gender)) +
  geom_boxplot()

p2 + coord_cartesian(xlim = c(0, 1000)) + facet_wrap(~age_group)

