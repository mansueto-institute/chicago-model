
library(tidyverse)
library(arrow)


# Metro crosswalk ---------------------------------------------------------------

xwalk_url <- 'https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2020/delineation-files/list1_2020.xls'
tmp_filepath <- paste0(tempdir(), '/', basename(xwalk_url))
download.file(url = paste0(xwalk_url), destfile = tmp_filepath)
cbsa_xwalk <- read_excel(tmp_filepath, sheet = 1, range = cell_rows(3:1919))
cbsa_xwalk <- cbsa_xwalk %>% 
  select_all(~gsub("\\s+|\\.|\\/", "_", .)) %>%
  rename_all(list(tolower)) %>%
  mutate(fips_state_code = str_pad(fips_state_code, width=2, side="left", pad="0"),
         fips_county_code = str_pad(fips_county_code, width=3, side="left", pad="0"),
         county_fips = paste0(fips_state_code,fips_county_code)) %>%
  rename(cbsa_fips = cbsa_code,
         area_type = metropolitan_micropolitan_statistical_area) %>%
  select(county_fips,cbsa_fips,cbsa_title,area_type,central_outlying_county) 

# First American ----------------------------------------------------------

options(scipen=9999)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
wd_dev <- getwd()

# Run this in Python to extract subset from raw CSV
# (pl.scan_csv('/nationwide-files/20220606_Annual.txt', separator = '|', try_parse_dates=True, infer_schema_length=1000, ignore_errors = True)
#   .with_columns([(pl.col('FIPS').cast(pl.Utf8).str.rjust(5, "0"))])
#   .filter(pl.col('FIPS').is_in(['17031', '17043', '17063', '17111', '17197', '17037', '17089', '17093', '18073', '18089', '18111', '18127', '17097', '55059']))
#   .select(['FIPS', 'SitusLatitude', 'SitusLongitude', 'SitusCensusBlock', 'SitusCensusTract', 'PropertyClassID', 'AssdYear', 'SumBuildingSqFt', 'BuildingArea', 'LotSizeSqFt', 'AssdTotalValue', 'AssdLandValue', 'AssdImprovementValue'])
# ).sink_parquet('/first_american.parquet', compression="snappy")

firstamerican <- read_parquet('first_american_raw.parquet')

firstamerican <- firstamerican %>% st_as_sf(coords = c("SitusLongitude", "SitusLatitude"), 
         crs = 4326, agr = "constant") %>% 
  st_transform(4326)  

blocks_17 <- tigris::blocks(state = '17', county =  c('031', '043', '063', '111', '197', '037', '089', '093', '097'), year = 2020) %>% select(GEOID20, ALAND20, geometry)
blocks_18 <- tigris::blocks(state = '18', county =  c('073', '089', '111', '127'), year = 2020) %>% select(GEOID20, ALAND20, geometry)
blocks_55 <- tigris::blocks(state = '55', county = '059', year = 2020) %>% select(GEOID20, ALAND20, geometry)

blocks <- rbind(blocks_17, blocks_18, blocks_55) %>% 
  st_transform(4326) %>%
  st_transform(3395) %>%
  mutate(area_m2 = st_area(geometry),
         area_ft2 = 10.7639*area_m2) %>%
  st_transform(4326) %>%
  mutate(area_m2 = as.numeric(area_m2),
         area_ft2 = as.numeric(area_ft2))
  
rm(blocks_17, blocks_18, blocks_55)

firstamerican <- firstamerican %>%
  st_join(., blocks)
  
firstamerican <- firstamerican %>% st_drop_geometry()
rm(blocks)
gc()

firstamerican <- firstamerican %>% 
  mutate(tract_fips = str_sub(GEOID20, 1, 11), 
         block_group_fips = str_sub(GEOID20,1, 12),
         block_fips = str_sub(GEOID20, 1, 15)) %>%
  mutate(property_count = 1) %>%
  mutate(property_class = case_when(
    PropertyClassID == 'R' ~ 'Residential',
    PropertyClassID == 'C' ~ 'Commercial',
    PropertyClassID == 'O' ~ 'Office',
    PropertyClassID == 'F' ~ 'Recreational',
    PropertyClassID == 'I' ~ 'Industrial',
    PropertyClassID == 'T' ~ 'Transportation',
    PropertyClassID == 'A' ~ 'Agricultural',
    PropertyClassID == 'V' ~ 'Vacant',
    PropertyClassID == 'E' ~ 'Exempt',
    TRUE ~ 'Missing')) %>%
  rename_all(tolower)

write_parquet(firstamerican, 'first_american_staging.parquet')
rm(firstamerican)
gc()


# -------------------------------------------------------------------------

scan_fa <- open_dataset('first_american_staging.parquet')

