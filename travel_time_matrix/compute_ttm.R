# SET-UP  ---------------------------------------------------------------

utils::remove.packages('r5r')
devtools::install_github("ipeaGIT/r5r", subdir = "r-package")
library(r5r) #need to have Java SE Development Kit 21 to run

# check your Java version here
# rJava::.jinit()
# rJava::.jcall("java.lang.System", "S", "getProperty", "java.version")

# to switch your Java version, in a terminal
# download Java JDK 21 here: https://www.oracle.com/java/technologies/downloads/#jdk21-mac
# follow installation instructions
# make sure to also change your JAVA_HOME and PATH environmental variables
    # export JAVA_HOME=$(/usr/libexec/java_home -v <version number> )
    # export PATH=$JAVA_HOME/bin:${PATH}
# to complete the switch run: R CMD javareconf
# check version number on command line: /usr/libexec/java_home -V
# done!

library(tidyverse)
library(tigris)
library(sf)

# GET TRACT DATA  --------------------------------------------------------

# get cook county tracts - example list of tracts to start with
cook_county_tracts <- tigris::tracts(state="17", county="031") %>% 
  select(GEOID, geometry)

# add centroid, point on surface, and boolean values if centroid is within the tract
tracts_summary = cook_county_tracts %>% 
  mutate(CENTROID = sf::st_centroid(`geometry`),
         POINT_ON_SURFACE = sf::st_point_on_surface(`geometry`),
         # check if the centroid point is in the tract
         centroid_in_tract = length(sf::st_intersects(`CENTROID`, `geometry`)) > 0) #,
         #chosen_point = st_point(ifelse(centroid_in_tract == TRUE, CENTROID, POINT_ON_SURFACE)), dim="XY")

points <- sf::st_coordinates(tracts_summary$CENTROID) %>% 
  as.tibble() %>% 
  rename(lon = `X`,
         lat = `Y`) %>% 
  mutate(id = tracts_summary$GEOID)

write.csv(points, "~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts_17_031/origins_R.csv")

# USE r5r TO GET TRAVEL TIME MATRIX --------------------------------------

# allocate RAM memory to Java
options(java.parameters = "-Xmx2G")

# build transport network, pointing to the path where OSM and GTFS data are stored
library(r5r)

Sys.setenv(R_USER_CACHE_DIR="~/internships/mansueto/chicago-model/travel_time_matrix/cache")
tools::R_user_dir("r5r", which = "cache")
r5r::download_r5(force_update = TRUE) #comment out for midway execute

r5r_core <- setup_r5(data_path = "~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts_17_031/travel_network", 
                     verbose = TRUE,
                     overwrite = TRUE)

# load origin/destination points and set arguments
points <- read.csv("~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts_17_031/origins_R.csv")

mode <- c("CAR")
#max_walk_time <- 30   # minutes
#max_trip_duration <- 60 # minutes
departure_datetime <- as.POSIXct("13-10-2023 08:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

# 3.1) calculate a travel time matrix
ttm <- travel_time_matrix(r5r_core = r5r_core,
                          origins = points,
                          destinations = points[10,],
                          mode = mode,
                          departure_datetime = departure_datetime
                          )








options(java.parameters = '-Xmx4G')

library(r5r)

# build transport network
data_path <- system.file("extdata/poa", package = "r5r")
r5r_core <- setup_r5(data_path, overwrite = T)

# load origin/destination points
points <- read.csv(file.path(data_path, "poa_points_of_interest.csv"))

departure_datetime <- as.POSIXct(
  "13-05-2019 14:00:00",
  format = "%d-%m-%Y %H:%M:%S"
)

ttm <- travel_time_matrix(
  r5r_core,
  origins = points,
  destinations = points,
  mode = c("WALK", "TRANSIT"),
  departure_datetime = departure_datetime,
  max_trip_duration = 60, 
  progress = T
)

head(ttm)









# # APPLY TO BLOCK LEVEL FOR CHICAGO METRO  ------------------------------------
# 
# blocks_17 <- tigris::blocks(state = '17', 
#                             county =  c('031', '043', '063', '111', '197', '037', '089', '093', '097'), 
#                             year = 2020) %>% 
#   select(GEOID20, geometry)
# 
# blocks_18 <- tigris::blocks(state = '18', county =  c('073', '089', '111', '127'), 
#                             year = 2020) %>% 
#   select(GEOID20, geometry)
# 
# blocks_55 <- tigris::blocks(state = '55', 
#                             county = '059', 
#                             year = 2020) %>% 
#   select(GEOID20, geometry)
# 
# blocks <- rbind(blocks_17, blocks_18, blocks_55) %>% st_transform(4326)
# 





