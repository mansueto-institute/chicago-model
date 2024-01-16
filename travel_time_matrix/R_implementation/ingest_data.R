# GET TRACT DATA  --------------------------------------------------------

library(tidyverse)
library(tigris)
library(sf)

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