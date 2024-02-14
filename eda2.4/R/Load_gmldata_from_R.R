##################################################################
# Function for loading and putting gml-files in postgis database #
##################################################################

# place zipped inspire gml files in a folder and convert data
# to postgis database
## Path to all zipped gml-files
path="c:/hydrografi_i_natverk/hydrografi/hyp"

# set working directory
setwd(path)

# list all gml-files with hydrographic network in directory
All_hyn <- list.files(pattern ="^inspire-hyn_.*3006.gml.zip$", all.files = FALSE,
           full.names = FALSE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

# list all zip-files with physical waters
All_hyp <- list.files(pattern ="^inspire-hyp_.*3006.gml.zip$", all.files = FALSE,
                      full.names = FALSE, recursive = FALSE,
                      ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)


# load and append all gml-files to postgis database
for(i in 1:length(All_hyn)){
  print(i)

##############################
# load hydropgraphic network #
##############################
  a <- unzip(All_hyn[i])
  hyn_gml_file <- list.files(pattern ="^inspire-hyn.*3006.gml$", all.files = FALSE,
                        full.names = FALSE, recursive = FALSE,
                        ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
  

command <- paste('"C:/Program Files/QGIS 3.22.14/OSGeo4W.bat"', # call shell
                 'ogr2ogr -f "PostgreSQL" PG:"host=localhost user=postgres dbname=eda2.4 password=postgres ACTIVE_SCHEMA=insp"', # connect to database
                 a, # file name
                 #"-sql ",
                 #'"select geometry from standingwater"', # select only certain data
              #   "-append", # append to database
                 "-oo XSD=https://inspire.ec.europa.eu/schemas/hy/4.0/HydroBase.xsd,https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd",
                 "--config GML_SKIP_RESOLVE_ELEMS HUGE",
                 "--config GML_ATTRIBUTES_TO_OGR_FIELDS YES",
                 "--config GML_PARSER XERCES",
                 "-oo WRITE_GFS=NO",
                 "-forceNullable",
                 "-append"
                 )

# append data to database
system(command)
unlink(a) # remove unzipped file
file.remove(list.files(pattern='resolved')) # remove resolved gml-files
}

# load and append all gml-files physical waters to postgis database
for(i in 1:length(All_hyp)){
  
  ##############################
  # load hydropgraphic network #
  ##############################
  a <- unzip(All_hyp[i])
  print(All_hyp[i])
  for(j in 1:length(a)){
  command <- paste('"C:/Program Files/QGIS 3.22.14/OSGeo4W.bat"', # call shell
                   'ogr2ogr -f "PostgreSQL" PG:"host=localhost user=postgres dbname=eda2.4 password=postgres ACTIVE_SCHEMA=insp"', # connect to database
                   "-oo XSD=https://inspire.ec.europa.eu/schemas/hy-p/4.0/HydroPhysicalWaters.xsd,https://inspire.ec.europa.eu/schemas/hy/4.0/HydroBase.xsd,https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd,https://inspire.ec.europa.eu/schemas/2021.1/hy-r/3.0/HydroReporting.xsd",
                   a[j], # file name
                   #"-sql ",
                   #'"select geometry from standingwater"', # select only certain data
                   "--config GML_ATTRIBUTES_TO_OGR_FIELDS YES",
                   #"--config GML_SKIP_RESOLVE_ELEMS HUGE",
                   "--config GML_PARSER XERCES",
                   "-oo WRITE_GFS=NO",
                   "-skipfailures",
                   "-forceNullable",
                   "-append" # append to database
  )
  # append data to database
  system(command)
  }
  unlink(a)
  file.remove(list.files(pattern='resolved')) # remove resolved gml-files
}