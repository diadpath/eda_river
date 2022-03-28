# Programme de calcul des débits classés pour l'anguille et le saumon
# SUDOANG Adataptation au format de téléchargement 2019
# Author: cedric.briand
###############################################################################

require(sqldf)
require(RPostgreSQL)
require(stacomirtools)
require(stringr)
getUsername <- function(){
	name <- Sys.info()[["user"]]
	return(name)
}
if(getUsername() == 'cedric.briand')
{
	options(sqldf.RPostgreSQL.user = "postgres", 
			sqldf.RPostgreSQL.password = passworddistant,
			sqldf.RPostgreSQL.dbname = "ouvragelb",
			sqldf.RPostgreSQL.host = "1.100.1.6",# 1.100.1.6 w3.eptb-vilaine.fr
			sqldf.RPostgreSQL.port = 5432)
	
	setwd("C:/workspace/p/devalpomi")
	datawd<-"C:/workspace/EDAdata/"
	imgwd<-""
	shpwd="" # where I store the shape file
}

#####################################################
# Chargement des données du Gave de Pau
######################################################

chemin=str_c(datawd,"sudoang/", "Pau_Q5501010_1923_2017.csv")

# Fonction d'extaction des débits du ficher délimité ----------------------------------------------------------

getflow <- function(chemin){
#récupère le fichier dans un format non contraint
	con  <- file(chemin, open = "r")
# la fonction readLines renvoit un vecteur charactère, un élément par ligne
	re<- readLines(con,warn = FALSE)
	close(con) # je referme la connexion
# on va chercher les lignes ou est marqué "Débit journalier ... c'est ce qui nous intéresse.
	lines_annual_table<-which(sapply(strsplit(re,";"),function(X)X[1]==iconv("Débits journaliers","UTF8")))
	
# line = lines_annual_table[1]
# extract_table(lines_annual_table[1])
	extract_table <- function(line){
		
		table_headers_month <- unlist(strsplit(re[(line+1):(line+1)],";"))
		table_headers_type <- unlist(strsplit(re[(line+2):(line+2)],";"))
		donneej <- strsplit(re[(line+3):(line+33)],";")
		# in many cases we may have only 24 columns if there is no term precising "estimated" in the 25th column...
		donneej <- lapply(donneej,function(X)if (length(X)==24) X <- c(X,""))
		
		donneej <- suppressWarnings(as.numeric(unlist(donneej)))
		donneej_year <- unlist(strsplit(re[(line+34)],";"))[1] # "Procédure : QJM - Année : 1924"
		options(warn=-1)
		donneej_year <- as.numeric(strsplit(donneej_year,":")[[1]][3])-1
		donneej <- as.data.frame(matrix(donneej,ncol=25,byrow=TRUE))
		table <- donneej[,c(1,seq(2,24,by=2))]
		tablesuppl <- donneej[,c(1,seq(3,25,by=2))]
		colnames(table) <- c("jour",as.character(1:12))
		colnames(tablesuppl) <- c("jour",as.character(1:12))
		mtable <- melt(table,variable.name ="mois",id.vars="jour")
		mtable$date <- as.Date(str_c(donneej_year,"-",mtable$mois,"-",mtable$jour))
		mtablesuppl <- melt(tablesuppl,variable.name ="mois",id.vars="jour")
		mtablesuppl$date <- as.Date(str_c(donneej_year,"-",mtablesuppl$mois,"-",mtablesuppl$jour))		
		mtable <- mtable[!is.na(mtable$date),c(4,3)]	# certaines dates n'existent pas
		mtablesuppl <- mtablesuppl[!is.na(mtablesuppl$date),c(4,3)]	# certaines dates n'existent pas
		mtablef <- merge(mtable,mtablesuppl,by="date")
		colnames(mtablef) <- c("date","debit","calcul")
		return(mtablef)
	}
# on applique la fonction à tous les éléments de la liste
	ll <- lapply(lines_annual_table,  extract_table)
	res <- do.call(rbind,ll) # concatène toutes les lignes dans un tableau
	res <- res[order(res$date),]
	return(res)
}
dat <- getflow(str_c(datawd,"sudoang/", "Pau_Q5501010_1923_2017.csv"))




