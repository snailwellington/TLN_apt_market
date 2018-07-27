library(readr)
library(rgdal)
library(rgeos)
library(ggplot2)
library(tmap)
library(leaflet)
library(spdep)

# setwd("//energia.sise/dfs/REDIRECT/tarmo.rahmonen/Documents/DS/Plots/Map_making/Data")
census.data <- read_csv("Data/practicaldata.csv")

output.areas <- readOGR("Data/Camden_oa11.shp")
?readOGR

plot(output.areas)

oa.census <- merge(output.areas,census.data, by.x="OA11CD",by.y="OA")

qtm(oa.census, fill = "Qualification")

tm_shape(oa.census)+
  tm_fill("Qualification", palette = "Blues", n =5, style ="equal", legend.hist = TRUE)+
  tm_borders(alpha=0.4)

?tm_shape

houses <- read.csv("Data/CamdenHouseSales15.csv")
houses <- houses[,c(1,2,8,9)]
plot(houses$oseast1m, houses$osnrth1m)


house.points <-SpatialPointsDataFrame(houses[,3:4], houses, proj4string = CRS("+init=EPSG:27700"))

tm_shape(oa.census) + tm_borders(alpha=.4) 



###making maps

tm_shape(oa.census) + tm_borders(alpha=.4) +
  tm_shape(house.points) + tm_dots(col = "Price", palette = "Reds", style = "quantile") 


tm_shape(oa.census) + tm_borders(alpha=.8) +
  tm_shape(house.points) + tm_dots(col = "Price", scale = 3.5, palette = "Reds", style = "quantile", title = "Price Paid (£)")


# creates a proportional symbol map
tm_shape(oa.census) + tm_borders(alpha=.4) + 
  tm_shape(house.points) + tm_bubbles(size = "Price", col = "Price", palette = "Blues", style = "quantile", legend.size.show = FALSE, title.col = "Price Paid (£)") +
  tm_layout(legend.text.size = 1.1, legend.title.size = 1.4, frame = FALSE)


# creates a proportional symbol map
tm_shape(oa.census) + tm_fill("Qualification", palette = "Reds", style = "quantile", title = "% Qualification") + 
  tm_borders(alpha=.4) + 
  tm_shape(house.points) + tm_bubbles(size = "Price", col = "Price", palette = "Blues", style = "quantile", legend.size.show = FALSE, title.col = "Price Paid (£)", border.col = "black", border.lwd = 0.1, border.alpha = 0.1) +
  tm_layout(legend.text.size = 0.8, legend.title.size = 1.1, frame = FALSE)


# # write the shapefile to your computer (remember to chang the dsn to your workspace)
# writeOGR(house.points,dsn = "//energia.sise/dfs/REDIRECT/tarmo.rahmonen/Documents/DS/Map_making/results",layer =  "Camden_house_sales", driver="ESRI Shapefile")

####### Iteractive map
# turns view map on
tmap_mode("view")
#turn map view off to plot view
tmap_mode("plot")

tm_shape(house.points) + 
  tm_dots(title = "House Prices (£)", 
          border.col = "black", 
          border.lwd = 0.1, 
          border.alpha = 0.2, 
          col = "Price", 
          style = "quantile",
          palette = "Reds")  


tm_shape(oa.census) +
  tm_fill("Qualification", 
          palette = "Blues", 
          style = "quantile", 
          title = "% with a Qualification") + 
  tm_borders(alpha=.2)

#### Running spatial autocorrelation


# Calculate neighbours
neighbours <- poly2nb(oa.census)
neighbours

plot(oa.census, border = 'lightgrey')
plot(neighbours, coordinates(oa.census), add=TRUE, col='red')


# Calculate the Rook's case neighbours
neighbours2 <- poly2nb(oa.census, queen = FALSE)
neighbours2

plot(oa.census, border = 'lightgrey')
plot(neighbours, coordinates(oa.census), add=TRUE, col='blue')
plot(neighbours2, coordinates(oa.census), add=TRUE, col='red')


