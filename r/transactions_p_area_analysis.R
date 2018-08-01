



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
  select(year,qtr,qtr_year,district:region_area,region:em_sd)


district_analysis <- full_data %>%
  filter(is.na(district) != TRUE) %>% 
  group_by(qtr_year,district) %>% 
  summarise(total_count = sum(tran_count),
            district_area = sum(region_area)) %>% 
  mutate(tran_p_ha = total_count/district_area)


ggplot(district_analysis, aes(qtr_year, y = tran_p_ha, color = district))+
  geom_line(alpha = 0.4)


region_ha_analysis <- full_data %>%
  filter(is.na(district) != TRUE) %>% 
  group_by(qtr_year,region) %>% 
  summarise(total_count = sum(tran_count),
            region_area = mean(region_area)) %>% 
  mutate(tran_p_ha = total_count/region_area)


ggplotly(ggplot(region_ha_analysis, aes(qtr_year, y = tran_p_ha, color = region))+
  geom_line(alpha = 0.4))
