# 
# Author: hilaire
###############################################################################



library(RPostgreSQL)
m=PostgreSQL()
con=dbConnect(m,host="localhost",user="hilaire",dbname="doeda2")

#intersection des polygones surfaces bdtopo avec les bv unitaires rht
dbGetQuery(con,"drop table if exists bdtopo_hydrographie.rht_toposurface;
				create table bdtopo_hydrographie.rht_toposurface as
				select array_agg(code_hydrographique) list_codhydro, 
			gridid as iddrain, 
			st_intersection(r.geom,
				st_makevalid(st_transform(st_union(geometrie),27572))) geom
			 from rht.bvunitaire r 
			inner join bdtopo_hydrographie.surface_hydrographique s 
		on st_intersects(st_makevalid(st_transform(geometrie,27572)),r.geom) 
			where persistance='Permanent' and nature in ('Lagune','Estuaire','Ecoulement naturel','Canal','Retenue-barrage','Réservoir-bassin') 
			group by r.geom, iddrain")

#calcul des surfaces en eau
dbGetQuery(con,"alter table bdtopo_hydrographie.rht_toposurface add column surface_rht numeric, add column surface_bdtopo numeric")
dbGetQuery(con,"update bdtopo_hydrographie.rht_toposurface set surface_bdtopo=st_area(geom)")
dbGetQuery(con,"update bdtopo_hydrographie.rht_toposurface ts set surface_rht=l*long_ from rht_att r where r.id_drain=ts.iddrain")