# Convert the neighbour data to a listw object
listw <- nb2listw(neighbours2)
listw
plot(oa.census, border = 'lightgrey')
plot(listw, coordinates(oa.census), add=TRUE, col='red')
# global spatial autocorrelation
moran.test(oa.census$Qualification, listw)

# creates a moran plot
moran <- moran.plot(oa.census$Qualification, listw = nb2listw(neighbours2, style = "W"))

# creates a local moran output
local <- localmoran(x = oa.census$Qualification, listw = nb2listw(neighbours2, style = "W"))

# binds results to our polygon shapefile
moran.map <- cbind(oa.census, local)

# maps the results
tm_shape(moran.map) + tm_fill(col = "Ii", style = "quantile", title = "local moran statistic") 


names(moran.map@data)

### to create LISA cluster map ### 
quadrant <- vector(mode="numeric",length=nrow(local))

# centers the variable of interest around its mean
m.qualification <- oa.census$Qualification - mean(oa.census$Qualification)     

# centers the local Moran's around the mean
m.local <- local[,1] - mean(local[,1])    

# significance threshold
signif <- 0.1 

# builds a data quadrant
quadrant[m.qualification >0 & m.local>0] <- 4  
quadrant[m.qualification <0 & m.local<0] <- 1      
quadrant[m.qualification <0 & m.local>0] <- 2
quadrant[m.qualification >0 & m.local<0] <- 3
quadrant[local[,5]>signif] <- 0   

# plot in r
brks <- c(0,1,2,3,4)
colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")
plot(oa.census,border="lightgray",col=colors[findInterval(quadrant,brks,all.inside=FALSE)])
box()
legend("bottomleft",legend=c("insignificant","low-low","low-high","high-low","high-high"),
       fill=colors,bty="n")

####Getis-Ord

# creates centroid and joins neighbours within 0 and x units
nb <- dnearneigh(coordinates(oa.census),0,150)
# creates listw
nb_lw <- nb2listw(nb, style = 'B')

nb


# plot the data and neighbours
plot(oa.census, border = 'lightgrey')
plot(nb, coordinates(oa.census), add=TRUE, col = 'red')

# compute Getis-Ord Gi statistic
local_g <- localG(oa.census$Qualification, nb_lw)
local_g <- cbind(oa.census, as.matrix(local_g))
names(local_g)[6] <- "gstat"

# map the results
tm_shape(local_g) + tm_fill("gstat", palette = "RdBu", style = "pretty") + tm_borders(alpha=.4)


## Geo weighted regression in R
# runs a linear model
model <- lm(oa.census$Qualification ~ oa.census$Unemployed+oa.census$White_British)

summary(model)
plot(model)

par(mfrow=c(2,2))
plot(model)

par(mfrow = c(1,0))
###mapping the residuals
resids<-residuals(model)

map.resids <- cbind(oa.census, resids) 
# we need to rename the column header from the resids file - in this case its the 6th column of map.resids
names(map.resids)[6] <- "resids"

# maps the residuals using the quickmap function from tmap
qtm(map.resids, fill = "resids")



###Interpolating Point Data in R
library(maptools)
library(spatstat)
library(DirichletReg)

#### broken

# Create a tessellated surface
dat.pp <- as(ddirichlet(as.ppp(house.points)), "SpatialPolygons")
dat.pp <- as(dat.pp,"SpatialPolygons")

# Sets the projection to British National Grid
proj4string(dat.pp) <- CRS("+init=EPSG:27700")
proj4string(house.points) <- CRS("+init=EPSG:27700")

# Assign to each polygon the data from house.points 
int.Z <- over(dat.pp,house.points, fn=mean) 

# Create a SpatialPolygonsDataFrame
thiessen <- SpatialPolygonsDataFrame(dat.pp, int.Z)


# maps the thiessen polygons and house.points
tm_shape(output.areas) + tm_fill(alpha=.3, col = "grey") +
  tm_shape(thiessen) +  tm_borders(alpha=.5, col = "black") +
  tm_shape(house.points) + tm_dots(col = "blue", scale = 0.5)


