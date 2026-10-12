library(data.table)
library(tidyverse)

# 1. 경로 설정
input_dir  <- "D:/@Teaching/Econometrics II/resources/BACI_HS92_V202601"
output_dir <- "data"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# 2. 1995년부터 2024년까지 반복하며 한국 수입(j == 410) 데이터 추출 (6자리 유지)
years <- 1995:2024
processed_list <- list()

for (yr in years) {
  file_pattern <- paste0("BACI_HS92_Y", yr, "_")
  matched_file <- list.files(path = input_dir, pattern = paste0("^", file_pattern), full.names = TRUE)
  
  if (length(matched_file) > 0) {
    target_file <- matched_file[1]
    cat("Processing year:", yr, "| File:", basename(target_file), "\n")
    
    # 고속 로딩 (k는 앞자리 0 보존을 위해 character 지정)
    df <- fread(target_file, colClasses = c(
      t = "integer",
      i = "integer",
      j = "integer",
      k = "character", 
      v = "numeric",
      q = "numeric"
    ))
    
    # [핵심] 수입국이 한국(j == 410)인 행만 필터링 (HS 6자리 그대로 유지)
    df_hs6_kr_import <- df |> 
      filter(j == 410) |>       # 수입국 == 한국 (ISO 숫자 코드 410)
      select(t, i, j, k, v, q)   # k(6자리 품목 코드) 유지
    
    processed_list[[as.character(yr)]] <- df_hs6_kr_import
    
  } else {
    cat("Warning: Year", yr, "에 해당하는 파일을 찾을 수 없습니다.\n")
  }
}

# 3. 모든 연도 데이터를 하나로 병합하여 저장
if (length(processed_list) > 0) {
  cat("\n한국 수입 데이터(HS 6자리) 통합 중...\n")
  final_df <- rbindlist(processed_list)
  
  # 파일명 지정 (HS6자리 및 수입(Import) 명시)
  output_filepath <- file.path(output_dir, "baci_kor_import.csv")
  
  cat("통합 파일을 저장하는 중입니다:", output_filepath, "\n")
  fwrite(final_df, output_filepath)
  
  cat("한국 수입 데이터(HS 6자리, 1995-2024) 추출 및 통합 완료!\n")
  
} else {
  cat("처리된 데이터가 없습니다.\n")
}