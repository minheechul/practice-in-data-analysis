library(tidyverse)
library(skimr)
library(janitor)

klips27p_small <- read_csv("data/klips27p_small.csv")


# 가르칠 내용
# 1. 컴퓨터에 저장된 데이터 불러오기: 
#   csv, excel
#   path와 r project 사용
# 2. 성별 임금 분포 
#   분석하는 방법, 태도 설명
#     표와 그림을 읽고 생각하기
#     필요하면 추가로 표 및 그래프 작성
#     전체 분포: 지니계수, 다른 기술 방법
#     세부 그룹별 비교
#   기술적인 이슈
#     기초: 패키지 사용법 (dplyr, ggplot2, skimr, janitor)
#     기타: kernel density, case_when, pivot_wider
#   KLIPS 실제로 다운받아서 사용해 보기
# 3. 실습


# 강의 예제: 성별 임금 분포

klips27p_small <- klips27p_small |> 
  mutate(age_group = fct_relevel(age_group, "Below 30", "30s", "40s", "Above 50")) 


klips27p_small |> 
  group_by(gender) |> 
  skim(wage)

klips27p_small |>
  group_by(gender) |> 
  summarize(mean_wage = mean(wage),
            n = n()) |> 
  # 아래 일곱 줄은 번거로우면 무시해도 됩니다   
  pivot_wider(
    names_from  = gender,
    values_from = c(mean_wage, n)
  ) |> 
  mutate(
    male_to_female_ratio = (mean_wage_Male / mean_wage_Female) * 100
  )  


klips27p_small |> 
  group_by(gender, age_group) |> 
  summarize(mean_wage = mean(wage),
            n = n()) |> 
  # 마찬가지로 아래 일곱 줄은 번거로우면 무시해도 됩니다 
  pivot_wider(
    names_from  = gender,
    values_from = c(mean_wage, n)
  ) |> 
  mutate(
    male_to_female_ratio = (mean_wage_Male / mean_wage_Female) * 100
  )

p1 <- klips27p_small |> 
  ggplot(aes(x = gender, y = wage)) +
  geom_boxplot()

p1
p1 + scale_y_log10()
p1 + coord_cartesian(ylim = c(0, 1000))
p1 + coord_cartesian(ylim = c(0, 1000)) + facet_wrap(~age_group)


p2 <- klips27p_small |> 
  ggplot(aes(x = wage, fill = gender)) +
  geom_density(alpha = 0.2)

p2
p2 + scale_x_log10()
p2 + coord_cartesian(xlim = c(0, 1000)) 
p2 + coord_cartesian(xlim = c(0, 1000)) + facet_wrap(~age_group)

# 강의 중 실습
# 정규직-비정규직 임금 분포 차이

# 실습 1
# KLIPS 원자료 다운
# 5년전 자료로 성별 임금 분포 살펴볼 것

# 실습 2
# KLIPS 원자료 다운
# 2027년 자료 이용 기업 규모별 임금 분포 
