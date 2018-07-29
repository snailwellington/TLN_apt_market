

raw_list <- list.files("data/housing_data_raw/", pattern = ".xlsx")


library(readxl)
library(tidyverse)

property_data <- data.frame()
for (file in raw_list){
  tmp_xlsx <- read_xlsx(path =paste0("data/housing_data_raw/",file))
  tmp <- tmp_xlsx[6:nrow(tmp_xlsx),]
  property_data <- rbind(property_data,tmp)
  
}


names(property_data)<-c("year","region","area_type","tran_count",
                        "area_total","area_mean","eur_total","eur_min",
                        "eur_max","em_min","em_max","em_median","em_mean","em_sd")



property_data_clean <- property_data %>% 
  filter(year != "Allikas: Maa-amet, tehingute andmebaas" & 
           year != "Tehingute hindasid puudutavad andmed kuvatakse vaid juhul, kui on toimunud vähemalt 5 tehingut." |
           is.na(year) == TRUE)

                      