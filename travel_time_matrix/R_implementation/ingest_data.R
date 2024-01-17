#!/usr/bin/env Rscript

# GET TRACT DATA  --------------------------------------------------------

library(tidyverse)
library(tigris)
library(sf)
library(argparse)
library(stringr)

get_origin_points = function(geography, state_id, county_id, directory){

  # get cook county tracts - example list of tracts to start with
  print(geography)
  method = get(geography, envir = getNamespace("tigris"))
  
  geometries <- method(state=state_id, county=county_id) %>%
    select(GEOID, geometry)

  # add centroid, point on surface, and boolean values if centroid is within the tract
  geometries_summary = geometries %>%
    mutate(CENTROID = sf::st_centroid(`geometry`)) #,
          #POINT_ON_SURFACE = sf::st_point_on_surface(`geometry`),
          # check if the centroid point is in the tract
          #centroid_in_tract = length(sf::st_intersects(`CENTROID`, `geometry`)) > 0) #,
          #chosen_point = st_point(ifelse(centroid_in_tract == TRUE, CENTROID, POINT_ON_SURFACE)), dim="XY")

  points <- sf::st_coordinates(geometries_summary$CENTROID) %>%
    as_tibble() %>%
    rename(lon = `X`,
          lat = `Y`) %>%
    mutate(id = geometries_summary$GEOID)

  fp = paste0(directory,"/origins_R.csv")
  write.csv(points, fp)
}

# GET PBF FILE ---------------------------------------------------------------

library(osmextract)

get_pbf = function(osm_source, directory){
  # Download the data into specified directory
  its_details <- osmextract::oe_match(osm_source)
  
  osmextract::oe_download(
    file_url = its_details$url,
    download_directory = paste0(directory,"/travel_network")
  )
}


main = function(geography, state_id, county_id, osm_source, working_directory){

  padded_county = str_pad(county_id, 3, pad = "0")

  directory <- paste0(working_directory, "/", geography, state_id, padded_county)

  if (!dir.exists(directory)) {
    # Create a new directory if it doesn't exist
    dir.create(directory)
  }

  get_origin_points(geography, state_id, county_id, directory)
  get_pbf(osm_source, directory)
}

setup <- function() {
  parser <- argparse::ArgumentParser(description='Ingests block geometries and relevant pbf data.')
  
  parser$add_argument('--geography', required=TRUE, type='character', dest="geography", help="Any type of geography available in tigris. See https://github.com/walkerke/tigris for options.")
  parser$add_argument('--state_id', required=TRUE, type='numeric', dest="state_id", help="Two digit string, e.g. '17' for IL.")
  parser$add_argument('--county_id', required=TRUE, type='numeric', dest="county_id", help="Three digit string, e.g. '031' for Cook County (in IL).")
  parser$add_argument('--osm_source', required=TRUE, type='character', dest="osm_source", help="String of geography available through https://cran.r-project.org/web/packages/osmextract/vignettes/osmextract.html, e.g. 'Illinois'")
  parser$add_argument('--working_directory', required=TRUE, type='character', dest="working_directory", help="working directory")

  args <- parser$parse_args()
  return(args)
}

if (sys.nframe() == 0) {
  args <- setup()
  main(args$geography, args$state_id, args$county_id, args$osm_source, args$working_directory)
}
