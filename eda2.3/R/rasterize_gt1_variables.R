# Name : rasterize_gt1_variables.R
# Date : 21/12/2020
# Authors: María Mateo, Cédric Briand & María Korta
#
# Variables
#		- Altitude: line 34
#		- Distance to the sea: line 93
###############################################################################

# Set paths
#-----------------------------------------
datawd <- "C:/workspace/EDAdata/"
ddatawd <- paste0(datawd,"/report2.3/data/")
imgwd <- paste0(datawd,"/report2.3/images/")


# Libraries
#-----------------------------------------
packs <- list("RPostgreSQL", "sf", "sp", "raster", "leaflet", "leaflet.opacity", "gstat", "sqldf", "stars", "leafem")
lapply(packs, require, character.only = T)


# Connect to the database
#------------------------------------------
con = 	dbConnect(PostgreSQL(),
		dbname="eda2.3",
		host="localhost",
		port=5432,
		user= userlocal,
		password= passwordlocal)

# sqldf("select count(*) from dbeel_rivers.rn_rna where country = 'SP'", connection = con) # 325 399 rows
# sqldf("select count(*) from dbeel_rivers.rn_rna where country = 'PT'", connection = con) #  75 056 rows
# sqldf("select count(*) from dbeel_rivers.rn_rna where country = 'FR'", connection = con) # 114 556 rows

#-----------------------------------------
# ALTITUDE
#------------------------------------------

# Loading data for the riversegments
#------------------------------------------
rn_spain <- read_sf(con,query=paste("select idsegment, altitudem, country, geom FROM dbeel_rivers.rn_rna where country = 'SP'")) 	# 325 399 rows
rn_portugal <- read_sf(con,query=paste("select idsegment, altitudem, country, geom FROM dbeel_rivers.rn_rna where country = 'PT'")) #  75 056 rows
rn_france <- read_sf(con,query=paste("select idsegment, altitudem, country, geom FROM dbeel_rivers.rn_rna where country = 'FR'")) 	# 114 556 rows

altitudem <- rbind(rn_spain, rn_portugal, rn_france) # 515 011 rows
# head(altitudem)
# 	Simple feature collection with 6 features and 3 fields
#	geometry type:  MULTILINESTRING
#	dimension:      XY
#	bbox:           xmin: 2877583 ymin: 1638255 xmax: 3580913 ymax: 2449086
# 	projected CRS:  ETRS89-extended / LAEA Europe
rm(rn_spain, rn_portugal, rn_france)


# Simplifying sf object
# altitudem_simp <- st_simplify(altitudem, dTolerance = 2000)  # 2000 m

# Reprojecting geographic data, leaflet -> WF84
#--------------------------------------------------
altitudem_reproj <- st_transform(altitudem, 4326)
rm(altitudem)
save(altitudem_reproj, file = paste0(ddatawd, "altitudem_reproj.Rdata"))


# Rasterizing sf object
#------------------------------------------
altitudem0 = st_rasterize(altitudem_reproj, st_as_stars(st_bbox(altitudem_reproj), options = "ALL_TOUCHED=TRUE", nx = 2000, ny = 2000, values = NA_real_))

# Convert stars object into raster
altitudem = as(altitudem0, "Raster")
rm(altitudem0)


# Saving the data
#------------------------------------------
writeRaster(altitudem, filename = paste0(imgwd, "altitudem.tif"))
save(altitudem, file = paste0(ddatawd, "altitudem.Rdata"))


# Mapping into leaflet
#------------------------------------------
pal <- colorNumeric(rainbow(12, alpha=0.5), values(altitudem),
		na.color = "transparent")

leaflet() %>% addTiles() %>% 
		addRasterImage(altitudem, opacity = 0.8, layerId = "raster") %>%
		addLegend(pal = pal, values = values(altitudem), title = "Altitude in m") %>%
		addOpacitySlider(layerId = "raster")



#-----------------------------------------
# DISTANCE TO THE SEA
#------------------------------------------

# Loading data for the riversegments
#------------------------------------------
rn_spain <- read_sf(con,query=paste("select idsegment, distanceseam, country, geom FROM dbeel_rivers.rn_rna where country = 'SP'")) 	# 325 399 rows
rn_portugal <- read_sf(con,query=paste("select idsegment, distanceseam, country, geom FROM dbeel_rivers.rn_rna where country = 'PT'")) #  75 056 rows
rn_france <- read_sf(con,query=paste("select idsegment, distanceseam, country, geom FROM dbeel_rivers.rn_rna where country = 'FR'")) 	# 114 556 rows

distanceseam <- rbind(rn_spain, rn_portugal, rn_france) # 515 011 rows
# head(distanceseam)
rm(rn_spain, rn_portugal, rn_france)


# Reprojecting geographic data, leaflet -> WF84
#--------------------------------------------------
distanceseam_reproj <- st_transform(distanceseam, 4326)
rm(distanceseam)


# Rasterizing sf object
#------------------------------------------
distanceseam0 = st_rasterize(distanceseam_reproj, st_as_stars(st_bbox(distanceseam_reproj), options = "ALL_TOUCHED=TRUE", nx = 2000, ny = 2000, values = NA_real_))

# Convert stars object into raster
distanceseam = as(distanceseam0, "Raster")
rm(distanceseam0)


# Saving the data
#------------------------------------------
writeRaster(distanceseam, filename = paste0(imgwd, "distanceseam.tif"))
save(distanceseam, file = paste0(ddatawd, "distanceseam.Rdata"))
 

# Mapping into leaflet
#------------------------------------------
pal <- colorNumeric(rainbow(12, alpha=0.5), values(distanceseam),
		na.color = "transparent")

leaflet() %>% addTiles() %>% 
		addRasterImage(distanceseam, opacity = 0.8, layerId = "raster") %>%
		addLegend(pal = pal, values = values(distanceseam), title = "Distance to the sea in m") %>%
		addOpacitySlider(layerId = "raster")


