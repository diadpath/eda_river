silver_eel_upstream.R
# Calculation of upstream production using BaseEdaRiosRiversegment class
#
# EDA2.3 
# EPTB, AZTI
# Author: Cédric Briand and María Mateo
###############################################################################

#**********************************************************#
#     Downloading init (library & codes necessary)         #
#**********************************************************#
setwd("C:/workspace/EDA/")
require("RPostgreSQL")
require("sqldf")
library("sp")
library("rgdal")
library("sf")
source("EDACCM/init.r")

#options(warn =  -1)
options(sqldf.RPostgreSQL.user = "postgres", 
		sqldf.RPostgreSQL.password = passwordlocal,
		sqldf.RPostgreSQL.dbname = "eda2.3",
		sqldf.RPostgreSQL.host = "localhost",#  1.100.1.6
		sqldf.RPostgreSQL.port = 5432)

#  correcting problems with river width and chaining.... running all again

rios_surf <- new('BaseEdaRiosRiversegments',
		baseODBC = "baseODBCrios",
		schema = "dbeel_rivers", 		
		table = "rn",
		prkey = "idsegment", 
		zonegeo = 'all',
		basin=as.character(NULL),
		emu=as.character(NULL)) 

rios_surf  <- loaddb_all(rios_surf)#1.3 min
save(rios_surf, file=str_c(ddatawd,'rios_surf.Rdata'))
rios_surf <- silver_eel_production(rios_surf) 



silver_upstream <- rios_surf@data
save(silver_upstream, file=str_c(datawd,"silver_upstream.Rdata"))
sqldf("drop table if exists dbeel_rivers.rn_rna_cumul_silver")
system.time(sqldf("create table dbeel_rivers.rn_rna_cumul_silver as 
SELECT 	idsegment, cnfemale300450,cnfemale450600, cnfemale600750, cnfemale750, 
cnmale150300, cnmale300450, cnmale450600, 
cnsilver150300, cnsilver300450, cnsilver450600, cnsilver600750, cnsilver750, 
cnsilver FROM silver_upstream
")) #72 s
sqldf("SELECT AddGeometryColumn ('dbeel_rivers','rn_rna_cumul_silver','geom',3035,'MULTILINESTRING',2, false);
				UPDATE  dbeel_rivers.rn_rna_cumul_silver set geom=rn.geom FROM
				dbeel_rivers.rn   WHERE rn.idsegment=rn_rna_cumul_silver.idsegment;")

