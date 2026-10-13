library(tidyverse)
library(skimr)
library(janitor)

# ==============================================================================
# (0) 데이터 준비 
# ==============================================================================


df <- read_csv("data/baci_kor_import_hs2.csv",
                col_types = "iiicd") 
# t, i, j (integer), hs2 (character), v (double)

hs2_label <- tribble(
  ~hs2, ~hs2_label,
  "29", "유기화학물",
  "39", "플라스틱",
  "72", "철강",
  "84", "일반기계",
  "85", "전기전자",
  "90", "정밀기기"
)

# ==============================================================================
# (1) 일본으로부터의 수입 품목 구성: 상위 5개와 비중 변화
# ==============================================================================
df_jpn <- df |>
  filter(i == 392)     # 일본 국가기호: 392

yrs <- c(1995, 2000, 2005, 2010, 2015, 2020, 2024)

# df_jpn |> 
#   filter(t %in% yrs) |> 
#   group_by(t) |>
#   mutate(share = v / sum(v)) |> 
#   slice_max(v, n = 5, with_ties = FALSE) |>
#   mutate(rank = row_number()) |>
#   select(t, rank, hs2) |> 
#   pivot_wider(names_from = rank, values_from = hs2, names_prefix = "rank") |> 
#   print(n = Inf)

df_jpn |> 
  filter(t %in% yrs) |> 
  left_join(hs2_label, by = "hs2") |> 
  group_by(t) |>
  mutate(share = v / sum(v)) |> 
  slice_max(v, n = 5, with_ties = FALSE) |>
  mutate(rank = row_number()) |>
  select(t, rank, hs2_label) |> 
  pivot_wider(names_from = rank, values_from = hs2_label, names_prefix = "rank") |> 
  print(n = Inf)


df_jpn |> 
  group_by(t) |>
  mutate(share = v / sum(v) * 100) |> 
  slice_max(v, n = 5, with_ties = FALSE) |>
  summarize(cum_share = sum(share)) |> 
  ggplot(aes(x = t, y = cum_share)) +
    geom_line() +
    geom_point() +
    labs(title = "대일 수입 상위 5개 품목의 점유율 합계 (HS1992 2자리 기준)",
         x = "연도",
         y = "상위 5개 품목 점유율 합계 (%)"
         )

# ==============================================================================
# (2) 품목(HS2)별 대일 의존도 = 일본산 수입 / 전체 수입
# 
# ==============================================================================

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
  


