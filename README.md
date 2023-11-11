### Chicago Model

#### Data inputs:

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

#### Notes:
* Rethinking Detroit [replication code link](https://www.aeaweb.org/articles?id=10.1257/pol.20180651).
* Access source data via this [link](https://uchicago.box.com/s/zeesv3a65pd7qol836xtz8xrr4ka2v3t). `acs_income.csv` and `tract_firstam.csv` are the primary input files containing tract level income and property information.
* Overview of data sources at this [link](https://docs.google.com/spreadsheets/d/1FuwpwtEi81J9U0c9YtDR3HSLVHOmQVtkfVc8o8Z4eQw/edit#gid=0).

#### Next steps:
* Use [lehdr](https://github.com/jamgreen/lehdr) to process LODES data.
* Use [r5r](https://ipeagit.github.io/r5r/) to process travel time matrices.


