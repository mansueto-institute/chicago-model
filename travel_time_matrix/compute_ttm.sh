#!/bin/bash

module load python/anaconda-2022.05
source activate compute_ttm

working_directory=/home/ckboyd/mansueto/chicago-model/travel_time_matrix

log_file_arg=$working_directory/data/deployments/compute_ttm.log
directory_fp_arg=$working_directory/data/tracts_17_031/travel_network
origins_fp_arg=$working_directory/data/tracts_17_031/origins_small.csv
TransportMode_arg=CAR

python /home/ckboyd/mansueto/chicago-model/travel_time_matrix/compute_ttm.py --log_file $log_file_arg --directory_fp $directory_fp_arg --origins_fp $origins_fp_arg --TransportMode $TransportMode_arg