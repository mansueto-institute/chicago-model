import sys
sys.argv.append(["--r5-classpath", "/home/ckboyd/.cache/r5py/"])
import r5py

import datetime
import geopandas as gpd
import pandas as pd

import psutil
import argparse

import os
import logging
import time
from pathlib import Path
import shapely.geometry
import matplotlib.pyplot as plt

def mem_profile() -> str: 
    """
    Return memory usage, str
    """
    mem_use = str(round(100 - psutil.virtual_memory().percent,4))+'% of '+str(round(psutil.virtual_memory().total/1e+9,3))+' GB RAM'
    return mem_use


def create_travel_time_matrix(directory_fp, origins_fp, TransportMode):
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

    print("Starting to read in origins ...")
    # load encoded dataframe
    df = pd.read_csv(origins_fp)
    # decode geometry columns as strings back into shapely objects
    df["geometry"] = df["geometry"].apply(shapely.wkt.loads)
    # finally reconstruct geodataframe
    origins = gpd.GeoDataFrame(df).set_crs("NAD27")
    print("Done.")

    print("Starting to build travel_time_matrix...")
    travel_time_matrix = r5py.TravelTimeMatrixComputer(
        transport_network,
        origins=origins,
        transport_modes=[getattr(r5py.TransportMode, TransportMode)],
        departure=datetime.datetime(2023, 10, 13, 8, 0, 0), # morning commute 
        snap_to_network=100  
    ).compute_travel_times()
    print("Done.")

    print(f"Starting to write travel_time_matrix to {directory_fp}...")
    travel_time_matrix.to_csv(f"{directory_fp}/ttm.csv")
    print("Done.")


def main(log_file: Path, directory_fp: Path, origins_fp: Path, TransportMode: str):

    logging.basicConfig(filename=Path(log_file), format='%(asctime)s:%(message)s: ', level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')

    logging.info(f"Process started: {mem_profile()}")
    t0 = time.time()

    create_travel_time_matrix(
        directory_fp, 
        origins_fp, 
        TransportMode)

    t1 = time.time()
    logging.info(f"Process succeeded: {mem_profile()}, {round((t1-t0)/60,2)} minutes")

    
def setup(args=None):    
    parser = argparse.ArgumentParser(description='Build blocks geometries.')
    parser.add_argument('--log_file', required=True, type=Path, dest="log_file", help="Path to log file.")  
    parser.add_argument('--directory_fp', required=True, type=Path, dest="directory_fp", help="Path to input directory.")
    parser.add_argument('--origins_fp', required=True, type=Path, dest="origins_fp", help="Path to origin CSV.")
    parser.add_argument('--TransportMode', required=True, type=str, dest="TransportMode", help="Any TransportMode method listed here: https://r5py.readthedocs.io/en/stable/reference/reference.html#r5py.TransportMode.")
    return parser.parse_args(args)

if __name__ == "__main__":
    main(**vars(setup()))