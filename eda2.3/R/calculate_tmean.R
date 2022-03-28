library(RPostgreSQL)
m<-PostgreSQL()
con=dbConnect(m,host="localhost",user="postgres",dbname="eda2.3")

#création de bv avec des températures moyennes, identifiés par seaidsegment
dbGetQuery(con, 'create table france.catchments as 
with france_catch as 
(select seaidsegment, st_convexhull(st_union(geom)) geom from france.rn group by seaidsegment),
temp as (select seaidsegment,sum(c.temp_mean*area)/sum(area) tmean,count(distinct gid) 
from  ccm21.catchments c inner join france_catch b on st_intersects(geom,the_geom) 
where "window" in (2002, 2003,2004) group by seaidsegment)
 select seaidsegment, tmean, geom from temp inner join france_catch using(seaidsegment)')

dbGetQuery(con, 'create table spain.catchments as with spain_catch as (select seaidsegment, st_convexhull(st_union(geom)) geom 
from spain.rn group by seaidsegment),
temp as (select seaidsegment,sum(c.temp_mean*area)/sum(area) tmean,count(distinct gid) from  ccm21.catchments c 
inner join spain_catch b on st_intersects(geom,the_geom) where "window" in (2003,2004) group by seaidsegment)
           select seaidsegment, tmean,geom from temp inner join spain_catch using(seaidsegment)')

dbGetQuery(con, 'create table portugal.catchments as with france_catch as (select seaidsegment, st_convexhull(st_union(geom)) geom 
from portugal.rn group by seaidsegment),
temp as (select seaidsegment,sum(c.temp_mean*area)/sum(area) tmean,count(distinct gid) from  ccm21.catchments c 
inner join portugal_catch b on st_intersects(geom,the_geom) where "window" in (2003,2004) group by seaidsegment)
           select seaidsegment, tmean,geom from temp inner join portugal_catch using(seaidsegment)')




#ajout d'une colonne tmean comme attribut des réseaux

dbGetQuery(con,'with temp_mean as(select r.gid, sum(temp_mean*area)/sum(area) tmean from france.rn r inner join ccm21.catchments on st_intersects(the_geom,geom) where "window" in (2003,2004) group by r.gid)
update france.rn set tmean=t.tmean from temp_mean t where t.gid=france.rn.gid')

dbGetQuery(con,"alter table portugal.rn add column tmean numeric")
dbGetQuery(con,'with temp_mean as(select r.gid, sum(temp_mean*area)/sum(area) tmean from portugal.rn r inner join ccm21.catchments on st_intersects(the_geom,geom) where "window" in (2003,2004) group by r.gid)
update portugal.rn set tmean=t.tmean from temp_mean t where t.gid=portugal.rn.gid')

dbGetQuery(con,"alter table spain.rn add column tmean numeric")
dbGetQuery(con,'with temp_mean as(select r.gid, sum(temp_mean*area)/sum(area) tmean from spain.rn r inner join ccm21.catchments on st_intersects(the_geom,geom) where "window" in (2003,2004) group by r.gid)
update spain.rn set tmean=t.tmean from temp_mean t where t.gid=spain.rn.gid')