# TODO rbind sur toutes les stations hydro



# calcul des débits classés ----------------------------------------------------------

plot(dat[,c(1,2)])
dat$station <- "Gave de Pau"
dat$m<-strftime(as.POSIXct(dat$date),format="%m")
dat$y<-as.numeric(strftime(as.POSIXct(dat$date),format="%Y"))
# choix des années
dat1004<-dat[dat$m%in%c("10","11","12","01","02","03","04")&dat$y>=1982&dat$y<2018,]
debits_classes_anguille<-tapply(dat1004$debit,dat1004$station,function(X)quantile(X,c(0.75,0.9,0.95,0.975,0.99),na.rm=TRUE))

dat$station <- "Gave de Pau"
dat$m<-strftime(as.POSIXct(dat$date),format="%m")
dat$y<-as.numeric(strftime(as.POSIXct(dat$date),format="%Y"))
dat$saison <- dat$y
dat$saison[dat$m%in%c("01","02","03","04")] <- dat$saison[dat$m%in%c("01","02","03","04")]-1
# choix des années
dat1002<-dat[dat$m%in%c("10","11","12","01")&dat$saison==2008,]
debits_classes_anguille<-tapply(dat1002$debit,dat1002$station,function(X)quantile(X,c(0.75,0.9,0.95,0.975,0.99),na.rm=TRUE))





debloire[debloire$code_hydro=="L8222110"&debloire$value=="858000"&!is.na(debloire$value),"value"]<-NA

debloire<-debloire[!is.na(debloire$date),]
debloire$m<-strftime(as.POSIXct(debloire$date),format="%m")
debloire$y<-as.numeric(strftime(as.POSIXct(debloire$date),format="%Y"))
debloire0305<-debloire[debloire$m%in%c("03","04","05")&debloire$y>=1982&debloire$y<2013,]
debits_classes_saumon<-tapply(debloire0305$value,debloire0305$code_hydro,function(X)quantile(X,c(0.1,0.3,0.5,0.7,0.9),na.rm=TRUE))
debits_classes_saumon<-as.data.frame(t(do.call(cbind.data.frame, debits_classes_saumon)))
debits_classes_saumon<-cbind("code_hydro"=rownames(debits_classes_saumon),debits_classes_saumon)
colnames(debits_classes_saumon)[2:6]<-str_c("q_0305_",substr(colnames(debits_classes_saumon),1,2)[2:6],"_bh")
extact_min_or_max<-function(dat,fun=min){
	annees_extr<-tapply(dat$y,dat$code_hydro,fun)
	annees_extr<-data.frame("code_hydro"=names(annees_extr), "val"<-annees_extr)
	return(annees_extr)
}
dfmin<-extact_min_or_max(debloire0305,min)
colnames(dfmin)<-c("code_hydro","min")
dfmax<-extact_min_or_max(debloire0305,max)
colnames(dfmax)<-c("code_hydro","max")
debits_classes_saumon<-merge(debits_classes_saumon,dfmin)
debits_classes_saumon<-merge(debits_classes_saumon,dfmax)


debits_classes_anguille<-as.data.frame(t(do.call(cbind.data.frame, debits_classes_anguille)))
debits_classes_anguille<-cbind("code_hydro"=rownames(debits_classes_anguille),debits_classes_anguille)
colnames(debits_classes_anguille)[2:6]<-str_c("q_1004_",substr(colnames(debits_classes_anguille),1,2)[2:6],"_bh")
debits_moyens<-tapply(debloire$value,debloire$code_hydro,mean,na.rm=TRUE)
debits_moyens<-data.frame("code_hydro"=names(debits_moyens),"module"=debits_moyens)
debits_classes<-merge(debits_classes_anguille,debits_classes_saumon,by="code_hydro")
debits_classes<-merge(debits_classes,debits_moyens,by="code_hydro")


