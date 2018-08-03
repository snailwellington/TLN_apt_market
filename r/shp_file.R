
library(tidyverse)
library(ggthemes)
library(plotly)
library(gifski)

options(encoding = "UTF-8")

## defined brand colors
elv_blue <- "#00aae7"
elv_black <- "#323232"
elv_grey <- "#969696"
elv_dblue <- "#002c77"
elv_orange <- "#f55523"
elv_yellow <- "#fdfd2f"





area <- rgdal::readOGR("data/shp_files/asumid_23052016_shp/t02_41_asum.shp")

# area <- sf::st_read("data/shp_files/asumid_23052016_shp/t02_41_asum.shp") ## alternative 1, but needs extra work to get lat and long
# area <- maptools::readShapePoly("data/shp_files/asumid_23052016_shp/t02_41_asum.shp") ## not reccomended but alternative 2

# generate data.frame with coordinates and long lat by asumi nimi
area.points <- broom::tidy(area, region = "asumi_nimi")

## filter out Aegna saar
area_plot <- area.points %>% 
  filter(id != "Aegna") %>% 
  mutate(id = str_replace_all(id,"Ã•","Õ"),
         id = str_replace_all(id,"Ã¤","ä"),
         id = str_replace_all(id,"Ã¼","ü"),
         id = str_replace_all(id,"Ãœ","Ü"),
         id = str_replace_all(id,"Ãµ","õ"))
  
write.csv2(area_plot, file = "data/csv/area_plot.csv")


## generating base plot with geom_polygon
# 
# base_map <- ggplot() +
#   geom_polygon(aes(x = long,
#                    y = lat,
#                    group = group,
#                    fill = id),
#                data = area_plot,
#                color = elv_dblue,
#                # fill = elv_blue,
#                alpha = 0.5) +
#   theme_map()+
#   coord_fixed()+
#   theme(text = element_text(size = 32), #, family = "elv_font"
#         plot.caption =  element_text(size= 16, color = elv_grey),
#         legend.position = "none")
# 
# ## need to check out ggplot new map plotting options
# 
# ## get data for linnaosa/asum and plot it
# 
# ## check other projects how to analyse property information
# 
# ## go wild
# 
# base_map

### need to get actual reference to this file
## why there are so many NA-s. Every qtr doesn't have transactions


guess_encoding("data/csv/region_ha_analysis_utf8.csv")
guess_encoding("data/csv/area_plot_utf8.csv")

region_data <- read_csv2("data/csv/region_ha_analysis_utf8.csv", locale = locale(encoding = "UTF-8"))

area_plot <- read_csv2("data/csv/area_plot_utf8.csv", locale = locale(encoding = "UTF-8"))




transaction_map <- area_plot %>% 
  left_join(subset(region_data, qtr_year == "1072008"), by = c("id" = "region"))

mid <- mean(transaction_map$tran_p_ha,na.rm = TRUE)


tln_plot <- ggplot(aes(x = long,
                       y = lat,
                       group = id,
                       fill = tran_p_ha),
                   data = transaction_map) +
  geom_polygon(color = elv_blue) +
  # geom_map(aes(x = long,
  #              y = lat,
  #              group = id,
  #              fill = tran_p_ha),
  #          data = transaction_map)+
  theme_map()+
  coord_fixed()+
  theme(legend.position = "top")+
  scale_fill_gradient(low = "blue", high = "red")

tln_plot

ggplotly(tln_plot)


# Make a gif --------------------------------------------------------------

# I'll run this as gif to see, if the transactions have moved from Tornimäe to somewhere else

time_list <- unique(region_data$qtr_year)
min_tran <- min(region_data$tran_p_ha)
max_tran <- max(region_data$tran_p_ha)

region_data_limited <- region_data %>% 
  mutate(tran_p_ha = case_when(tran_p_ha > 1.5 ~ 1.5,
                               TRUE ~ tran_p_ha))


for (time_item in time_list){
  transaction_map <- area_plot %>% 
    left_join(subset(region_data_limited, qtr_year == time_item), by = c("id" = "region"))

# mid <- mean(transaction_map$tran_p_ha,na.rm = TRUE)


  tln_plot <- ggplot(aes(x = long,
                         y = lat,
                         group = id,
                         fill = tran_p_ha),
                     data = transaction_map) +
    geom_polygon(color = elv_blue) +
    ggtitle(label = paste0(substr(time_item,4,7),"-",substr(time_item,2,3)))+
    # geom_map(aes(x = long,
    #              y = lat,
    #              group = id,
    #              fill = tran_p_ha),
    #          data = transaction_map)+
    theme_map()+
    coord_fixed()+
    theme(legend.position = "top")+
    scale_fill_gradient2(low = "blue",mid = "lightgreen", high = "red", midpoint = 0.75, limits = c(0,1.5))
  
  # tln_plot
  ggsave(filename = paste0("output/transaction_p_ha/trans_p_ha_",substr(time_item,4,7),"-",substr(time_item,2,3),".png"), dpi = 100)

}  



gif_files <- list.files(path = "output/transaction_p_ha/", pattern = ".png")

gifski(png_files = paste0("output/transaction_p_ha/",gif_files), gif_file = "output/transaction_p_ha.gif",
       width = 1600,
       height = 900, 
       delay = 1,
       loop = TRUE)
