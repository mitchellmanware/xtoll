################################################################################
# Manually define the US regions and divisions with their respective states.
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

################################################################################
# Import mortality data from RDS file used in regression analyses.
sf_mortality <- readRDS(
  "../../climate_mortality_opinion/data/sf_mortalityid.rds"
)
head(sf::st_drop_geometry(sf_mortality))

################################################################################
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

################################################################################
# Check for any missing or unusual GEOID values.
sf_mortality$GEOID[is.na(sf_mortality$GEOID)]
# Check for Connecticut data.
sf_mortality[grep("Connecticut", sf_mortality$State), ]

################################################################################
# Subset relevant columns and rename them for easier use.
sf_mortality2 <- sf_mortality[,
  c(
    "GEOID",
    "State",
    "County",
    "All_events_death_rate_rank",
    "Smoke_death_rate_rank",
    "Heat_death_rate_rank",
    "Cold_death_rate_rank",
    "Flood_death_rate_rank",
    "Drought_death_rate_rank"
  )
]
names(sf_mortality2) <- c(
  "GEOID",
  "State",
  "County",
  "rank_all",
  "rank_smoke",
  "rank_heat",
  "rank_cold",
  "rank_flood",
  "rank_drought",
  "geometry"
)
head(sf_mortality2)

################################################################################
# Merge mortality data with regional data based on State.
sf_mortality3 <- merge(
  sf_mortality2,
  df_regions,
  by = "State",
  all.x = TRUE
)
head(sf_mortality3)
dim(sf_mortality3)

################################################################################
df_xtoll <- sf_mortality3

################################################################################
# Calculate percentage values for each rank column.
df_xtoll$perc_all <- round(
  100 - (df_xtoll$rank_all / max(df_xtoll$rank_all) * 100),
  2
)
df_xtoll$perc_smoke <- round(
  100 - (df_xtoll$rank_smoke / max(df_xtoll$rank_smoke) * 100),
  2
)
df_xtoll$perc_heat <- round(
  100 - (df_xtoll$rank_heat / max(df_xtoll$rank_heat, na.rm = TRUE) * 100),
  2
)
df_xtoll$perc_cold <- round(
  100 - (df_xtoll$rank_cold / max(df_xtoll$rank_cold, na.rm = TRUE) * 100),
  2
)
df_xtoll$perc_flood <- round(
  100 - (df_xtoll$rank_flood / max(df_xtoll$rank_flood) * 100),
  2
)
df_xtoll$perc_drought <- round(
  100 - (df_xtoll$rank_drought / max(df_xtoll$rank_drought) * 100),
  2
)
head(df_xtoll)
tail(df_xtoll)

################################################################################
# Check missing heat and cold ranks.
sum(!is.na(df_xtoll$rank_heat))
sum(!is.na(df_xtoll$rank_cold))

################################################################################
# Save the processed data to a GeoJSON file.
sf::st_write(df_xtoll, "data/xtoll1.geojson", delete_dsn = TRUE)

################################################################################
# Save the processed data to a CSV file.
write.csv(df_xtoll, "data/xtoll.csv", row.names = FALSE)
