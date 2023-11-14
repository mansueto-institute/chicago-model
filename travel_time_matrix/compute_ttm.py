# package dependencies
import r5py
import datetime
import geopandas

# to run package on CLI
import sys
import os

def create_travel_time_matrix(directory_fp, origins_fp, destinations_fp,
                              TransportMode):
    '''
    Creates travel time matrix from inputs.

    Inputs:
    - directory_fp (str): directory name where all inputs exist
    - origins (str): csv file
    - destinations (str): csv file
    - TransportMode (str): any TransportMode method listed here: https://r5py.readthedocs.io/en/stable/reference/reference.html#r5py.TransportMode

    Returns: ttm as pandas DataFrame (where num rows = origins * destinations)
    '''
    #create transport network with osm.pbf and GTFS by pointing to the directory with all relevant files
    print("Starting to create transport_network...")
    transport_network = r5py.TransportNetwork.from_directory(directory_fp)
    print("Done.")

    print("Starting to read in origins and destinations...")
    origins = geopandas.read_csv(origins_fp)
    destinations = geopandas.read_csv(destinations_fp)
    print("Done.")

    print("Starting to build travel_time_matrix...")
    travel_time_matrix = r5py.TravelTimeMatrixComputer(
        transport_network,
        origins=origins,
        destinations=destinations,
        transport_modes=[getattr(r5py.TransportMode, TransportMode)],
        departure=datetime.datetime(2019, 5, 13, 14, 0, 0),
    ).compute_travel_times()
    print("Done.")

    print(f"Starting to write travel_time_matrix to {directory_fp}...")
    travel_time_matrix.to_csv(f"{directory_fp}/ttm.csv")
    print("Done.")

# run package on CLI: python -m compute_ttm "tracts_17_031" "origins.csv" "origins.csv" "CAR"
# assuming that the files cta_chicago.zip and illinois-latest.osm.pbf are in "tracts_17_031" 
#       and origins in the main directory that the call is bring run from.

if __name__ == "__main__":
    directory_fp, origins_fp, destinations_fp, TransportMode = sys.argv[1:]

    create_travel_time_matrix(directory_fp, origins_fp, destinations_fp, TransportMode)