stations<-killfactor(read.csv(str_c(datawd,"sta_loire.csv"),sep=";"))
colnames(stations)<-c("bv","station_de_reference_hydrologique","commentaire","code_hydro","X","Y")
head(stations)
head(debits_classes_anguille)
staloire<-as.data.frame(staloire)
staloire<-staloire[,c(2,3)]
colnames(staloire)<-c("code_hydro","nom_station")
stations<-merge(staloire,stations,by="code_hydro")
debits_classes<-merge(stations,debits_classes,by="code_hydro")
colnames(debits_classes)<-tolower(colnames(debits_classes))
#ex(debits_classes)
sqldf("drop table if exists lb.debits_classes",host=getOption("sqldf.RPostgreSQL.host"))			
sqldf("create table lb.debits_classes as select 
				* from debits_classes",					
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host")) # #convert_to(turb_description, 'UTF8') 

sqldf("
				alter table lb.debits_classes add constraint c_pk_debits_classes primary key(code_hydro);
				select addgeometrycolumn('lb','debits_classes','geom',3035,'POINT',2);
				update lb.debits_classes set geom= st_transform(ST_GeomFromText('POINT('||x||' '||y ||')',27572),3035) ;
				alter table lb.debits_classes add column id_drain integer;
				update lb.debits_classes set id_drain =sub.id_drain from (
				select distinct on (code_hydro) code_hydro,sub.id_drain,min(distance) as distance from
				(select st_distance(d.geom,r.the_geom) as distance, d.code_hydro,r.id_drain from lb.debits_classes d 
				join rht.rhtvs2_loirebretagne r on st_dwithin(d.geom,r.the_geom,500))sub
				group by  code_hydro, distance,id_drain) sub
				where debits_classes.code_hydro=sub.code_hydro;
				update lb.debits_classes set id_drain = 224537 where code_hydro='K1440010';--il y a un pb de projection
				update lb.debits_classes set id_drain= 216846 where code_hydro='K6192420';--il y a un pb de projection
				",
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host")) 



# load(file="debits_classes.Rdata")
############################
# Traitement des données Bretagne
############################
debbre<-killfactor(read.table(file=str_c(datawd,"/hydro_bretagne.csv"),sep=";"))
str(debbre)
debbre[,2]<-as.Date(strptime(debbre[,2],format="%d/%m/%Y"))
colnames(debbre)<-c("code_hydro","date","value")
debbre$code_hydro[debbre$code_hydro=="J5712140"]<-"J5712130"
debbre$code_hydro[debbre$code_hydro=="J9300611"]<-"J9300610"
debbre<-debbre[!is.na(debbre$date),]
debbre$m<-strftime(as.POSIXct(debbre$date),format="%m")
debbre$y<-as.numeric(strftime(as.POSIXct(debbre$date),format="%Y"))
debbre0305<-debbre[debbre$m%in%c("03","04","05")&debbre$y>=1982&debbre$y<2013,]
debits_classes_saumon<-tapply(debbre0305$value,debbre0305$code_hydro,function(X)quantile(X,c(0.1,0.3,0.5,0.7,0.9),na.rm=TRUE))
debits_classes_saumon<-as.data.frame(t(do.call(cbind.data.frame, debits_classes_saumon)))
debits_classes_saumon<-cbind("code_hydro"=rownames(debits_classes_saumon),debits_classes_saumon)
colnames(debits_classes_saumon)[2:6]<-str_c("q_0305_",substr(colnames(debits_classes_saumon),1,2)[2:6],"_bh")
extact_min_or_max<-function(dat,fun=min){
	annees_extr<-tapply(dat$y,dat$code_hydro,fun)
	annees_extr<-data.frame("code_hydro"=names(annees_extr), "val"<-annees_extr)
	return(annees_extr)
}
dfmin<-extact_min_or_max(debbre0305,min)
colnames(dfmin)<-c("code_hydro","min")
dfmax<-extact_min_or_max(debbre0305,max)
colnames(dfmax)<-c("code_hydro","max")
debits_classes_saumon<-merge(debits_classes_saumon,dfmin)
debits_classes_saumon<-merge(debits_classes_saumon,dfmax)

debbre1004<-debbre[debbre$m%in%c("10","11","12","01","02","03","04")&debbre$y>=1982&debbre$y<2013,]
debits_classes_anguille<-tapply(debbre1004$value,debbre1004$code_hydro,function(X)quantile(X,c(0.75,0.9,0.95,0.975,0.99),na.rm=TRUE))
debits_classes_anguille<-as.data.frame(t(do.call(cbind.data.frame, debits_classes_anguille)))
debits_classes_anguille<-cbind("code_hydro"=rownames(debits_classes_anguille),debits_classes_anguille)
colnames(debits_classes_anguille)[2:6]<-str_c("q_1004_",substr(colnames(debits_classes_anguille),1,2)[2:6],"_bh")
debits_moyens<-tapply(debbre$value,debbre$code_hydro,mean,na.rm=TRUE)
debits_moyens<-data.frame("code_hydro"=names(debits_moyens),"module"=debits_moyens)
debits_classes<-merge(debits_classes_anguille,debits_classes_saumon,by="code_hydro")
debits_classes<-merge(debits_classes,debits_moyens,by="code_hydro")


stations<-killfactor(read.csv("F:/IAV/Publications/devalpomi/sta_bre.csv",sep=";"))
colnames(stations)<-c("bv","nom_station","commentaire","code_hydro","x","y","id_drain")
head(stations)
head(debits_classes_anguille)
debits_classes<-merge(stations,debits_classes,by="code_hydro")
colnames(debits_classes)<-tolower(colnames(debits_classes))

#ex(debits_classes)

sqldf("delete from lb.debits_classes where code_hydro in (select code_hydro from debits_classes);
				insert into lb.debits_classes (
				code_hydro,nom_station,bv,x,y,q_0305_90_bh,q_0305_70_bh,q_0305_50_bh,q_0305_30_bh,
				q_0305_10_bh,q_1004_99_bh,q_1004_97_bh,q_1004_95_bh,q_1004_90_bh,q_1004_75_bh,module,min,max) 
				select
				code_hydro,nom_station,bv,x,y,q_0305_90_bh,q_0305_70_bh,q_0305_50_bh,q_0305_30_bh,
				q_0305_10_bh,q_1004_99_bh,q_1004_97_bh,q_1004_95_bh,q_1004_90_bh,q_1004_75_bh,module,min,max
				from debits_classes",					
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host")) # #convert_to(turb_description, 'UTF8') 

sqldf("			update lb.debits_classes set geom= st_transform(ST_GeomFromText('POINT('||x||' '||y ||')',27572),3035) ;
				
				update lb.debits_classes set id_drain =sub.id_drain from (
				select distinct on (code_hydro) code_hydro,sub.id_drain,min(distance) as distance from
				(select st_distance(d.geom,r.the_geom) as distance, d.code_hydro,r.id_drain from lb.debits_classes d 
				join rht.rhtvs2_loirebretagne r on st_dwithin(d.geom,r.the_geom,500))sub
				group by  code_hydro, distance,id_drain) sub
				where debits_classes.code_hydro=sub.code_hydro;
				update lb.debits_classes set id_drain = 224537 where code_hydro='K1440010';--il y a un pb de projection
				update lb.debits_classes set id_drain= 216846 where code_hydro='K6192420';--il y a un pb de projection
				update lb.debits_classes set bv=replace(bv,'BV ','');
				",
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host")) 


############################
#Chargement final
##########################

debits_classes<-sqldf("select 
				code_hydro,
				nom_station,
				bv,
				commentaire,
				station_de_reference_hydrologique,
				x as xl2,
				y as yl2,
				min as year_min,
				max as year_max,
				module as module_annuel_bh,
				q_0305_10_bh,
				q_0305_30_bh,
				q_0305_50_bh,
				q_0305_70_bh,
				q_0305_90_bh,
				q_1004_75_bh,
				q_1004_90_bh,
				q_1004_95_bh,
				q_1004_97_bh as q_1004_975_bh,
				q_1004_99_bh,
				id_drain
				from lb.debits_classes",					
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host"))	
# sbvu surface bassin vesrant unitaire km2
# module_icinf Limite inférieur IC du débit moyen           (m3) /s
# module_icsup  Limite supérieure IC du débit moyen           (m3) /s
rht_data<-sqldf("select r.id_drain,sfbvu, module_icinf as module_icinfrht,r.module as module_rht,
				module_icsup as module_icsuprht 
				from debits_classes d join rht.attributs_rht_fev_2011_vs2 r
				on d.id_drain=r.id_drain",					
		dbname="eda2.1",host=getOption("sqldf.RPostgreSQL.host"))# debits_classes_rht
debits_classes<-merge(debits_classes,rht_data,by="id_drain")


debits_classes$ratio_rht_over_bh<-as.numeric(debits_classes$module_rht)/(as.numeric(debits_classes$module_annuel_bh)/1000)
resetencoding<-function(data,from="UTF-8",to="latin1"){
	col<-(1:ncol(data))[sapply(data, is.character)]
	for (i in col){
		data[,i]<-iconv(data[,i],from=from,to=to)
	}
	return(data)
}
debits_classes<-resetencoding(debits_classes)
# correction du module pour le Thouest à Missé (vérifier que la correction a été effectuée précedemment.
#debits_classes[debits_classes$code_hydro=="L8222110",module_annuel_bh]<-module_rht


debits_classes[,c("n_0305_10_rht","n_0305_30_rht","n_0305_50_rht","n_0305_70_rht","n_0305_90_rht")]<-
		round(debits_classes[,c("q_0305_10_bh","q_0305_30_bh","q_0305_50_bh","q_0305_70_bh","q_0305_90_bh")]/(1000*as.numeric(debits_classes$module_rht)),2)
# le débit de chaque classe est rapporté au module, mais le module est lui même rapporté au débit de la banque hydro sur la période concernée, ici mars à mai
# le débit du module est calculé comme débit classé banque hydro/module rht. Les valeurs de chaque débit de chaque tronçon seront donc rapportées
# au débit de la banque hydro, il faudra multiplier par le débit rht de chaque tronçon
debits_classes[,c("n_1004_75_rht","n_1004_90_rht","n_1004_95_rht","n_1004_975_rht","n_1004_99_rht")]<-
		round(debits_classes[,c("q_1004_75_bh","q_1004_90_bh","q_1004_95_bh","q_1004_975_bh","q_1004_99_bh")]/(1000*as.numeric(debits_classes$module_rht)),2)
sqldf("alter table rht.bv_hydro drop constraint c_fk_hydro_ref",host=getOption("sqldf.RPostgreSQL.host"))	
sqldf("drop table if exists lb.debits_classes_final",host=getOption("sqldf.RPostgreSQL.host"))			
sqldf("create table lb.debits_classes_final as select 
				* from debits_classes",					
		dbname=getOption("sqldf.RPostgreSQL.dbname"),host=getOption("sqldf.RPostgreSQL.host")) # #convert_to(turb_description, 'UTF8') 
sqldf("alter table lb.debits_classes_final add column hydro_ref character varying (20) unique;
				update lb.debits_classes_final set hydro_ref='LEGUER' where bv='Léguer';
				update lb.debits_classes_final set hydro_ref='SCORFF' where bv='Scorff';
				update lb.debits_classes_final set hydro_ref='COUESNON' where bv='Couesnon';
				update lb.debits_classes_final set hydro_ref='AULNE' where bv='Aulne';
				update lb.debits_classes_final set hydro_ref='BLAVET' where bv='Blavet';
				update lb.debits_classes_final set hydro_ref='VILAINE' where bv='Vilaine';
				update lb.debits_classes_final set hydro_ref='HUISNE' where bv='Huisne';
				update lb.debits_classes_final set hydro_ref='MAYENNE' where bv='Mayenne';
				update lb.debits_classes_final set hydro_ref='SARTHE' where bv='Sarthe (hors Huisne)';
				update lb.debits_classes_final set hydro_ref='LOIR' where bv='Loir';
				update lb.debits_classes_final set hydro_ref='SAULDRE AMONT' where bv=
				'Sauldre amont + latéraux Loire moyenne en amont du Cher';
				update lb.debits_classes_final set hydro_ref='SAULDRE' where bv=
				'Sauldre en aval de Brinon ';
				update lb.debits_classes_final set hydro_ref='ARNON' where bv=
				'Arnon ';
				update lb.debits_classes_final set hydro_ref='SEVRE NANTAISE' where bv=
				'affluents Loire aval Cher et hors Vienne Thouet';
				update lb.debits_classes_final set hydro_ref='INDRE' where bv=
				'Indre ';
				update lb.debits_classes_final set hydro_ref='THOUET' where bv=
				'Thouet';
				update lb.debits_classes_final set hydro_ref='YEVRE' where bv=
				'Yèvre ';
				update lb.debits_classes_final set hydro_ref='ARROUX' where bv=
				'Arroux';
				update lb.debits_classes_final set hydro_ref='CLAIN' where bv=
				'Clain';
				update lb.debits_classes_final set hydro_ref='CHER AMONT' where bv=
				'Cher amont';
				update lb.debits_classes_final set hydro_ref='CREUSE' where bv=
				'Creuse ';
				update lb.debits_classes_final set hydro_ref='COTIERS VENDEENS' where bv=
				'cotier vendéens';
				update lb.debits_classes_final set hydro_ref='SEVRE NIORTAISE' where bv=
				'Sèvre Niortaise';
				update lb.debits_classes_final set hydro_ref='CREUSE' where bv=
				'Creuse ';
				update lb.debits_classes_final set hydro_ref='GARTEMPE' where bv=
				'Gatempe';
				update lb.debits_classes_final set hydro_ref='ALAGNON' where bv=
				'Allagnon + autres affluents de l''Allier';
				update lb.debits_classes_final set hydro_ref='ALLIER' where bv=
				'Allier amont';
				update lb.debits_classes_final set hydro_ref='VIENNE' where bv=
				'Vienne (hors Creuse Gartempe Clain)';
				update lb.debits_classes_final set hydro_ref='DORE' where bv=
				'Dore';
				update lb.debits_classes_final set hydro_ref='SIOULE' where bv=
				'Sioule';
				update lb.debits_classes_final set hydro_ref='LOIRE AMONT' where bv=
				'Loire amont Villerest';
				update lb.debits_classes_final set hydro_ref='LOIRE MOYENNE' where bv=
				'axe Loire aval Villerest';
				update lb.debits_classes_final set hydro_ref='ALLIER AVAL' where bv=
				'Allier aval';",host=getOption("sqldf.RPostgreSQL.host"))	
sqldf("alter table rht.bv_hydro ADD CONSTRAINT c_fk_hydro_ref FOREIGN KEY (hydro_ref)
				REFERENCES lb.debits_classes_final (hydro_ref)",host=getOption("sqldf.RPostgreSQL.host"))	
#pg_dump -U postgres -h w3.eptb-vilaine.fr --table lb.debits_classes_final -f "debits_classes_final.sql" ouvragelb

save(debits_classes, file=str_c(getwd(),"/R/data/debits_classes.Rdata"))
ex(debits_classes)