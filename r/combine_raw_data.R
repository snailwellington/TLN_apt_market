library(readxl)
library(tidyverse)
library(zoo) ## to use na.locf()


# Read in asum data -------------------------------------------------------

raw_list <- list.files("data/asum_data_raw/", pattern = ".xlsx")



asum_data <- data.frame()
for (file in raw_list){
  tmp_xlsx <- read_xlsx(path =paste0("data/asum_data_raw/",file))
  tmp <- tmp_xlsx[6:nrow(tmp_xlsx),]
  asum_data <- rbind(asum_data,tmp)
  
}


names(asum_data)<-c("year","region","area_type","tran_count",
                        "area_total","area_mean","eur_total","eur_min",
                        "eur_max","em_min","em_max","em_median","em_mean","em_sd")



asum_data_clean <- asum_data %>% 
  filter(year != "Allikas: Maa-amet, tehingute andmebaas" & 
           year != "Tehingute hindasid puudutavad andmed kuvatakse vaid juhul, kui on toimunud vähemalt 5 tehingut." |
           is.na(year) == TRUE) %>% 
  mutate(year = na.locf(year),
         region = na.locf(region)) %>% 
  separate(year, c("year","qtr"), sep = " ") %>% 
  filter(str_detect(area_type,"KOKKU") == FALSE) %>% 
  mutate(year = as.numeric(year),
         qtr = as.factor(qtr),
         region = as.factor(region),
         area_type = as.factor(area_type),
         tran_count = as.numeric(tran_count),
         area_total = as.numeric(area_total),
         area_mean = as.numeric(area_mean),
         eur_total = as.numeric(eur_total),
         eur_min = as.numeric(eur_min),
         eur_max = as.numeric(eur_max),
         em_min = as.numeric(em_min),
         em_max = as.numeric(em_max),
         em_median = as.numeric(em_median),
         em_mean = as.numeric(em_mean),
         em_sd = as.numeric(em_sd)) %>% 
  mutate(region = case_when(region == "Ülemiste järv" ~ "Ülemistejärve",
                            TRUE ~ as.character(region)))

saveRDS(object = asum_data_clean, file ="data/rds/clean_asum_data.Rds")


# Read in district data ---------------------------------------------------


district_data_raw <- read_xlsx(path = "data/district_data_raw/Kinnisvara hinnastatistika_2003_III_2018_III.xlsx")

district_data <- district_data_raw[6:nrow(district_data_raw),]

names(district_data)<-c("year","region","area_type","tran_count",
                        "area_total","area_mean","eur_total","eur_min",
                        "eur_max","em_min","em_max","em_median","em_mean","em_sd")



district_data_clean <- district_data %>% 
  filter(year != "Allikas: Maa-amet, tehingute andmebaas" & 
           year != "Tehingute hindasid puudutavad andmed kuvatakse vaid juhul, kui on toimunud vähemalt 5 tehingut." |
           is.na(year) == TRUE) %>% 
  mutate(year = na.locf(year),
         region = na.locf(region)) %>% 
  separate(year, c("year","qtr"), sep = " ") %>% 
  filter(str_detect(area_type,"KOKKU") == FALSE)

saveRDS(object = district_data_clean, file = "data/rds/clean_district_data.Rds")

## Old solution

# guess_encoding("data/Kinnisvara hinnastatistika_2003_III_2018_III.csv")
# price_data_raw <- read_csv2("data/Kinnisvara hinnastatistika_2003_III_2018_III.csv", locale = locale(encoding = "ISO-8859-1"))
# 
# price_data <- price_data_raw %>% 
#   mutate(region = as.factor(region),
#          area_total = str_replace(area_total,",","."),
#          em_min = str_replace(em_min,",","."),
#          em_max = str_replace(em_max,",","."),
#          em_median = str_replace(em_median,",","."),
#          em_mean = str_replace(em_mean,",","."),
#          em_sd = str_replace(em_sd,",","."),
#          area_type = str_replace(area_type,",",".")) %>% 
#   mutate(area_total = str_replace_all(area_total," ",""),
#          em_min = str_replace(em_min," ",""),
#          em_max = str_replace(em_max," ",""),
#          em_median = str_replace(em_median," ",""),
#          em_mean = str_replace(em_mean," ",""),
#          em_sd = str_replace(em_sd," ",""),
#          eur_total = str_replace_all(eur_total," ",""),
#          eur_min = str_replace(eur_min," ",""),
#          eur_max = str_replace(eur_max," ","")) %>% 
#   mutate(area_total = as.numeric(area_total),
#          em_min = as.numeric(em_min),
#          em_max = as.numeric(em_max),
#          em_median = as.numeric(em_median),
#          em_mean = as.numeric(em_mean),
#          em_sd = as.numeric(em_sd),
#          eur_total = as.numeric(eur_total),
#          eur_min = as.numeric(eur_min),
#          eur_max = as.numeric(eur_max))

