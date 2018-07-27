
library(tidyverse)

guess_encoding("data/Kinnisvara hinnastatistika_2003_III_2018_III.csv")
price_data_raw <- read_csv2("data/Kinnisvara hinnastatistika_2003_III_2018_III.csv", locale = locale(encoding = "ISO-8859-1"))

price_data <- price_data_raw %>% 
  mutate(region = as.factor(region),
         area_total = str_replace(area_total,",","."),
         em_min = str_replace(em_min,",","."),
         em_max = str_replace(em_max,",","."),
         em_median = str_replace(em_median,",","."),
         em_mean = str_replace(em_mean,",","."),
         em_sd = str_replace(em_sd,",",".")) %>% 
  mutate(area_total = str_replace_all(area_total," ",""),
         em_min = str_replace(em_min," ",""),
         em_max = str_replace(em_max," ",""),
         em_median = str_replace(em_median," ",""),
         em_mean = str_replace(em_mean," ",""),
         em_sd = str_replace(em_sd," ",""),
         eur_total = str_replace_all(eur_total," ",""),
         eur_min = str_replace(eur_min," ",""),
         eur_max = str_replace(eur_max," ","")) %>% 
  mutate(eur_total = ifelse(eur_total == "***","0",eur_total)) %>% 
  mutate(area_total = as.numeric(area_total),
         em_min = as.numeric(em_min),
         em_max = as.numeric(em_max),
         em_median = as.numeric(em_median),
         em_mean = as.numeric(em_mean),
         em_sd = as.numeric(em_sd),
         eur_total = as.numeric(eur_total),
         eur_min = as.numeric(eur_min),
         eur_max = as.numeric(eur_max))



