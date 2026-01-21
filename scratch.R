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
sf::st_write(xtoll, "xtoll2.geojson", delete_dsn = TRUE)

states <- sf::st_read("states.geojson")
us <- sf::st_union(states)
plot(us)
sf::st_write(us, "us.geojson", delete_dsn = TRUE)


color <- c(
  '#4575b4',
  '#74add1',
  '#abd9e9',
  '#fed976',
  '#feb24c',
  '#f03b20',
  '#bd0026'
)
