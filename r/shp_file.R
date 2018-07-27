
library(tidyverse)
library(ggthemes)


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
  filter(id != "Aegna")
  

## generating base plot with geom_polygon

base_map <- ggplot() +
  geom_polygon(aes(x = long,
                   y = lat,
                   group = group,
                   fill = id),
               data = area_plot,
               color = elv_dblue,
               # fill = elv_blue,
               alpha = 0.5) +
  theme_map()+
  coord_fixed()+
  theme(text = element_text(size = 32), #, family = "elv_font"
        plot.caption =  element_text(size= 16, color = elv_grey),
        legend.position = "none")

## need to check out ggplot new map plotting options

## get data for linnaosa/asum and plot it

## check other projects how to analyse property information

## go wild

base_map
