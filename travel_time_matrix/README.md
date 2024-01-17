# Generate travel time matrix

To generate a travel time matrix in R, follow the steps below:

* download and install [java jdk 21](https://www.oracle.com/java/technologies/downloads/#jdk21-mac)
* inspect the `R_implementation/run.sh` script to confirm input parameters (and adjust as needed). The input parameters are:
    * geography: what level of geography you are interested in computing travel times for
    * state_id: two digit id you want to focus on
    * county_id: three digit id you want to focus on
    * osm_source: the open street map source that is most relevant to your geography (use osmextract to confirm this)
* change relevant filepaths in `R_implementation/run.sh` to point to your correct working directories
* run the script by running `bash R_implementation/run.sh` in your terminal. 

For questions or suggestions for modifications, please contact: ckboyd@uchicago.edu.