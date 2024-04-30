-- integration des données de Florentina 
/*
voici la couche France en question avec qqs précisions. N'oubliez pas non plus qu'il s'agit d'une reconstitution d'une métrique en conditions "naturelles", sans influence des retenues, barrages, seuils ...

https://filesender.renater.fr/?s=download&token=5e9571e3-100d-4220-8991-e52ebb9b9369 
Tw_30j - estimation de la température moyenne sur 30jours consécutifs les plus chauds (2009-2017)
Tw_7j - estimations sur 7 jours ....
Ta_30J et Ta_7J = moyennes des températures atmosphériques sur la même période 
Plus de précisions dans le rapport du projet TIGRE et l'article publié suite à ce travail. Merci de citer ces deux travaux lors de vos restitutions.
A. Beaufort, F. Moatar, E. Sauquet, C. Magand, 2020. Thermie en rivière : Analyse géostatistique et description de régime : Application à l’échelle de la France, INRAE UR RiverLy, Université de Tours GéHCO, 63 pages + 53 pages d’annexes 
https://florentinamoatar.files.wordpress.com/2020/12/projet-tigre_rapport_final_2020.pdf
Beaufort, A., Diamond, J. S., Sauquet, E., and Moatar, F.: Spatial extrapolation of stream thermal peaks using heterogeneous time series at a national scale, Hydrol. Earth Syst. Sci., 26, 3477–3495, https://doi.org/10.5194/hess-26-3477-2022, 2022. 
https://hess.copernicus.org/articles/26/3477/2022/hess-26-3477-2022.pdf
*/

/*
 * -s précise le système de projection (SRS)
 * -d Supprime la table avant de la récréer avec les nouvelles données.
 * -I génère un index spatial (Gist)
 * -D Utilise des DUMP PostgreSQL
 * -g <geocolumn> Specify the name of the geometry/geography column
 *      (mostly useful in append mode).
 *  -k  Keep postgresql identifiers case.
 */
set PGPASSWORD=postgres&&psql -U postgres -c "create schema tigre" eda2.3
shp2pgsql -s 2154 -d -g geom -k -I -D "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_FRANCE" tigre.rht_mtw_predicted_france > "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_FRANCE.sql"
set PGPASSWORD=postgres&&psql -U postgres -f "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_FRANCE.sql" eda2.3 
shp2pgsql -s 2154 -d -g geom -k -I -D "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_PAYS_LOIRE" tigre.rht_mtw_predicted_pays_loire > "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_PAYS_LOIRE.sql"
set PGPASSWORD=postgres&&psql -U postgres -f "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_PAYS_LOIRE.sql" eda2.3 
shp2pgsql -s 2154 -d -g geom -k -I -D "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_BRETAGNE" tigre.rht_mtw_predicted_bretagne > "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_BRETAGNE.sql"
set PGPASSWORD=postgres&&psql -U postgres -f "D:\eda\data\eda2.3\temperatures\RHT_MTw_predicted_BRETAGNE.sql" eda2.3


set PGPASSWORD=postgres&&pgdump -U postgres -Fc -f "D:\eda\data\eda2.3\temperatures\export_RHT_temperatures.sql" --table tigre.rht_mtw_predicted_bretagne --table tigre.rht_mtw_predicted_pays_loire eda2.3
set PGPASSWORD=supersecret&&psql -U cbriand -f "D:\eda\data\eda2.3\temperatures\export_RHT_temperatures.sql" -h 162.19.62.98 geogwilen
set PGPASSWORD=supersecret&&psql -U cbriand -c "drop table  -h 162.19.62.98 geogwilen