library(tidyverse)


obj_reg <- readRDS("data/rds/asum_district_match.Rds")
asum_data <- readRDS(file = "data/rds/clean_asum_data.Rds")

## If less than 5 transactions, then there is no price given
## For the sake of analysis, previous qtr price is used

find_price <- function(x){
  ## need to check which areas don't have price
  ## find previous qtr, that has a price
  ## take the mean price for the previous qtr
  
  price = ...
  
  
  return(price)
}


# Finding average price for m2 for each region. Not taking into account the size of apartments. 

fill_missing <- asum_data %>% 
  group_by(region,year,qtr) %>% 
  summarise(tran_count = sum(tran_count, na.rm = TRUE),
            area_avg = mean(area_total, na.rm = TRUE),
            eur_total = sum(eur_total, na.rm = TRUE),
            mean_max_price = mean(eur_max, na.rm = TRUE),
            mean_min_price = mean(eur_min, na.rm = TRUE),
            mean_m2_median = mean(em_median, na.rm = TRUE),
            mean_m2_mean = mean(em_mean, na.rm = TRUE),
            mean_m2_sd = mean(em_sd, na.rm = TRUE)) %>% 
  mutate(qtr = case_when(qtr == "IV" ~ "01.10",
                         qtr == "III" ~ "01.07",
                         qtr == "II" ~ "01.04",
                         TRUE ~ "01.01")) %>% 
  mutate(qtr_year = as.POSIXct(strptime(paste0(year,".",qtr),format = "%Y.%d.%m")))


## Index price needs to be found. 100 is taken at 2004-01-01
## Inflation can/should be taken into account


find_index <- 1

## Plotting

ggplot(fill_missing, aes(x = qtr_year, y = mean_m2_mean))+
  geom_line(aes(color = region))+
  geom_smooth()+
  geom_hline(yintercept = 1189.5950)+
  theme(legend.position = "bottom")+
  scale_x_datetime(date_breaks = ("1 year"), date_labels = "%Y")



