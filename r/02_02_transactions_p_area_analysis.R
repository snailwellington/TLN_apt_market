

library(plotly)
library(tidyverse)

# Combine asum and district data ------------------------------------------

obj_reg <- readRDS("data/rds/asum_district_match.Rds")
asum_data <- readRDS(file = "data/rds/clean_asum_data.Rds")


full_data <- asum_data %>% 
  left_join(obj_reg, by = c("region")) %>% 
  mutate(qtr = case_when(qtr == "IV" ~ "01.10",
                         qtr == "III" ~ "01.07",
                         qtr == "II" ~ "01.04",
                         TRUE ~ "01.01")) %>% 
  mutate(qtr_year = as.POSIXct(strptime(paste0(year,".",qtr),format = "%Y.%d.%m"))) %>% 
  select(year,qtr,qtr_year,district:region_area,region:em_sd) %>% 
  mutate(population = as.numeric(str_replace(population," ","")))


district_analysis <- full_data %>%
  filter(is.na(district) != TRUE) %>% 
  group_by(qtr_year,district) %>% 
  summarise(total_count = sum(tran_count),
            district_area = sum(region_area),
            population = mean(population)) %>% 
  mutate(tran_p_ha = total_count/district_area,
         tran_p_pop = total_count/population)


ggplot(district_analysis, aes(qtr_year, y = tran_p_pop, color = district))+
  geom_line(alpha = 0.4)


region_ha_analysis <- full_data %>%
  filter(is.na(district) != TRUE) %>% 
  group_by(qtr_year,region) %>% 
  summarise(total_count = sum(tran_count),
            region_area = mean(region_area),
            population = mean(population)) %>% 
  mutate(tran_p_ha = total_count/region_area,
         tran_p_pop = total_count/population) %>% 
  mutate(region = as.character(region))


##write this data to csv to fix the umlauts
write.csv2(region_ha_analysis, file = "data/csv/region_ha_analysis.csv", fileEncoding = "UTF-8", row.names = FALSE)



ggplot(region_ha_analysis, aes(qtr_year, y = tran_p_pop, color = region))+
  geom_line(alpha = 0.4)

