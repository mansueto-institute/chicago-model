# SET-UP  ---------------------------------------------------------------

library(tidyverse)
library(tigris)
library(sf)
library(r5r) #need to have Java SE Development Kit 11 to run

# GET TRACT DATA  --------------------------------------------------------

# get cook county tracts - example list of tracts to start with
cook_county_tracts <- tigris::tracts(state="17", county="031") %>% 
  select(GEOID20, geometry)

# add centroid, point on surface, and boolean values if centroid is within the tract
tracts_summary = cook_county_tracts %>% 
  mutate(CENTROID = sf::st_centroid(`geometry`),
         POINT_ON_SURFACE = sf::st_point_on_surface(`geometry`),
         # check if the centroid point is in the tract
         centroid_in_tract = length(sf::st_intersects(`CENTROID`, `geometry`)) > 0)

# r5r example ------------------------------------------------------------

# allocate RAM memory to Java
#options(java.parameters = "-Xmx2G")

# 1) build transport network, pointing to the path where OSM and GTFS data are stored
path <- system.file("extdata/poa", package = "r5r")
r5r_core <- setup_r5(data_path = path, verbose = FALSE) #blocked on this line of code 


#ERROR:

# Error in setup_r5(data_path = path, verbose = FALSE) :
#   This package requires the Java SE Development Kit 11.
# Please update your Java installation. The jdk 11 can be downloaded from either:
#   - openjdk: https://jdk.java.net/java-se-ri/11
# - oracle: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html







# 2) load origin/destination points and set arguments
points <- tracts_summary$CENTROID
mode <- c("CAR")
#max_walk_time <- 30  # minutes
#max_trip_duration <- 60 # minutes
departure_datetime_rushhour <- as.POSIXct("07-11-2023 08:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")
departure_datetime_midday <- as.POSIXct("07-11-2023 13:00:00",
                                          format = "%d-%m-%Y %H:%M:%S")

# 3.1) calculate a travel time matrix
ttm <- travel_time_matrix(r5r_core = r5r_core,
                          origins = points,
                          destinations = points,
                          mode = mode,
                          departure_datetime = departure_datetime_rushhour)



# APPLY TO BLOCK LEVEL FOR CHICAGO METRO  ------------------------------------

blocks_17 <- tigris::blocks(state = '17', 
                            county =  c('031', '043', '063', '111', '197', '037', '089', '093', '097'), 
                            year = 2020) %>% 
  select(GEOID20, geometry)

blocks_18 <- tigris::blocks(state = '18', county =  c('073', '089', '111', '127'), 
                            year = 2020) %>% 
  select(GEOID20, geometry)

blocks_55 <- tigris::blocks(state = '55', 
                            county = '059', 
                            year = 2020) %>% 
  select(GEOID20, geometry)

blocks <- rbind(blocks_17, blocks_18, blocks_55) %>% st_transform(4326)






