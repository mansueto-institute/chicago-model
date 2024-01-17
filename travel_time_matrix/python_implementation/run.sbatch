#!/bin/bash

#SBATCH --job-name=compute_ttm
#SBATCH --partition=caslake
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=180000
#SBATCH --output=/project/crberry/chicago-model-project/data/deployments/compute_ttm.out
#SBATCH --error=/project/crberry/chicago-model-project/data/deployments/compute_ttm.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ckboyd@rcc.uchicago.edu
#SBATCH --time=36:00:00
#SBATCH --account=pi-crberry

module load R
source activate compute_ttm

working_directory=/project/crberry/chicago-model-project

log_file_arg=$working_directory/data/deployments/compute_ttm.log
directory_fp_arg=$working_directory/data/tracts_17_031/travel_network
origins_fp_arg=$working_directory/data/tracts_17_031/origins.csv
TransportMode_arg=$CAR
# Assumes that illinois-latest.osm.pbf are in "tracts_17_031/travel_network" 

Rscript /project/crberry/chicago-model-project/chicago-model/travel_time_matrix/R_implementation/compute_ttm.R --log_file $log_file_arg --directory_fp $directory_fp_arg --origins_fp $origins_fp_arg --TransportMode $TransportMode_arg
