# import libraries

library(tidyverse)
library(tigris)
library(RColorBrewer)
library(sf)

# import ttm

ttm <- read_csv("~/internships/mansueto/chicago-model/travel_time_matrix/data/tracts17031/travel_network/ttm.csv") %>% 
  #isolate to only the census tracts leaving 17031839100
  filter(from_id == "17031839100") %>% 
  rename(GEOID = to_id) %>% 
  mutate(GEOID = as.character(GEOID))

cook_county_tracts <- tigris::tracts(state = "17", county = "031") %>% 
  #select(GEOID, geometry) %>% 
  mutate(GEOID = as.character(GEOID))

merged_table = left_join(cook_county_tracts, ttm, by=c('GEOID')) %>% 
  filter(!is.na(travel_time_p50))

ggplot() + 
  geom_sf(data = merged_table %>% filter(!is.na(travel_time_p50)), aes(fill = travel_time_p50), color = 'white', linewidth = .3) +
  viridis::scale_fill_viridis() +
  labs(subtitle = "Median Commute Time from Tract 17031839100") + 
  theme(plot.subtitle = element_text(hjust = .5)) + 
  theme_void()

ggsave("tracts_ttm.jpg", device = "jpg")

# jpeg("tracts_ttm.jpg", width = 700, height = "500")
# plot(merged_table["travel_time_p50"],
#      main="Median Commute Time from Tract '17031839100'",
#      breaks = "jenks")
# dev.off()
