# import libraries

library(tidyverse)
library(tigris)
library(RColorBrewer)
library(sf)

# import ttm and census track geographies
ttm <- read_csv("~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts17031/travel_network/ttm.csv") %>% 
  #isolate to only the census tracts leaving 17031839100
  filter(from_id == "17031839100") %>% 
  rename(GEOID = to_id) %>% 
  mutate(GEOID = as.character(GEOID))

cook_county_tracts <- tigris::tracts(state = "17", county = "031") %>% 
  mutate(GEOID = as.character(GEOID))

# merge into a joined table
merged_table = left_join(cook_county_tracts, ttm, by=c('GEOID')) %>% 
  filter(!is.na(travel_time_p50))

# plot 
ggplot() + 
  geom_sf(data = merged_table, aes(fill = travel_time_p50), color = 'white', linewidth = .3) +
  viridis::scale_fill_viridis() +
  labs(subtitle = "Median commute time to a tract in downtown Chicago") + 
  theme(plot.subtitle = element_text(hjust = .5)) + 
  theme_void()

# save
ggsave("tracts_ttm.jpg", device = "jpg")