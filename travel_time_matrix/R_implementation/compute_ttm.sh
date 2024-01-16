#!/bin/bash

eval "$(conda shell.bash hook)"
module load R
source activate compute_ttm

working_directory=/Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix
#working_directory=/home/ckboyd/mansueto/chicago-model/travel_time_matrix

log_file_arg=$working_directory/data/deployments/compute_ttm.log
directory_fp_arg=$working_directory/data/tracts_17_031/travel_network
origins_fp_arg=$working_directory/data/tracts_17_031/origins_R.csv
TransportMode_arg=CAR

Rscript /Users/claireboyd/internships/mansueto/chicago-model/travel_time_matrix/R_implementation/compute_ttm.R --log_file $log_file_arg --directory_fp $directory_fp_arg --origins_fp $origins_fp_arg --TransportMode $TransportMode_arg