
library(tidyverse)
library(ggthemes)
library(plotly)
library(gifski)
library(viridis)

options(encoding = "UTF-8")

## defined brand colors
cus_blue <- "#00aae7"
cus_black <- "#323232"
cus_grey <- "#969696"
cus_dblue <- "#002c77"
cus_orange <- "#f55523"
cus_yellow <- "#fdfd2f"


region_data <- read_csv2("data/csv/region_ha_analysis_utf8.csv", locale = locale(encoding = "UTF-8")) %>% 
  mutate(region = case_when(region == "ÜlemisteJärve" ~ "Ülemistejärve",
                            TRUE ~ region))

area_plot <- read_csv2("data/csv/area_plot_utf8.csv", locale = locale(encoding = "UTF-8"))
# area_plot <- data.table::fread("data/csv/area_plot_utf8.csv", encoding = "UTF-8")

full_data <- readRDS("data/full_data.RDS") %>% 
  mutate(qtr_year = as.character(qtr_year),
         qtr = str_replace_all(qtr,"[[.]]","-"))

# price_map <- area_plot %>% 
#   left_join(subset(full_data,qtr_year == "2013-01-01"), by = c("id" = "region")) 
#   # mutate(id = tolower(id),
  #        id = str_replace_all(id, "ä","a"),
  #        id = str_replace_all(id, "ü","u"),
  #        id = str_replace_all(id, "ö","o"),
  #        id = str_replace_all(id, "õ","o"))




time_list <- unique(full_data$qtr_year)


for (time_item in time_list){
  price_map <- area_plot %>% 
    left_join(subset(full_data,qtr_year == time_item), by = c("id" = "region"))
  # %>% 
  #   mutate(tran_p_ha = case_when(is.na(tran_p_ha) == TRUE ~ 0,
  #                                TRUE ~ tran_p_ha))
  
  # mid <- mean(transaction_map$tran_p_ha,na.rm = TRUE)
  
  
  tln_plot <- ggplot(aes(x = long,
                         y = lat,
                         group = id,
                         fill = em_mean),
                     data = price_map,
                     alpha = 0.6) +
    geom_polygon(color = "grey40") +
    ggtitle(label = time_item)+
    # geom_map(aes(x = long,
    #              y = lat,
    #              group = id,
    #              fill = tran_p_ha),
    #          data = transaction_map)+
    labs(fill = "Price per region")+
    theme_map()+
    coord_fixed()+
    theme(legend.position = "top")+
    scale_fill_viridis(limits = c(0, 3500),breaks = seq(0,4500,1000))
 
  
  tln_plot
  ggsave(filename = paste0("output/price/price_",time_item,".png"), dpi = 300)
  
}  



gif_files <- list.files(path = "output/price/", pattern = ".png")

gifski(png_files = paste0("output/price/",gif_files), gif_file = "output/price_map.gif",
       delay = 1,
       loop = TRUE)
