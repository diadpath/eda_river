##################################################################
# Function for loading and putting gml-files in postgis database #
##################################################################

# place zipped inspire gml files in a folder and convert data
# to postgis database
## Path to all zipped gml-files
path="c:/hydrografi_i_natverk/hydrografi"

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
  

command <- paste('"C:/Program Files/QGIS 3.16.16/OSGeo4W.bat"', # call shell
                 'ogr2ogr -f "PostgreSQL" PG:"host=localhost user=postgres dbname=eda2.3 password=postgres"', # connect to database
                 a, # file name
                 #"-sql ",
                 #'"select geometry from standingwater"', # select only certain data
                 "-append" # append to database
                 )

# append data to database
system(command)
unlink(a) # remove unzipped file
}

# load and append all gml-files physical waters to postgis database
for(i in 1:length(All_hyp)){
  
  ##############################
  # load hydropgraphic network #
  ##############################
  a <- unzip(All_hyp[i])
  print(All_hyp[i])
  for(j in 1:length(a)){
  command <- paste('"C:/Program Files/QGIS 3.16.16/OSGeo4W.bat"', # call shell
                   'ogr2ogr -f "PostgreSQL" PG:"host=localhost user=postgres dbname=eda2.3 password=postgres"', # connect to database
                   a[j], # file name
                   #"-sql ",
                   #'"select geometry from standingwater"', # select only certain data
                   "-append" # append to database
  )
  # append data to database
  system(command)
  }
  unlink(a)
}