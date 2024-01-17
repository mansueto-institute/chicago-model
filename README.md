### Chicago Model

#### Data inputs (available at this [link](https://uchicago.box.com/s/zeesv3a65pd7qol836xtz8xrr4ka2v3t))

##### `acs_income.csv`
* `geoid`: tract FIPS code covering all counties in Chicago MSA
* `variable`: Census variable ID      
* `income_bin`: household income in the past 12 months (in 2020 inflation-adjusted dollars) 
* `share`: share of income bin    
* `estimate`: number of households at income bin level

##### `tract_firstam.csv`
* `tract_fips`: tract FIPS code covering all counties in Chicago MSA
* `property_class`: one of the following categories 'Residential', 'Exempt', 'Commercial', 'Vacant', 'Industrial', 'Office', 'Agricultural', 'Recreational', 'Missing', 'Transportation'
* `buildingarea`: building square footage that can most accurately be used for assessments
* `lotsizesqft`: total area measurement of the land in square feet
* `market_totalvalue`: market value of land and building value (adjusted from `assdtotalvalue` using assessment level of 10% for Cook County Residential, 25% for Cook County Commercial, and 33.33% for all other properties statewide)

##### `tract_ttm.csv` (generated using r5r)
* `from_id`: tract FIPS code in Cook County
* `to_id`: tract FIPS code in Cook County
* `travel_time_p50`: travel time (in minutes) from the centroid of the "from" tract to the centroid of the "to" tract. (Note: if the centroid is not within the shape of the tract, then we use a "point on surface" which approximates a center point that is within the tract boundaries). p50 indicates that the result is the 50 percentile or median travel time. For more on this, see the documentation of [r5r travel_time_matix()](https://ipeagit.github.io/r5r/reference/travel_time_matrix.html)).

#### Notes:
* Rethinking Detroit [replication code link](https://www.aeaweb.org/articles?id=10.1257/pol.20180651).
* Overview of data sources at this [link](https://docs.google.com/spreadsheets/d/1FuwpwtEi81J9U0c9YtDR3HSLVHOmQVtkfVc8o8Z4eQw/edit#gid=0).

#### Next steps:
* Use [lehdr](https://github.com/jamgreen/lehdr) to process LODES data.


