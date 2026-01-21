xtoll <- sf::st_read("xtoll.geojson")
class(xtoll)
head(xtoll)

xtoll$perc_all <- round(100 - (xtoll$rank_all / max(xtoll$rank_all) * 100), 2)
xtoll$perc_smoke <- round(
  100 - (xtoll$rank_smoke / max(xtoll$rank_smoke) * 100),
  2
)
xtoll$perc_heat <- round(
  100 - (xtoll$rank_heat / max(xtoll$rank_heat, na.rm = TRUE) * 100),
  2
)
xtoll$perc_flood <- round(
  100 - (xtoll$rank_flood / max(xtoll$rank_flood) * 100),
  2
)
xtoll$perc_drought <- round(
  100 - (xtoll$rank_drought / max(xtoll$rank_drought) * 100),
  2
)
head(xtoll)
tail(xtoll)


summary(xtoll$perc_all)
head(xtoll)


sf::st_write(xtoll, "xtoll3.geojson", delete_dsn = TRUE)

states <- sf::st_read("states.geojson")
us <- sf::st_union(states)
plot(us)
sf::st_write(us, "us.geojson", delete_dsn = TRUE)

df_new_england <- data.frame(
  Region = "Northeast",
  Division = "New England",
  State = c(
    "Connecticut",
    "Maine",
    "Massachusetts",
    "New Hampshire",
    "Rhode Island",
    "Vermont"
  )
)
df_mid_atlantic <- data.frame(
  Region = "Northeast",
  Division = "Middle Atlantic",
  State = c("New Jersey", "New York", "Pennsylvania")
)

# Midwest Region
df_east_north_central <- data.frame(
  Region = "Midwest",
  Division = "East North Central",
  State = c("Illinois", "Indiana", "Michigan", "Ohio", "Wisconsin")
)
df_west_north_central <- data.frame(
  Region = "Midwest",
  Division = "West North Central",
  State = c(
    "Iowa",
    "Kansas",
    "Minnesota",
    "Missouri",
    "Nebraska",
    "North Dakota",
    "South Dakota"
  )
)

# South Region
df_south_atlantic <- data.frame(
  Region = "South",
  Division = "South Atlantic",
  State = c(
    "Delaware",
    "District of Columbia",
    "Florida",
    "Georgia",
    "Maryland",
    "North Carolina",
    "South Carolina",
    "Virginia",
    "West Virginia"
  )
)
df_east_south_central <- data.frame(
  Region = "South",
  Division = "East South Central",
  State = c("Alabama", "Kentucky", "Mississippi", "Tennessee")
)
df_west_south_central <- data.frame(
  Region = "South",
  Division = "West South Central",
  State = c("Arkansas", "Louisiana", "Oklahoma", "Texas")
)

# West Region
df_mountain <- data.frame(
  Region = "West",
  Division = "Mountain",
  State = c(
    "Arizona",
    "Colorado",
    "Idaho",
    "Montana",
    "Nevada",
    "New Mexico",
    "Utah",
    "Wyoming"
  )
)
df_pacific <- data.frame(
  Region = "West",
  Division = "Pacific",
  State = c("Alaska", "California", "Hawaii", "Oregon", "Washington")
)

# Bind regions and divisions.
df_regions <-
  do.call(
    rbind,
    list(
      df_new_england,
      df_mid_atlantic,
      df_east_north_central,
      df_west_north_central,
      df_south_atlantic,
      df_east_south_central,
      df_west_south_central,
      df_mountain,
      df_pacific
    )
  )


sf_mortality <- readRDS("../climate_mortality_opinion/data/sf_mortalityid.rds")
# All_events_death_rate_rank (all_diff)
head(sf::st_drop_geometry(sf_mortality))


# Replace 08X01 with 08014 (Broomfield County, CO).
sf_mortality$GEOID[which(sf_mortality$GEOID == "08X01")] <- "08014"
sf_mortality$State[which(sf_mortality$GEOID == "08014")] <- "Colorado"
# Replace 51X01 with 51019 (Bedford County, VA).
sf_mortality$GEOID[which(sf_mortality$GEOID == "51X01")] <- "51019"
sf_mortality$State[which(sf_mortality$GEOID == "51019")] <- "Virginia"
# Replace 46113 with 46102 (Oglala Lakota County, SD).
sf_mortality$GEOID[which(sf_mortality$GEOID == "46113")] <- "46102"
sf_mortality$State[which(
  sf_mortality$GEOID == "46102"
)] <- "South Dakota"
sf_mortality$State[which(sf_mortality$GEOID == "30X01")] <- "Montana"

sf_mortality2 <- sf_mortality[, grep(
  "GEOID|State|County|rank",
  colnames(sf_mortality)
)]
head(sf::st_drop_geometry(sf_mortality2))
sf_mortality3 <- sf_mortality2[,
  c(
    "GEOID",
    "State",
    "County",
    "All_events_death_rate_rank",
    "Smoke_death_rate_rank",
    "Heat_death_rate_rank",
    "Flood_death_rate_rank",
    "Drought_death_rate_rank"
  )
]
names(sf_mortality3) <- c(
  "GEOID",
  "State",
  "County",
  "rank_all",
  "rank_smoke",
  "rank_heat",
  "rank_flood",
  "rank_drought",
  "geometry"
)
head(sf_mortality3)

sf_mortality4 <- merge(
  sf_mortality3,
  df_regions,
  by = "State",
  all.x = TRUE
)
dim(sf_mortality3)
dim(sf_mortality4)

head(sf_mortality4)
sf_mortality4[grep("Connecticut", sf_mortality4$State), ]
sf_mortality4[is.na(sf_mortality4$State), ]
xtoll <- sf_mortality4
