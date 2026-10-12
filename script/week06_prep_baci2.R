library(tidyverse)
library(data.table)


# fread로 고속 로딩 (k는 6자리 문자열 형태 유지)
df_hs6 <- fread("data/baci_kor_import.csv", colClasses = c(
  t = "integer",
  i = "integer",
  j = "integer",
  k = "character", 
  v = "numeric",
  q = "numeric"
))


df_hs2 <- df_hs6 |> 
  mutate(
    hs2 = str_sub(k, 1, 2)  # 앞 2자리 추출
  ) |> 
  group_by(t, i, j, hs2) |>   
  summarise(
    v = sum(v, na.rm = TRUE), # 무역액 합산
    .groups = "drop"
  ) |> 
  select(t, i, j, hs2, v)   # 컬럼 순서 정돈

fwrite(df_hs2, "data/baci_kor_import_hs2.csv")

