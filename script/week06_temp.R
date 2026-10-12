hs1992 <- fread("data/HS1992.csv", colClasses = "character")

hs2_label <- hs1992 |> 
  filter(Level == "2") |> 
  mutate(hs2 = Code, hs2_name = Description) |> 
  select(hs2, hs2_name)

left_join(hs2_label, by = "hs2") |> 