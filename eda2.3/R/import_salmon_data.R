########################################################################################
# Script qui va chercher les anciennes productions saumon réalisés dans DEVALPOMI 2015
# pour les écrire dans eda2.3 (en attendant qu'on fasse retourner les scripts de prédiction
# des habitats et de production de smolts sur tous les segments du RHT)
# date : 2023-06-29
# @uteur : Benjamin, Léa, Marion
########################################################################################

library(stringr)
library(dplyr)
library(RPostgres)
library(DBI)

getUsername <- function(){
	name <- Sys.info()[["user"]]
	return(name)
}

if(getUsername() == 'marion.legrand'){
		datawd<-"D:\\Documents\\Workspace_eclipse\\pdata\\devalpomi\\data\\"
	} else {
		datawd<-"C:\\workspace\\pdata\\devalpomi\\data\\"
} 

server <- "distant"# sinon "localhost" 

if (server == "localhost"){
	options(list(eda.dbname= "eda2.3",
					eda.host= "localhost",
					eda.password= passwordlocal,
					eda.user= userlocal,
					eda.port= 5432))
	
} else {
	if (!exists("mainpass")) stop("mainpass must be provided, configure R at startup")
	options(eda.dbname= "eda2.3",
			eda.host= decrypt_string(hostdistant, mainpass),
			eda.password= decrypt_string(passworddistant, mainpass),
			eda.user= decrypt_string(userdistant, mainpass),
			eda.port= 5432 )
}

con <- dbConnect(Postgres(), 
		dbname="eda2.3", 
		host=getOption("eda.host"),
		port=getOption("eda.port"), 
		user= getOption("eda.user"), 
		password= getOption("eda.password"))


#on charge le vieu jeu de données
load(str_c(datawd,"allba_prod_mod_actu.RData"))
rht <- ba@data

#on réécrit les id_drain pour qu'ils aient la même tête que dans eda2.3
rht$idsegment <- str_c("FR", rht$id_drain)
#on renomme le champ "N" qui n'est pas facile à réutiliser par la suite
rht<-rename(rht,eff_sat = "N")

# on ne récupère que les variables qui nous semblent intéressante à conserver
var<-c("idsegment", 
    "ratio", # représente en proportion les surfaces err par rapport à la surface totale du segment
    "region", 
    "presencesaumon", 
    "surfaceerr", 
     "geol", 
    "intensite_etiage", 
    "idbvia", 
    "pred", #ne sais pas trop ce qu'on prédit : les tacon 0+ ?
    "s_err_mod", 
    "s_err_obs", 
    "date", 
    "preddensactu",
    "preddenspristine", 
    "preddens", 
    "eff_sat", 
    "IC-5\\%",
    "Moy", 
    "IC-95\\%",
    "prod_mod_hist",
    "prod_mod_actu", 
    "prod_obs", 
    "prod_obs_5", 
    "prod_obs_95"
)

rht_sat<-rht%>%select(all_of(var))

DBI::dbExecute(con,"DROP TABLE IF EXISTS france.temp_rns")
DBI::dbWriteTable(
		conn= con, 
		name = DBI::Id(
				schema="france",
				table="temp_rns"),
		value = rht_sat,
		overwrite =TRUE
)


