# package dependencies
import geopandas
import pygris
import pyrosm

# to run package on CLI
import sys
import os

# GET CENSUS TRACT DATA ------------------------------------------------------

def get_geometries(geography, state_id, county_id):
    '''
    Get geometries for given geography using pygris.

    Input:
    - geography (str): any method of pygris e.g. tracts, counties, etc.
    - state_id (str): 2 digit code for state ("17" for IL)
    - county_id (str): 3 digit code for county ("031" for Cook County, IL)

    Returns: DataFrame (2 cols) where each observation is a unit of the given
        geography [gives an 'GEOID' and 'geometry'].
    '''
    #get the relevant method for any geography of pygris
    method = getattr(pygris, geography)
    
    # apply method to obtain the geometries, only getting the id and geometry back
    return method(state=state_id, county=county_id).loc[:,['GEOID', 'geometry']]


def get_origin_points(tracts, directory):
    '''
    Gets origin points for a dataframe of census tracts (or could be any geography).

    Inputs:
    - tracts (pandas DF): contains a column 'geometry' which is the geometry of the tract.

    Returns (pandas DF): origins, dataframe with 5 additional columns, one named 'origin' 
        which is the centroid if it is within the polygon and the representative
        point otherwise.
    '''  
    output = tracts.copy()
    
    # add centroid, point on surface, and boolean values if centroid is within the tract
    origins = geopandas.GeoDataFrame(output)
    origins.loc[:,'CENTROID'] = origins.loc[:,'geometry'].centroid
    origins.loc[:,'centroid_in_tract'] = origins.loc[:,'geometry'].contains(origins.loc[:,'CENTROID'])
    origins.loc[:,'REPRESENTATIVE_POINT'] = origins.loc[:,'geometry'].representative_point()
    origins.loc[:,'rpoint_in_tract'] = origins.loc[:,'geometry'].contains(origins.loc[:,'REPRESENTATIVE_POINT'])

    # set origin as centroid if in tract, else set representative point
    origins.loc[:,'ORIGIN'] = origins.loc[:,'CENTROID']
    origins.loc[(origins.loc[:,'centroid_in_tract'] == False),'ORIGIN'] = origins.loc[:,'REPRESENTATIVE_POINT']

    origins = origins[['GEOID', 'ORIGIN']].rename(columns={'GEOID':'id', 'ORIGIN':'geometry'})

    fp = f"{directory}/origins.csv"
    origins.to_csv(fp)
    print("Data was downloaded to:", fp)

# GET PBF FILE ---------------------------------------------------------------

def get_pbf(pyrosm_source, directory):
    # Download the data into specified directory
    fp = pyrosm.get_data(pyrosm_source, directory=directory)
    print("Data was downloaded to:", fp)

# GET GTSM FILE --------------------------------------------------------------

def get_pbf(pyrosm_source, directory):
    # Download the data into specified directory
    fp = pyrosm.get_data(pyrosm_source, directory=directory)
    print("Data was downloaded to:", fp)


# run package on CLI: python -m ingest_data "17" "031" "Illinois"

if __name__ == "__main__":
    geography, state_id, county_id, pyrosm_source = sys.argv[1:]

    directory = f"{geography}_{state_id}{county_id}"

    if not os.path.exists(directory):
        # Create a new directory if it doesn't exist
        os.makedirs(directory)

    tracts = get_geometries(geography, state_id, county_id)
    get_origin_points(tracts, directory)
    get_pbf(pyrosm_source, directory)
