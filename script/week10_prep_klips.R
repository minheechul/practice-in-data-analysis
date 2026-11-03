# =====================================================================
# week10_prep_klips.R
# 10주차 과제용 KLIPS 27차 개인자료 추출
# 결과: data/klips27p_week10.csv
# =====================================================================

library(tidyverse)
library(readxl)
library(skimr)

klips27p <- read_excel("data/klips27p.xlsx")

# ---------------------------------------------------------------------
# 1. 사용할 변수 (코드북: 1-27차 개인용 통합변수명 p__XXXX → 27차는 p27XXXX)
# ---------------------------------------------------------------------
# jobtype : (주된일자리) 일자리형태          1 임금근로자, 2 비임금근로자
# p270101 : 성별                             1 남자, 2 여자
# p270107 : 만나이
# p270110 : 학력(학교)                       1 미취학 2 무학 3 초 4 중 5 고
#                                            6 2년제/전문대 7 4년제 8 석사 9 박사
# p270317 : 정규직/비정규직                  1 정규직, 2 비정규직
# p270403 : 전체종업원수(범주)               1~10, 11 잘 모르겠다
# p270342 : 업종 KSIC 10차 (소분류 3자리)
# p270352 : 직종 KSCO 7차 (소분류 3자리)
# p271641 : 월평균임금 유무                  1 임금 받음, 2 받지 않음
# p271642 : 월평균임금액(만원)
# 공통: -1 = 모름/무응답 → NA

klips_raw <- klips27p |>
  select(pid, jobtype,
         p270101, p270107, p270110, p270317, p270403,
         p270342, p270352, p271641, p271642) |>
  mutate(across(-pid, ~ na_if(.x, -1)))

# 코드 형식 점검: 소분류 3자리로 들어 있는지 확인 (100 미만 값이 많으면 확인 필요)
klips_raw |> filter(jobtype == 1) |> count(p270342 < 100)
klips_raw |> filter(jobtype == 1) |> count(p270352 < 100)

# ---------------------------------------------------------------------
# 2. 변수 만들기
# ---------------------------------------------------------------------
klips_w10 <- klips_raw |>
  filter(jobtype == 1, p271641 == 1, p271642 > 0) |>     # 임금근로자, 임금 > 0
  mutate(
    wage = p271642,
    age  = p270107,
    gender = case_when(
      p270101 == 1 ~ "Male",
      p270101 == 2 ~ "Female"
    ),
    education = case_when(                                # 최종 학교 기준 (졸업 여부 무시)
      p270110 %in% 1:4 ~ "Middle or less",
      p270110 == 5     ~ "High school",
      p270110 == 6     ~ "College (2yr)",
      p270110 %in% 7:9 ~ "University+"
    ),
    job_type = case_when(
      p270317 == 1 ~ "Regular",
      p270317 == 2 ~ "Non-regular"
    ),
    firm_size = case_when(
      p270403 %in% 1:4  ~ "Small (1-49)",
      p270403 %in% 5:7  ~ "Medium (50-299)",
      p270403 %in% 8:10 ~ "Large (300+)"
    ),
    
    # 산업: 중분류(2자리) = 소분류 %/% 10, 대분류 = 중분류의 구간
    ind2 = p270342 %/% 10,
    industry_detail = if_else(is.na(ind2), NA, sprintf("I%02d", ind2)),
    industry = case_when(
      ind2 %in% 1:3   ~ "A Agriculture",
      ind2 %in% 5:8   ~ "B Mining",
      ind2 %in% 10:34 ~ "C Manufacturing",
      ind2 == 35      ~ "D Electricity",
      ind2 %in% 36:39 ~ "E Water/Waste",
      ind2 %in% 41:42 ~ "F Construction",
      ind2 %in% 45:47 ~ "G Wholesale/Retail",
      ind2 %in% 49:52 ~ "H Transport",
      ind2 %in% 55:56 ~ "I Accommodation/Food",
      ind2 %in% 58:63 ~ "J Information",
      ind2 %in% 64:66 ~ "K Finance",
      ind2 == 68      ~ "L Real estate",
      ind2 %in% 70:73 ~ "M Professional",
      ind2 %in% 74:76 ~ "N Business support",
      ind2 == 84      ~ "O Public admin",
      ind2 == 85      ~ "P Education",
      ind2 %in% 86:87 ~ "Q Health/Welfare",
      ind2 %in% 90:91 ~ "R Arts/Sports",
      ind2 %in% 94:96 ~ "S Other services",
      ind2 %in% 97:98 ~ "T Household",
      ind2 == 99      ~ "U Intl org"
    ),
    
    # 직업: 중분류(2자리) = 소분류 %/% 10, 대분류 = 첫 자리 (98x는 군인)
    occ2 = p270352 %/% 10,
    occupation_detail = if_else(is.na(occ2), NA, sprintf("O%02d", occ2)),
    occupation = case_when(
      occ2 == 98       ~ "A Military",
      occ2 %/% 10 == 1 ~ "1 Managers",
      occ2 %/% 10 == 2 ~ "2 Professionals",
      occ2 %/% 10 == 3 ~ "3 Clerical",
      occ2 %/% 10 == 4 ~ "4 Service",
      occ2 %/% 10 == 5 ~ "5 Sales",
      occ2 %/% 10 == 6 ~ "6 Agri/Fishery",
      occ2 %/% 10 == 7 ~ "7 Craft",
      occ2 %/% 10 == 8 ~ "8 Machine operators",
      occ2 %/% 10 == 9 ~ "9 Elementary"
    )
  ) |>
  # 모형에 쓰는 변수에 결측이 없는 사람만 (job_type, firm_size의 결측으로는 제외하지 않음)
  filter(!is.na(age), !is.na(gender), !is.na(education),
         !is.na(industry), !is.na(occupation)) |>
  # 대분류에서 30명 미만인 범주는 "Other"로 묶음 (중분류는 토론 문항용으로 그대로 둠)
  mutate(industry   = fct_lump_min(industry,   min = 30, other_level = "Other"),
         occupation = fct_lump_min(occupation, min = 30, other_level = "Other")) |>
  select(pid, wage, age, gender, education,
         industry, industry_detail, occupation, occupation_detail,
         job_type, firm_size)

# ---------------------------------------------------------------------
# 3. 점검
# ---------------------------------------------------------------------
skim(klips_w10)
klips_w10 |> count(industry, sort = TRUE)
klips_w10 |> count(occupation, sort = TRUE)
klips_w10 |> count(education)
klips_w10 |> summarize(n_ind_detail = n_distinct(industry_detail),
                       n_occ_detail = n_distinct(occupation_detail))

write_csv(klips_w10, "data/klips27p_week10.csv")