query_fa <- scan_fa %>%
  group_by(tract_fips, property_class) %>% 
  filter() %>%
  summarize(sumbuildingsqft = sum(sumbuildingsqft),
            buildingarea = sum(buildingarea),
            lotsizesqft = sum(lotsizesqft),
            assdtotalvalue = sum(assdtotalvalue),
            assdlandvalue = sum(assdlandvalue),
            assdimprovementvalue = sum(assdimprovementvalue),
            aland20 = sum(aland20),
            area_m2 = sum(area_m2),
            area_ft2 = sum(area_ft2),
            property_count = sum(property_count)) %>%
  ungroup() %>%
  collect()

unique(query_fa$property_class)

query_fa <- query_fa %>% 
  mutate(county_fips = str_sub(tract_fips, 1, 5), 
         assessment_factor = case_when(county_fips == '17031' & property_class == "Residential" ~ 10, # 10%
                                  county_fips == '17031' & property_class == "Commercial" ~ 4, # 20%
                                  county_fips != '17031' ~ 3)) %>% # 33.3333%
  mutate(market_totalvalue = assdtotalvalue*assessment_factor,
         market_landvalue = assdlandvalue*assessment_factor,
         market_improvementvalue = assdimprovementvalue*assessment_factor)

# query_fa <- query_fa %>% 
#   filter(property_class %in% c('Residential','Commercial'))

# https://tax.illinois.gov/questionsandanswers/answer.318.html

write_csv(query_fa, 'tract_firstam.csv')

# property_class: A First American general code used to easily recognize specific property types (e.g., Residential, Commercial, Office).
# sumbuildingsqft : The size of the building in Square Feet. This field is most commonly populated as a cumulative total when a county does not differentiate between Living and Non-living areas.
# buildingarea : The Building Square Footage that can most accurately be used for assessments or comparable (e.g., Living, Adjusted, Gross).
# lotsizesqft : This field contains the total area measurement of the land in square feet.
# assdtotalvalue : The Total Assessed Value of the Parcel's Land & Improvement values
# assdlandvalue : The current assessed value of the land only (before exemptions, if any) as reported on the current county tax/assessment roll. Whole dollars only.
# assdimprovementvalue : The current assessed value of the improvements only (before exemptions, if any) as reported on the current county tax/assessment roll. Whenever separate fields are provided for additional improved values, this will be the total of all improvement values. Whole dollars only.
# area_m2 : Geographic FIPS unit area meters square
# area_ft2 : Geographic FIPS unit area feet square


# ACS Tract Income --------------------------------------------------------

state_county_list <- cbsa_xwalk %>% filter(cbsa_fips %in% c('16980')) %>% 
  mutate(county_code = str_sub(county_fips, 3,5),
         state_fips = str_sub(county_fips, 1,2)) %>%
  select(state_fips, county_code) %>% as.list() 

acs5_vars_selected <- c('B19001_002', 'B19001_003', 'B19001_004', 'B19001_005', 'B19001_006', 'B19001_007', 'B19001_008', 'B19001_009', 'B19001_010', 'B19001_011', 'B19001_012', 'B19001_013', 'B19001_014', 'B19001_015', 'B19001_016', 'B19001_017')

acs_data <- map2_dfr(.x = state_county_list[[1]], .y = state_county_list[[2]], .f = function(x , y) {
  get_acs(year = 2020, geography = "tract", survey = 'acs5',
          variables = acs5_vars_selected,  summary_var = 'B19001_001',
          state = x, county = y)
})

acs_data <- acs_data %>%
  rename_all(list(tolower)) %>%
  mutate(income_bin = case_when(variable == 'B19001_002' ~ 'Less than $10,000',
                                variable == 'B19001_003' ~ '$10,000 to $14,999',
                                variable == 'B19001_004' ~ '$15,000 to $19,999',
                                variable == 'B19001_005' ~ '$20,000 to $24,999',
                                variable == 'B19001_006' ~ '$25,000 to $29,999',
                                variable == 'B19001_007' ~ '$30,000 to $34,999',
                                variable == 'B19001_008' ~ '$35,000 to $39,999',
                                variable == 'B19001_009' ~ '$40,000 to $44,999',
                                variable == 'B19001_010' ~ '$45,000 to $49,999',
                                variable == 'B19001_011' ~ '$50,000 to $59,999',
                                variable == 'B19001_012' ~ '$60,000 to $74,999',
                                variable == 'B19001_013' ~ '$75,000 to $99,999',
                                variable == 'B19001_014' ~ '$100,000 to $124,999',
                                variable == 'B19001_015' ~ '$125,000 to $149,999',
                                variable == 'B19001_016' ~ '$150,000 to $199,999',
                                variable == 'B19001_017' ~ '$200,000 or more')) %>%
  mutate(share = estimate / summary_est) %>%
  select(geoid, variable, income_bin, share, estimate, summary_est, moe)

write_csv(acs_data, 'acs_income.csv')
