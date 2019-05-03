library(tidyverse)
library(ggthemes)





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



### tallinn mean price of all regions
tln_mean_price <- full_data %>% 
  group_by(qtr_year,district) %>% 
  summarise(mean_price = mean(em_mean, na.rm = TRUE)) %>% 
  na.omit()

ggplot(tln_mean_price,aes(x = qtr_year, y = mean_price))+
  geom_point(aes(color = district), size = 2, alpha = 0.75)+
  geom_smooth()+
  labs(x = "Aasta",
       y= "Keskmine m2 hind",
       title = "Tallinna korterite m2 hinnamuut",
       color = "Linnaosa")+
  scale_y_continuous(breaks = seq(0,4000,200))+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")

ggsave("output/tallinn_price_mean.png",width = 16, height = 9)


### tallinn mean price by different districts

district_mean_price <- full_data %>% 
  group_by(district,qtr_year) %>% 
  # filter(lubridate::year(qtr_year) >= 2015) %>% 
  summarise(mean_price = mean(em_mean, na.rm = TRUE)) %>% 
  group_by(district) %>% 
  mutate(index_value = min(mean_price,na.rm = TRUE)) %>% 
  mutate(lead_price = lag(mean_price)) %>% 
  mutate(price_change = round((mean_price/lead_price-1)*100,1),
         index_change = mean_price/index_value) %>% 
  na.omit()

ggplot(district_mean_price,aes(x = qtr_year, y = index_change))+
  # geom_line(aes())+
  geom_smooth(aes(color = district),se = FALSE)+
  # facet_wrap(~district)+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")+
  scale_y_continuous(limits = c(0,6))

ggplot(district_mean_price,aes(x = qtr_year, y = price_change))+
  # geom_line(aes())+
  geom_smooth(aes(color = district),se = FALSE)+
  # facet_wrap(~district)+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")+
  scale_y_continuous(breaks = seq(-30,30,5))
  
ggplot(district_mean_price,aes(x = qtr_year, y = mean_price))+
  # geom_line(aes())+
  geom_smooth(aes(color = district),se = FALSE)+
  # facet_wrap(~district)+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")
  
ggplot(district_mean_price,aes(mean_price))+
  geom_histogram(aes(fill = district),  alpha = 0.9, binwidth = 100)


 



## check only kesklinna data
kesklinn_data <- full_data %>% 
  filter(district == "Kesklinn") %>% 
  # filter(lubridate::year(qtr_year) >= 2017) %>% 
  group_by(qtr_year,region) %>% 
  summarise(mean_price = mean(em_mean,na.rm = TRUE)) %>% 
  # arrange(region) %>% 
  group_by(region) %>% 
  mutate(index_value = min(mean_price,na.rm = TRUE)) %>% 
  mutate(lead_price = lag(mean_price)) %>% 
  mutate(price_change = round((mean_price/lead_price-1)*100,1),
         index_change = mean_price/index_value) 

ggplot(kesklinn_data,aes(x = qtr_year, y = index_change))+
  geom_line(aes(color = region))+
  geom_smooth()+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")+
  scale_y_continuous(limits = c(-1,6))

ggplot(kesklinn_data,aes(x = qtr_year, y = price_change))+
  # geom_line(aes(color = region))+
  geom_smooth(se = FALSE)+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")+
  scale_y_continuous(breaks = seq(-10,max(kesklinn_data$price_change,na.rm = TRUE)+10,2.5))

ggplot(kesklinn_data,aes(x = qtr_year, y = mean_price))+
  geom_line(aes(color = region))+
  geom_smooth(se = FALSE)+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")

## check only põhja tallinn
## check only kesklinna data
ptallinn_data <- full_data %>% 
  filter(district == "Põhja-Tallinn") %>% 
  group_by(qtr_year,region) %>% 
  summarise(mean_price = mean(em_mean,na.rm = TRUE))

ggplot(ptallinn_data,aes(x = qtr_year, y = mean_price))+
  geom_line(aes(color = region))+
  geom_smooth()+
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y")

# ## all region price distribtuion
# ggplot(full_data,aes(em_mean))+
#   geom_histogram(aes(fill = area_type),  alpha = 0.9, binwidth = 100)+
#   facet_wrap(~region)

###
ggplot(asum_data,aes(x = qtr_year, y = em_mean))+
  geom_line(aes(color = region))+
  geom_smooth()



ggplot(asum_data,aes(x = qtr_year, y = em_mean))+
  geom_line(alpha = 0.4)+
  geom_smooth()




## functions





#####  IDEAS ####

# Find by area where growth has been faster
# Which areas recovered faster than others, where are they
# Are some area prices correlated
# Which type of area_types are more popular
# Calculate relative change price per m2 through qtr and plot it as gif