library(raster)

# crops the polygon by our output area shapefile
thiessen.crop <-crop(thiessen, output.areas)

# maps cropped thiessen polygons and house.points
tm_shape(output.areas) + tm_fill(alpha=.3, col = "grey") +
  tm_shape(thiessen.crop) +  tm_borders(alpha=.5, col = "black") +
  tm_shape(house.points) + tm_dots(col = "blue", scale = 0.5)


# maps house prices across thiessen polygons
tm_shape(thiessen.crop) + tm_fill(col = "Price", style = "quantile", palette = "Reds", title = "Price Paid (£)") + tm_borders(alpha=.3, col = "black") +
  tm_shape(house.points) + tm_dots(col = "black", scale = 0.5) +
  tm_layout(legend.position = c("left", "bottom"),  legend.text.size = 1.05, legend.title.size = 1.2, frame = FALSE)

#####Inverse Distance Weighting(IDW)
library(gstat)
library(xts)

# define sample grid based on the extent of the house.points file
grid <-spsample(house.points, type = 'regular', n = 10000)

# runs the idw for the Price variable of house.points
idw <- idw(house.points$Price ~ 1, house.points, newdata= grid)

idw.output = as.data.frame(idw)
names(idw.output)[1:3] <- c("long", "lat", "prediction")


# create spatial points data frame
spg <- idw.output
coordinates(spg) <- ~ long + lat

# coerce to SpatialPixelsDataFrame
gridded(spg) <- TRUE
# coerce to raster
raster_idw <- raster(spg)

# sets projection to British National Grid
projection(raster_idw) <- CRS("+init=EPSG:27700")

# we can quickly plot the raster to check its okay
plot(raster_idw)


persp(raster_idw)


library(tmap)
tm_shape(raster_idw) + tm_raster("prediction", style = "quantile", n = 100, palette = "Blues", legend.show = FALSE)

tm_shape(raster_idw) + tm_raster("prediction", style = "quantile", n = 100, palette = "Reds", legend.show = FALSE) +
  tm_shape(output.areas) + tm_borders(alpha=.5)


#### Loops and conditionals


# map function with 3 arguments
map <- function(x,y,z){
  
  tm_shape(x) + tm_fill(y, palette = z, style = "quantile") + tm_borders(alpha=.4) + 
    tm_compass(size = 1.8, fontsize = 0.5) + 
    tm_layout(title = "Camden", legend.title.size = 1.1, frame = FALSE) 
  
}


# runs map function, remember we need to include all 3 arguments of the function
map(oa.census, "Unemployed", "Blues")

# creates a new newdata object so we have it saved somewhere

newdata <- census.data

# a for loop where i iterates from 2 to 5
for(i in 2:5){
  # i is used to identify the column number
  newdata[, i] <- round(census.data[,i], 1)
  
}
for(i in 2: ncol (census.data)){
  
  newdata[, i] <- census.data[,i]/100
  
}

# newdata1 <- newdata
# 
# for(i in 1:nrow(newdata)){
#   
#   if (newdata$White_British[i] < 0.5) {
#     newdata$White_British[i] <- "Low";
#     
#   } else {
#     newdata$White_British[i] <- "High";
#     
#   }
# }


# copies the numbers back to newdata so we can start again
newdata <- newdata1


for(j in 2: ncol (newdata)){
  
  for(i in 1:nrow(newdata)){
    
    if (newdata[i,j] < 0.25) {
      newdata[i,j] <- "Very Low";
      
    } else if (newdata[i,j] < 0.50){
      newdata[i,j] <- "Low";
      
    } else if (newdata[i,j] < 0.75){
      newdata[i,j] <- "High";
      
    } else {
      newdata[i,j] <- "Very High";
      
    }
  }
}

# merge our new formatted data with the output areas shapefile
shapefile <- merge(output.areas, newdata, by.x = "OA11CD", by.y = "OA")

# runs our predefined map function
map(shapefile, "Qualification", "Set2")
