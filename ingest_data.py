
import geopandas
import pygris

# GET CENSUS TRACT DATA ------------------------------------------------------

def get_tracts(state_id, county_id):
    return pygris.tracts(state=state_id, county=county_id).loc[:,['GEOID', 'geometry']]

def get_origin_points(tracts):
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

    return origins

# GET PBF FILE ---------------------------------------------------------------

import pyrosm 

def get_pbf()

# Download the data into specified directory
fp = pyrosm.get_data("Illinois", directory="input")
print("Data was downloaded to:", fp)

