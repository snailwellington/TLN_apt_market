
library(tidyverse)


asum_plot <- readRDS(file = "data/rds/clean_asum_data.Rds")

p <- asum_plot %>% 
  filter(year > 2003 & year < 2018) %>%
  group_by(year,region) %>% 
  summarise(count = sum(tran_count)) %>% 
  ungroup() %>% 
  ggplot(aes(x = year, y = count, color = region))+
  geom_line(alpha = 0.6)+
  scale_x_continuous(breaks = seq(2004,2017,1))

library(plotly)

ggplotly(p)

#####  IDEAS ####

# Find by area where growth has been faster
# Which areas recovered faster than others, where are they
# Are some area prices correlated
# Which type of area_types are more popular
# Calculate relative change price per m2 through qtr and plot it as gif