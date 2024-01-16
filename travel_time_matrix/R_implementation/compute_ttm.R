#!/usr/bin/env Rscript

# JAVA SET-UP  -----------------------------------------------------------

#need to have Java SE Development Kit 21 to run

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

# r5r versioning --------------------------------------

# utils::remove.packages('r5r')
devtools::install_github("ipeaGIT/r5r", subdir = "r-package")

# allocate RAM memory to Java
options(java.parameters = '-Xmx9G') #not sure what we should change about this line to work on the cluster

# build transport network, pointing to the path where OSM and GTFS data are stored
library(r5r)
library(argparse)
library(logr)

# USE r5r TO GET TRAVEL TIME MATRIX --------------------------------------

#' Create travel time matrix
#'
#' Creates travel time matrix from inputs.
#' @param directory_fp A string, filepath to a directory name where inputs for travel network (osm or pbf files) exist
#' @param origins_fp A string, filepath to csv file that contains at least the following columns: `id`, `lon`, `lat`
#' @param TransportMode A string, any TransportMode method listed here: https://r5py.readthedocs.io/en/stable/reference/reference.html#r5py.TransportMode
#' @return None. Saves a csv of the compiled travel time matrix in the directory_fp as 'ttm.csv'
#' @examples
#' directory_fp = "~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts_17_031/travel_network"
#' origins_fp = "~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts_17_031/origins_R.csv"
#' TransportMode = "CAR"
#' create_travel_time_matrix(directory_fp, origins_fp, TransportMode)
create_travel_time_matrix <- function(directory_fp, origins_fp, TransportMode) {

  log_print("Starting to build transport network...")
  r5r_core <- setup_r5(data_path = directory_fp, 
                     verbose = TRUE,
                     #overwrite = TRUE
                     )
  log_print("Done.")

  log_print("Starting to read in origins and set parameters...")
  origins <- read.csv(origins_fp)
  origins_small <- origins[1:10,]
  mode <- c(TransportMode)
  departure_datetime <- as.POSIXct("13-10-2023 08:00:00",
                                  format = "%d-%m-%Y %H:%M:%S")
  log_print("Done.")

  # 3.1) calculate a travel time matrix
  log_print("Starting to create the travel time matrix...")
  ttm <- travel_time_matrix(r5r_core = r5r_core,
                            origins = origins_small,
                            destinations = origins_small,
                            mode = mode,
                            departure_datetime = departure_datetime
                            )
  log_print("Done.")
  
  log_print("Starting to write matrix to csv...")
  write.csv(ttm, paste0(directory_fp, "/ttm.csv"))
  log_print("Done.")
}


main <- function(log_file, directory_fp, origins_fp, TransportMode) {
  
  #raise error if inputs are not character values
  for (param in list(log_file, directory_fp, origins_fp, TransportMode)) {
    if (!is.character(param)) {
      stop(paste0(as.character(param), " is not a character value"))
    }
  }
  
  log_fp = file.path(log_file)
  log_open(log_fp)
  
  log_print("Process started.")

  # sets directory to save the r5r jar locally
  Sys.setenv(R_USER_CACHE_DIR= paste0(directory_fp,"/cache"))
  tools::R_user_dir("r5r", which = "cache")
  # r5r::download_r5(force_update = TRUE) #comment out for offline execute, assuming jar is already in local project cache folder listed above
  
  create_travel_time_matrix(
    directory_fp,
    origins_fp,
    TransportMode
  )
  
  log_print("Process succeeded")
}

setup <- function() {
  parser <- ArgumentParser(description='Build blocks geometries.')
  
  parser$add_argument('--log_file', required=TRUE, type='character', dest="log_file", help="Path to log file.")
  parser$add_argument('--directory_fp', required=TRUE, type='character', dest="directory_fp", help="Path to input directory.")
  parser$add_argument('--origins_fp', required=TRUE, type='character', dest="origins_fp", help="Path to origin CSV.")
  parser$add_argument('--TransportMode', required=TRUE, type='character', dest="TransportMode", help="Any TransportMode method listed here: https://r5py.readthedocs.io/en/stable/reference/reference.html#r5py.TransportMode.")
  
  args <- parser$parse_args()
  return(args)
}

#exploring ways this could work in R
if (sys.nframe() == 0) {
  args <- setup()
  main(args$log_file, args$directory_fp, args$origins_fp, args$TransportMode)
}
