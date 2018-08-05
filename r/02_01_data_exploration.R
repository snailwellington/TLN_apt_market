
library(tidyverse)


asum_plot <- readRDS(file = "data/rds/clean_asum_data.Rds")

p <- asum_plot %>% 
  filter(!(year == 2018 & qtr == "III")) %>% 
  mutate(qtr = case_when(qtr == "IV" ~ "01.10",
                         qtr == "III" ~ "01.07",
                         qtr == "II" ~ "01.04",
                         TRUE ~ "01.01")) %>% 
  group_by(year, qtr,region) %>% 
  summarise(count = sum(tran_count)) %>%
  ungroup() %>% 
  group_by(region) %>% 
  mutate(cum_sum = cumsum(count),
         qtr_year = as.POSIXct(strptime(paste0(year,".",qtr),format = "%Y.%d.%m"))) %>% 
  ggplot(aes(x = qtr_year, y = cum_sum, color = region))+
  geom_line(alpha = 0.4)

p

library(plotly)

ggplotly(p)

#####  IDEAS ####

# Find by area where growth has been faster
# Which areas recovered faster than others, where are they
# Are some area prices correlated
# Which type of area_types are more popular
# Calculate relative change price per m2 through qtr and plot it as gif