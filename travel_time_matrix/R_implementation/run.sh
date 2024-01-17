#!/bin/bash

module load R
#source activate compute_ttm

# STEP 1: run ingest_data.R
working_directory=/Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix/data
geography_arg=tracts
state_id_arg=17
county_id_arg=031
osm_source_arg=us/illinois

Rscript /Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix/R_implementation/ingest_data.R --geography $geography_arg --state_id $state_id_arg --county_id $county_id_arg --osm_source $osm_source_arg --working_directory $working_directory

# STEP 2: run compute_ttm.R

working_directory=/Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix

log_file_arg=$working_directory/data/deployments/compute_ttm.log
directory_fp_arg=$working_directory/data/$geography_arg$state_id_arg$county_id_arg/travel_network
origins_fp_arg=$working_directory/data/$geography_arg$state_id_arg$county_id_arg/origins_R.csv
TransportMode_arg=CAR

Rscript /Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix/R_implementation/compute_ttm.R --log_file $log_file_arg --directory_fp $directory_fp_arg --origins_fp $origins_fp_arg --TransportMode $TransportMode_arg