/*----------------------------------------------------------------------
SCRIPT TO UPDATE SURFACE WATER IN FRANCE
source Hilaire Drouineau
------------------------------------------------------------------------*/


-- Restore the water basin table from RHT
-- create schema bdtot_hydrographie
-- the restoration is done in eda2.2.1 (eda2.2 database)

-- downloading bd_topo hydro theme (not easy at all)
/*
https://geoservices.ign.fr/documentation/diffusion/telechargement-donnees-libres.html
BD TOPO® Hydrographie par territoire édition septembre 2019


Notes la surface hydrographique recouvre les plans d'eau
*/

/*
 C:/"Program Files"/PostgreSQL/10/bin/psql -U postgres -f "rht_toposurface.sql" eda2.2
 C:/"Program Files"/PostgreSQL/10/bin/pg_restore -U postgres -d eda2.2 bvunitaire.sql 
*/



/*
 * convert bdtop surface to postgres
 * opening with gis Qgis => the file is UTF8
 * F:
 * cd F:\eda\shape\BDTOPO_3-0_HYDROGRAPHIE_SHP_LAMB93_FXX_2019-09-19\BDTOPO\1_DONNEES_LIVRAISON_2019-09-00371\BDT_3-0_SHP_LAMB93_FXX_ED2019-09-19\HYDROGRAPHIE
 * C:\"Program Files"\PostgreSQL\10\bin\shp2pgsql.exe -I -s 2154 SURFACE_HYDROGRAPHIQUE.shp bdtopo_hydrographie.surface_hydrographique|Out-File -FilePath F:\eda\shape\BDTOPO_3-0_HYDROGRAPHIE_SHP_LAMB93_FXX_2019-09-19\BDTOPO\1_DONNEES_LIVRAISON_2019-09-00371\BDT_3-0_SHP_LAMB93_FXX_ED2019-09-19\HYDROGRAPHIE\surface_hydrographique.sql 
 * Shapefile type: PolygonZ
 * Postgis type: MULTIPOLYGON[4]
 * 
 * C:\"Program Files"\PostgreSQL\10\bin\psql -U postgres -f surface_hydrographique.sql eda2.2
 */



/*
 * TEST ENCODAGE : WHEN IMPORTING WITH PSQL the encoding gets wrong because client encoding = LATIN1
 * TRIAL WITH QGIS, FIRST WE MUST SET THE PROJECTION OTHERWISE GET AN ERROR so the default imported from the shapefile does not work
 * FINALLY to use shp2ppgsql and sql we must find a way to set the encoding first (using psql ? ... I didn't test this)
 * Qgis will work, also reproject, but the identifiers are wrong when using the reprojection tool, so we have to do it in two phases,
 * and create two table in postgis
 *    C:\"Program Files"\PostgreSQL\10\bin\shp2pgsql.exe -I -s 2154 -p SURFACE_HYDROGRAPHIQUE.shp bdtopo_hydrographie.surface_hydrographique|Out-File -FilePath F:\eda\shape\BDTOPO_3-0_HYDROGRAPHIE_SHP_LAMB93_FXX_2019-09-19\BDTOPO\1_DONNEES_LIVRAISON_2019-09-00371\BDT_3-0_SHP_LAMB93_FXX_ED2019-09-19\HYDROGRAPHIE\surface_hydrographique_test.sql 
 */

-- Dans EDA2.3 je restaure les tables et je les mets dans le schema france
/*
 *  C:\"Program Files"\PostgreSQL\10\bin\psql -U postgres -f surface_hydrographique.sql eda2.3   
 *  C:/"Program Files"/PostgreSQL/10/bin/pg_restore -U postgres -d eda2.3 bvunitaire.sql      
 *  C:/"Program Files"/PostgreSQL/10/bin/psql -U postgres -f "rht_toposurface.sql" eda2.3                           
 * 
 */
ALTER TABLE bdtopo_hydrographie.surface_hydrographique_bdtopo SET SCHEMA france;
ALTER TABLE rht.bvunitaire SET SCHEMA france;


SELECT * FROM france.surface_hydrographique_bdtopo ;


SELECT distinct(nature) FROM france.surface_hydrographique_bdtopo;

/*
Ecoulement canalisé
Canal
Réservoir-bassin d'orage
Conduit buse
Ecoulement naturel
Plan d'eau de gravière
Glacier, névé
Retenue-digue
Lac
Retenue
Lagune
Retenue-barrage
Mare
Retenue-bassin portuaire
Réservoir-bassin piscicole
Plan d'eau de mine
Inconnue
Réservoir-bassin
Marais
Estuaire
*/

SELECT DISTINCT ON (origine) origine FROM france.surface_hydrographique_bdtopo;
SELECT nature, count(*) FROM france.surface_hydrographique_bdtopo GROUP BY nature;
COMMENT ON TABLE france.surface_hydrographique_bdtopo IS 'source : IGN, bdtopo_hydrographie 3.0 september 2019';


SELECT * FROM france.surface_hydrographique_bdtopo LIMIT 10;
-- CREATE AN INDEX
CREATE INDEX  surface_hydrographique_bdtopo_geom_gist ON france.surface_hydrographique_bdtopo 
 USING gist (the_geom);--17.6s
-- to project the geometry column we need the type
    
SELECT type 
FROM geometry_columns 
WHERE f_table_schema = 'france' 
AND f_table_name = 'surface_hydrographique_bdtopo' 
and f_geometry_column = 'geom';   -- POLYGON

-- reprojecting is very slow, better to use QGis for this (and a new table)

ALTER TABLE france.surface_hydrographique_bdtopo
  ALTER COLUMN geom
    TYPE geometry(Polygon, 3035)
    USING ST_Transform(geom, 3035);
   
ALTER TABLE france.bvunitaire3035
  ALTER COLUMN geom
    TYPE geometry(MULTIPOLYGON, 3035)
    USING ST_Transform(geom, 3035);   
   

 
 
 

DROP TABLE if exists france.surface_hydrographique_bdtopo_unitrht;
CREATE TABLE france.surface_hydrographique_bdtopo_unitrht as
			select  
			  surface_hydrographique_bdtopo."ID" as id, 
			  surface_hydrographique_bdtopo."CODE_HYDRO" as code_hydro, 
			  surface_hydrographique_bdtopo."CODE_PAYS" as code_pays, 
			  surface_hydrographique_bdtopo."NATURE" as nature, 
			  surface_hydrographique_bdtopo."PERSISTANC" as persistance, 
			  surface_hydrographique_bdtopo."SALINITE" as salinite, 
			  surface_hydrographique_bdtopo."COMMENT" as commentaire, 
			  surface_hydrographique_bdtopo."ID_P_EAU" as id_p_eau, 
			  surface_hydrographique_bdtopo."ID_C_EAU" as id_c_eau, 
			  surface_hydrographique_bdtopo."ID_ENT_TR" as id_ent_tr, 
			  surface_hydrographique_bdtopo."NOM_P_EAU" as nom_p_eau, 
			  surface_hydrographique_bdtopo."NOM_C_EAU" as nom_c_eau, 
			  surface_hydrographique_bdtopo."NOM_ENT_TR" as nom_ent_tr,
			'FR'||gridid as idsegment,  
			st_intersection(r.geom,	the_geom) geom
			 from france.bvunitaire3035 r 
			inner join france.surface_hydrographique_bdtopo  
			on st_intersects(the_geom,r.geom) 
			where "PERSISTANC"='Permanent' 
			AND "NATURE" in ('Lagune','Estuaire','Ecoulement naturel','Canal','Retenue-barrage','Réservoir-bassin','Marais','Lac','Retenue');--723627 rows affected, 26:29 minutes execution time

CREATE INDEX  surface_hydrographique_bdtopo_unitrht_geom_gist ON france.surface_hydrographique_bdtopo_unitrht 
 USING gist (geom);
 COMMENT ON TABLE france.surface_hydrographique_bdtopo_unitrht is 'Table issued from bd_topo hydro cut by unit rht basins, the 
 type of water surface considered is permanent surfaces with natures in lagune, estuaire, ecoulement naturel, canal, retenue-barrage,
 reservoir-bassin, marais, lac, retenue';


-- the result of the calculation is stored in the unit basin table
ALTER TABLE france.bvunitaire3035 add column perc_rn_notcovered numeric;
ALTER TABLE france.bvunitaire3035 add column idsegment text;
UPDATE france.bvunitaire3035 set idsegment='FR'||gridid;
select * from france.bvunitaire3035 limit 10;
CREATE INDEX ON france.bvunitaire3035 USING btree (idsegment);

-- calculate the proportion of riverssegments free of water surface bodies.

With 
clippedsegment as(
	select clipped.idsegment, clipped.geom
	from (
		 select r.idsegment, 
		     (ST_Dump(ST_Intersection(m.geom, r.geom))).geom
		 from france.surface_hydrographique_bdtopo_unitrht m
		 inner join france.rn r on 
		 ST_Intersects(m.geom, r.geom)         
	     ) as clipped
	where ST_Dimension(clipped.geom) = 1), -- remvoe points
-- in some cases there are several polygons per basin... need to group them first
lengthclipped AS (
SELECT sum(st_length(c.geom)) as totalclippedlength, idsegment FROM
		clippedsegment c
		group by idsegment),	
percnotcovered AS(
	select 1-totalclippedlength/st_length(r.geom) as perc, 
	r.idsegment 
	from lengthclipped c 
	JOIN france.rn r ON c.idsegment = r.idsegment 
)
UPDATE france.bvunitaire3035 set perc_rn_notcovered=perc 
	FROM percnotcovered
	WHERE bvunitaire3035.idsegment=percnotcovered.idsegment; --56861 rows affected, ? execution time.


/*------------------------------------
* updating rna table with both surface from waterbodies and surface from segments corrected
-------------------------------------*/


begin;
with ggg as(
select idsegment, sum(st_area(geom)) as wettedarea from france.surface_hydrographique_bdtopo_unitrht group by idsegment)
update france.rna set wettedsurfaceotherm2 = wettedarea from ggg where ggg.idsegment=rna.idsegment;
COMMIT; --89789 rows affected, 23.8 secs execution time.
 

BEGIN;
with recalculated as (
SELECT 
rna.idsegment,
st_length(rn.geom) as lengthriverm,
round((riverwidthm * st_length(rn.geom) * coalesce(perc_rn_notcovered,1))::numeric,2) as wettedsurfacem2,
perc_rn_notcovered
FROM france.rna 
JOIN france.rn on rn.idsegment=rna.idsegment
left JOIN
france.bvunitaire3035 p on rna.idsegment=p.idsegment)
UPDATE france.rna set (wettedsurfacem2, lengthriverm)= (recalculated.wettedsurfacem2,recalculated.lengthriverm)
FROM recalculated
where recalculated.idsegment=rna.idsegment;
COMMIT; -- 114564  rows affected, 7 secs execution time.

/*
Updating river width from values sent by Hervé Pella and Maxime Morel
*/

SELECT count(*) from france."RHT_RF_Pred_Haut_Larg"; ---114562
SELECT count(*) from france."RHT_RF_Pred_Haut_Larg" where "L50_corr"!='NA'; ---110883
SELECT count(*) FROM france.rn ---114564
SELECT * FROM france.rn where idsegment not in (select 'FR'||"ID_DRAIN" FROM france."RHT_RF_Pred_Haut_Larg");
-- FR314887 and FR314610	
-- I have some values in the segments where they are not recaculated by Maxime, I keep those
SELECT idsegment,riverwidthm FROM france.rna 
EXCEPT
SELECT idsegment,riverwidthm FROM france.rna 
 JOIN france."RHT_RF_Pred_Haut_Larg" 
 on 'FR'||"ID_DRAIN" =idsegment
 where "L50_corr"!='NA';
-- FR314887 et FR314610	
BEGIN;		
UPDATE france.rna set riverwidthm = "L50_corr"::numeric FROM france."RHT_RF_Pred_Haut_Larg" 
where "L50_corr"!='NA' AND 'FR'||"ID_DRAIN" =idsegment;--110883
COMMIT;
comment ON COLUMN france.rna.riverwidthm is 'Median of the width calculated on RHT stream 2019, Morel et al., 2019, 
Intercontinental Predictions of River Hydraulic Geometry from Catchment Physical Characteristics, Journal of Hydrology, https://doi.org/10.1016/j.jhydrol.2019.124292';


alter table france.bvunitaire3035 rename to unit_basin;



/*
ESPAÑA
*/



create index idx_rna_pfafsegment on spain.rna
  USING btree  (pfafsegment) ;
-- this speeds up the following query considerably  
select * from spain.cuencas join spain.rn_rna on pfafsegment=pfafcuen where idsegment='SP129600';
-- TODO PENTE 

ALTER TABLE spain.cuencas ADD column idsegment text;
BEGIN;
UPDATE spain.cuencas set idsegment=rn_rna.idsegment from 
spain.rn_rna WHERE pfafsegment=pfafcuen;
COMMIT;--Query returned successfully: 325606 rows affected, 04:16 minutes execution time.
create index idx_cuencas_idsegment on spain.cuencas
  USING btree  (idsegment) ;


create table spain.cuencas as 
(
select * from spain.basin_uni1
UNION
select * from spain.basin_uni2
UNION
select * from spain.basin_uni3
UNION
select * from spain.basin_uni4
); -- 327903 rows affected, 02:14 minutes execution time.
DROP TABLE spain.basin_uni1;
DROP TABLE spain.basin_uni2;
DROP TABLE spain.basin_uni3;
DROP TABLE spain.basin_uni4;

create index idx_cuencas_pfafcuen on spain.cuencas
  USING btree  (pfafcuen) ;
  
create index cuencas_geom_idx on spain.cuencas
  USING gist  (geom) ;

 VACUUM ANALYSE spain.cuencas;


   
DROP TABLE if exists spain.masas_agua_unitbv;
CREATE TABLE spain.masas_agua_unitbv as
			SELECT 
			  idsegment,
			  s.id, 
			  s.cod_masa, 
			  s.nom_masa, 
			  s.categoria, 
			  s.naturalida, 
			  s.tipona_cod, 
			  s.dh_cod, 
			  s.dh_nom, 
			  s.tipona_nom, 
			  s.tipocalib, 
			  s.num_tipoca, 
			  s.internac, 
			  s.embalse,			   
			st_intersection(c.geom,	s.geom) geom
			 from spain.cuencas c 
			INNER join spain.rna on pfafsegment=pfafcuen
			inner join spain.masas_agua s on st_intersects(s.geom,c.geom);	--Query returned successfully: 18731 rows affected, 20:01 minutes execution time.


-- What is the portion of idsegment covered by aquas masas

ALTER TABLE spain.masas_agua_unitbv DROP column perc_rn_notcovered numeric;
COMMENT ON COLUMN spain.masas_agua_unitbv.perc_rn_notcovered IS 'percentage of length of line not covered by masas in the basin';

create index masas_agua_unitbv_geom_idx on spain.masas_agua_unitbv
  USING gist  (geom) ;

-- first test with a small table
drop table if exists spain.temp_test;
CREATE TABLE spain.temp_test as (
With petitmas as (
select * FROM spain.masas_agua_unitbv where idsegment='SP311133'),
petitrn as (
select * FROM spain.rn_rna where idsegment='SP311133'),
clippedbv as(
select idsegment, geom
from (
         select petitrn.idsegment, 
             (ST_Dump(ST_Intersection(petitmas.geom, petitrn.geom))).geom
         from petitmas
              inner join petitrn on ST_Intersects(petitmas.geom, petitrn.geom)
     ) as clipped
where ST_Dimension(clipped.geom) = 1)
SELECT * FROM clippedbv);

select idsegment,round(st_length(geom)) from spain.temp_test;
/*
idsegment;round
SP311133;66
SP311133;102
SP311133;13
SP311133;31
SP311133;22
SP311133;21
SP311133;10
SP311133;2
SP311133;35
SP311133;15
SP311133;10
SP311133;8
SP311133;1551
*/

with longueur as (
select idsegment, sum(st_length(geom)) length_inter from spain.temp_test group by idsegment)
SELECT rn.idsegment,sum(length_inter)/sum(st_length(geom)) FROM longueur 
join spain.rn on rn.idsegment=longueur.idsegment GROUP BY rn.idsegment; --0.53 OK (1-0.46)

/*
Correct missing river width
some riversegements are noted as source MERIT but were null
I have replaced those in script river_width.Rmd, line > 619
Also correcting wrong predictions
*/


SELECT count(*) FROM spain.rna where riverwidthm IS NULL; --89
SELECT * FROM riverwidth_spain_portugalbis limit 10 --7997

/*
This collects the data from data generated with the R markdown river width script
*/

BEGIN;
update spain.rna r set (riverwidthm, riverwidthmsource)=(s.pred_river_width::numeric, s.riverwidthmsource)
FROM riverwidth_spain_portugal s where  
s.idsegment=r.idsegment; --Query returned successfully: 308975 rows affected, 24.5 secs execution time.
COMMIT;


BEGIN;
update spain.rna r set (riverwidthm, riverwidthmsource)=(s.pred_river_width::numeric, s.riverwidthmsource)
FROM riverwidth_spain_portugalbis s where  
s.idsegment=r.idsegment
; --7997
COMMIT;



SELECT count(*), isendoreic FROM spain.rn_rna where riverwidthm IS NULL group by isendoreic; --97 (94t 3f)
--  3 remaining....

-- manual
UPDATE spain.rna r set riverwidthm=1.82 where  idsegment='SP234487';
UPDATE spain.rna r set riverwidthm=2.01 where  idsegment='SP234058';
UPDATE spain.rna r set riverwidthm=1.3 where  idsegment='SP30469';

BEGIN;
UPDATE spain.rna set riverwidthm=0 where idsegment in (
select idsegment from spain.rn_rna where riverwidthm IS NULL and isendoreic); --94
COMMIT;

SELECT count(*)FROM spain.rn_rna where riverwidthm IS NULL ; --0

/*
Computes the percentage of segment free of water mass (polygon) overlap
*/

With 
clippedsegment as(
	select clipped.idsegment, clipped.geom
	from (
		 select r.idsegment, 
		     (ST_Dump(ST_Intersection(m.geom, r.geom))).geom
		 from spain.masas_agua_unitbv m
		 inner join spain.rn r on 
		 ST_Intersects(m.geom, r.geom)         
	     ) as clipped
	where ST_Dimension(clipped.geom) = 1), -- remvoe points
-- in some cases there are several polygons per basin... need to group them first
lengthclipped AS (
SELECT sum(st_length(c.geom)) as totalclippedlength, idsegment FROM
		clippedsegment c
		group by idsegment),	
percnotcovered AS(
	select 1-totalclippedlength/st_length(r.geom) as perc, 
	r.idsegment 
	from lengthclipped c 
	JOIN spain.rn r ON c.idsegment = r.idsegment 
)
UPDATE spain.masas_agua_unitbv set perc_rn_notcovered=perc 
	FROM percnotcovered
	WHERE masas_agua_unitbv.idsegment=percnotcovered.idsegment;--Query returned successfully: 18338 rows affected, 01:34 minutes execution time.


BEGIN;
with percnotcovered as (
-- there might be several water mass within one basin
select distinct on (idsegment) idsegment, perc_rn_notcovered from spain.masas_agua_unitbv
),
recalculated as (
SELECT 
rna.idsegment,
lengthriverm,
riverwidthm,
round((lengthriverm * riverwidthm) * coalesce(perc_rn_notcovered,1),2) as wettedsurfacem2,
perc_rn_notcovered
FROM spain.rna 
left JOIN
percnotcovered p on rna.idsegment=p.idsegment)
UPDATE spain.rna set wettedsurfacem2 = recalculated.wettedsurfacem2 
FROM recalculated
where recalculated.idsegment=rna.idsegment;
COMMIT; -- Query returned successfully: 325607 rows affected, 22.3 secs execution time.



begin;
with ggg as(
select idsegment, sum(st_area(geom)) as wettedarea from spain.masas_agua_unitbv group by idsegment)
update spain.rna set wettedsurfaceotherm2 = wettedarea from ggg where ggg.idsegment=rna.idsegment;
COMMIT; -- 18299 rows affected, 23.8 secs execution time.

ALTER table spain.cuencas RENAME to unit_basin 

/*
* Portugal
*/
/*
HY_PhysicalWaters_DrainageBasinGeoCod.gml => fail when copied to postgis (missing lines due to varchar10 restriction pb)
=> had to save in shp and then to postgis, encoding UTF8
*/


ALTER TABLE portugal.wise_vw_surfacewaterbody_transitional_ptcont add column categoria text;
UPDATE portugal.wise_vw_surfacewaterbody_transitional_ptcont set categoria='TW';--49
ALTER TABLE portugal.wise_vw_surfacewaterbody_river_area_ptcont add column categoria text;
UPDATE portugal.wise_vw_surfacewaterbody_river_area_ptcont set categoria='RW';--119

DROP TABLE if exists portugal.wisewaterbody;
create table portugal.wisewaterbody as (
SELECT * FROM portugal.wise_vw_surfacewaterbody_transitional_ptcont
UNION
SELECT * FROM portugal.wise_vw_surfacewaterbody_river_area_ptcont);--168

select * from portugal.wisewaterbody
COMMENT ON TABLE portugal.wisewaterbody is 'Source wise_vw_surfacewaterbody_transitional_ptcont and wise_vw_surfacewaterbody_river_area_ptcont, added comun categoria with TW AND RW for transitional and river water'

SELECT st_srid(geom) from portugal.wisewaterbody limit 10; --4326
SELECT type 
FROM geometry_columns 
WHERE f_table_schema = 'portugal' 
AND f_table_name = 'wisewaterbody' 
and f_geometry_column = 'geom';   --MULTIPOLYGON

ALTER TABLE portugal.wisewaterbody
  ALTER COLUMN geom
    TYPE geometry(MULTIPOLYGON, 3035)
    USING ST_Transform(geom, 3035);   

ALTER TABLE portugal.wise_vw_riverbasindistrict_ptcont
  ALTER COLUMN geom
    TYPE geometry(MULTIPOLYGON, 3035)
    USING ST_Transform(geom, 3035); 


 ALTER TABLE  portugal.unit_basins
  ALTER COLUMN geom
    TYPE geometry(MULTIPOLYGON, 3035)
    USING ST_Transform(geom, 3035);     --50s
 
   
SELECT count(*) FROM portugal.rna where riverwidthm IS NULL; --2
SELECT * FROM riverwidth_spain_portugalbis limit 10 --7997


ALTER TABLE portugal.unit_basins add column idsegment text;
--- jsub joining segments and unit basins. I don't have any link between the two tables so I have to run a spatial query
-- and select the basin with the largest join...
/*
SELECT * FROm portugal.rn join portugal.unit_basins b on st_intersects(rn.geom, b.geom) where idsegment = 'PT80645';
SELECT rn.idsegment, "order" FROm portugal.rn join 
portugal.rivers r on 'PT'||r.gid = rn.idsegment
JOIN portugal.unit_basins on "order" =id_localid; --321204 wrong
*/ 
BEGIN;
with jsub as (
SELECT rn.idsegment, id, st_length(st_intersection(rn.geom,b.geom)) len
 FROm portugal.rn join portugal.unit_basins b on st_intersects(rn.geom, b.geom)),
 -- getting the longest segment for the join
 jsub1 as (
SELECT distinct on (idsegment) * FROM jsub order by idsegment, len desc)
UPDATE portugal.unit_basins set idsegment=jsub1.idsegment FROM jsub1 where jsub1.id=unit_basins.id;
COMMIT;---Query returned successfully: 75336 rows affected, 10 minutes execution time.




/*
This collects the data from data generated with the R markdown river width script
there is a part for spain and the last one is for portugal...
The table riverwidth_spain_portugal is a union of spain and portugal so all is OK 
*/

BEGIN;
update portugal.rna r set (riverwidthm, riverwidthmsource)=(s.pred_river_width::numeric, s.riverwidthmsource)
FROM riverwidth_spain_portugal s where  
s.idsegment=r.idsegment; --Query returned successfully: 68738 rows affected, 4.4 secs execution time.
COMMIT;


BEGIN;
update portugal.rna r set (riverwidthm, riverwidthmsource)=(s.pred_river_width::numeric, s.riverwidthmsource)
FROM riverwidth_portugalbis s where  
s.idsegment=r.idsegment
; --2363
COMMIT;


SELECT * from portugal.rna where riverwidthm is null; --184 -- all surfacebvm2 null

SELECT * from portugal.rn_rna where riverwidthm is null and seaidsegment is null;
BEGIN;
UPDATE portugal.rn set isendoreic = TRUE  WHERE idsegment in (
select idsegment from portugal.rn_rna where riverwidthm is null and seaidsegment is null); --182
UPDATE portugal.rna set (riverwidthm,riverwidthmsource) = (0,'Not computed, the stream is endoreic') WHERE idsegment in (
select idsegment from portugal.rn_rna where riverwidthm is null and seaidsegment is null); --182
COMMIT;


/*
CREATE SPLITTED POLYGONS PER UNIT BASINS PORTUGAL
*/
  
create index unit_basins_geom_idx on portugal.unit_basins
  USING gist  (geom) ;

-- SELECT * FROM portugal.unit_basins limit 10;
-- SELECT * from portugal.wisewaterbody limit 10;
   
DROP TABLE if exists portugal.wisewaterbody_unitbv;
CREATE TABLE portugal.wisewaterbody_unitbv as
			SELECT 
			  idsegment,	
			  s.id, 
			  s.codigo, 
			  s.nome, 
			  s.regiao_hid, 
			  s.natur_fm_a, 
			  s.transfront, 
			  s.est_pot_ec, 
			  s.estado_qui, 
			  s.categoria,   
			st_intersection(c.geom,	s.geom) geom
			 from portugal.unit_basins c 
			inner join portugal.wisewaterbody s on st_intersects(s.geom,c.geom);	--Query returned successfully: 7036 rows affected, 09:50 minutes execution time.

ALTER TABLE portugal.unit_basins ADD column perc_rn_notcovered numeric; 
COMMENT ON COLUMN portugal.unit_basins.perc_rn_notcovered IS 'percentage of length of line not covered by waterbody in the basin';

create index wisewaterbody_unitbv_geom_idx on portugal.wisewaterbody_unitbv 
  USING gist  (geom) ;--171msec
/*
Computes the percentage of segment free of water mass (polygon) overlap  portugal.wisewaterbody / portugal.unit_basins
*/

With 
clippedsegment as(
	select clipped.idsegment, clipped.geom
	from (
		 select r.idsegment, 
		     (ST_Dump(ST_Intersection(m.geom, r.geom))).geom
		 from portugal.wisewaterbody_unitbv m
		 inner join portugal.rn r on 
		 ST_Intersects(m.geom, r.geom)         
	     ) as clipped
	where ST_Dimension(clipped.geom) = 1), -- remvoe points
-- in some cases there are several polygons per basin... need to group them first
lengthclipped AS (
SELECT sum(st_length(c.geom)) as totalclippedlength, idsegment FROM
		clippedsegment c
		group by idsegment),	
percnotcovered AS(
	select 1-totalclippedlength/st_length(r.geom) as perc, 
	r.idsegment 
	from lengthclipped c 
	JOIN portugal.rn r ON c.idsegment = r.idsegment 
)
UPDATE portugal.unit_basins set perc_rn_notcovered=perc 
	FROM percnotcovered
	WHERE unit_basins.idsegment=percnotcovered.idsegment;--Query returned successfully: 6254 rows affected, 25.7 secs execution time.

BEGIN;
UPDATE portugal.rna set lengthriverm=st_length(geom) from portugal.rn_rna where rn_rna.idsegment=rna.idsegment;
COMMIT; --Query returned successfully: 75830 rows affected, 4.2 secs execution time.

BEGIN;
with percnotcovered as (
-- there might be several water mass within one basin
select distinct on (idsegment) idsegment, perc_rn_notcovered from portugal.unit_basins
),
recalculated as (
SELECT 
rna.idsegment,
lengthriverm,
riverwidthm,
round((lengthriverm * riverwidthm) * coalesce(perc_rn_notcovered,1),2) as wettedsurfacem2,
perc_rn_notcovered
FROM portugal.rna 
left JOIN
percnotcovered p on rna.idsegment=p.idsegment)
UPDATE portugal.rna set wettedsurfacem2 = recalculated.wettedsurfacem2 
FROM recalculated
where recalculated.idsegment=rna.idsegment;
COMMIT; -- Query returned successfully: 75830 rows affected, 5.2 secs execution time.



begin;
with ggg as(
select idsegment, sum(st_area(geom)) as wettedarea from portugal.wisewaterbody_unitbv group by idsegment)
update portugal.rna set wettedsurfaceotherm2 = wettedarea from ggg where ggg.idsegment=rna.idsegment;
COMMIT; -- 6260 rows affected, 23.8 secs execution time.


ALTER table portugal.unit_basins RENAME to unit_basin ;

/*
 * VIEW FOR MAPS
 * 
 */

CREATE VIEW france.surface_hydrographique_bdtopo_unitrht_density  AS 
SELECT t.*, density FROM france.surface_hydrographique_bdtopo_unitrht t JOIN
france.rn_rna ON t.idsegment= rn_rna.idsegment;


CREATE VIEW spain.masas_agua_unitbv_density  AS 
SELECT t.*, density FROM spain.masas_agua_unitbv t JOIN
spain.rn_rna ON t.idsegment= rn_rna.idsegment;

/*
SELECT * FROM dbeel_rivers.basinunit_bu bb LIMIT 10
SELECT * FROM france.waterbody_unitbv ; -- nature, persitance, salinite

SELECT * FROM portugal.waterbody_unitbv; --categoria, estado_qui, est_pot_ec, natur_fm_a
france.waterbody_unitbv

SELECT * FROM spain.waterbody_unitbv; 
SELECT * FROM france.waterbody_unitbv w JOIN france.rne ON rne.idsegment=w.idsegment
*/

CREATE INDEX ON france.waterbody_unitbv USING btree(idsegment);
CREATE INDEX ON spain.waterbody_unitbv USING btree(idsegment);
CREATE INDEX ON portugal.waterbody_unitbv USING btree(idsegment);

SELECT * FROM france.waterbody_unitbv w JOIN france.rne 
ON rne.idsegment=w.idsegment 
GROUP BY id;


DROP TABLE IF EXISTS france.temp_waterbody_unitbv_rn_rna_rne;
CREATE TABLE france.temp_waterbody_unitbv_rn_rna_rne AS (
SELECT 
row_number() over() AS _uid_,
w.ubv_idwu,
w.ubv_idw,
w.ubv_idsegment as idsegment,
w.ubv_code,
w.ubv_name,
w.ubv_sudoang_category,
w.ubv_country,
w.geom,
w.nature,
w.persistance,
w.salinite,
w.commentaire,
w.id_p_eau,
w.id_c_eau,
w.id_ent_tr,
w.lag_id,
st_area(w.geom) AS surface,
wettedsurfaceotherm2 /st_area(w.geom) AS perc_surface_with_unitbv,
rn.seaidsegment,
codesea,
basin,
emu,
distanceseam,
cumnbdam,
wettedsurfacem2,
wettedsurfaceotherm2,
gerem_zone_4 AS sudoe_area,
ccm_wso_id,
name_coast,
name_basin,
delta,
density,
neel,
beel,
nsilver,
bsilver,
pmale,
neel_pmax_tr,
nsilver_pmax_tr,
neel_wd,
beel_wd,
drought
FROM france.waterbody_unitbv w 
JOIN france.rn ON rn.idsegment=w.ubv_idsegment  
JOIN france.rne ON rne.idsegment=w.ubv_idsegment 
JOIN france.rna ON rna.idsegment=w.ubv_idsegment
LEFT JOIN eda_gerem.assoc_dbeel_rivers aa ON rn.seaidsegment= aa.seaidsegment);--722036
CREATE INDEX ON france.temp_waterbody_unitbv_rn_rna_rne USING gist(geom);
CREATE INDEX ON france.temp_waterbody_unitbv_rn_rna_rne USING btree(idsegment);
CREATE INDEX ON france.temp_waterbody_unitbv_rn_rna_rne USING btree(seaidsegment);
ALTER TABLE france.temp_waterbody_unitbv_rn_rna_rne ADD PRIMARY KEY (_uid_);

/*
SELECT idsegment, sum(perc_surface_with_unitbv) 
FROM france.temp_waterbody_unitbv_rn_rna_rne 
GROUP BY idsegment; -- one for all hurray !
*/

/*
 * A query to get the sum per waterbody type upstream from the Loire 
 * this will be further developped in a function in R
 */

WITH upstream AS (SELECT france.upstream_segments_rn('FR213929')),
     joined AS (
SELECT 
idsegment
, id
,code_hydro
, nature
, persistance
, salinite
, surface
, perc_surface_with_unitbv
, wettedsurfacem2
, wettedsurfaceotherm2
, neel
, nsilver
, bsilver
, pmale
FROM upstream JOIN
france.temp_waterbody_unitbv_rn_rna_rne w ON w.idsegment=upstream.upstream_segments_rn)

SELECT 
id,
code_hydro,
nature,
persistance,
salinite,
sum(neel*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS neel,
sum(nsilver*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS nsilver,
sum(nsilver*wettedsurfaceotherm2*pmale*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS nmale--,
--sum(bsilver*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS bsilver
FROM joined
GROUP BY (id,
code_hydro,
nature,
persistance,
salinite
); 
/*
 * We fetch the other
 * 
 */

WITH upstream AS (SELECT france.upstream_segments_rn('FR213929')),
     joined AS (
SELECT * FROM upstream 
JOIN france.rne ON rne.idsegment = upstream.upstream_segments_rn 
JOIN france.rna ON rna.idsegment = rne.idsegment)
SELECT 
'cours_eau' AS nature,
'Permanent' AS persistance,
'Non' AS salinite,
sum(density*wettedsurfacem2) AS neel,
sum(psilver*density*wettedsurfacem2) AS nsilver,
sum(psilver*density*wettedsurfacem2*pmale) AS nmale
FROM joined


SELECT  * FROM france.temp_waterbody_unitbv_rn_rna_rne LIMIT 100

SELECT  * FROM france.temp_waterbody_unitbv_rn_rna_rne LIMIT 100
/* 
 * sum of eel per waterbodies
 * Attention number eel correspond to total number eel in all waterbodies
 */
 */
DROP TABLE IF EXISTS france.number_per_waterbodies;
CREATE TABLE france.number_per_waterbodies AS 
SELECT 
row_number() over() AS _uid_,
id,
nature,
persistance,
salinite,
sum(neel*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS neel,
sum(nsilver*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS nsilver,
sum(nsilver*wettedsurfaceotherm2*pmale*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS nmale,
sum(bsilver*wettedsurfaceotherm2*perc_surface_with_unitbv/(COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) AS bsilver,
st_union(geom) AS Geom
FROM france.temp_waterbody_unitbv_rn_rna_rne
GROUP BY (id, 
nature,
persistance,
salinite
); --650817

SELECT sum(neel) FROM france.rne; --225 millions
SELECT sum(neel) FROM france.number_per_waterbodies --208 millions OK
SELECT sum(wettedsurfaceotherm2)/sum((COALESCE(wettedsurfacem2,0)+COALESCE(wettedsurfaceotherm2,0))) 
FROM france.rna; --0.84
--208/225 0.92
CREATE INDEX ON france.number_per_waterbodies USING gist(geom);


SELECT * FROM france.number_per_waterbodies

 SELECT * FROM france.temp_waterbody_unitbv_rn_rna_rne

DROP TABLE IF EXISTS spain.temp_waterbody_unitbv_rn_rna_rne;
CREATE TABLE spain.temp_waterbody_unitbv_rn_rna_rne AS (
SELECT 
row_number() over() AS _uid_,
w.*,
st_area(w.geom) AS surface,
rn.seaidsegment,
codesea,
basin,
emu,
distanceseam,
cumnbdam,
wettedsurfacem2,
wettedsurfaceotherm2,
gerem_zone_4 AS sudoe_area,
ccm_wso_id,
name_coast,
basin_name,
delta,
density,
neel,
beel,
nsilver,
bsilver,
neel_pmax_tr,
nsilver_pmax_tr,
neel_wd,
beel_wd,
drought
FROM spain.waterbody_unitbv w 
JOIN spain.rn ON rn.idsegment=w.idsegment 
JOIN spain.rne ON rne.idsegment=w.idsegment 
JOIN spain.rna ON rna.idsegment=w.idsegment
LEFT JOIN eda_gerem.assoc_dbeel_rivers aa ON rn.seaidsegment= aa.seaidsegment);--18709
CREATE INDEX ON spain.temp_waterbody_unitbv_rn_rna_rne USING gist(geom);
CREATE INDEX ON spain.temp_waterbody_unitbv_rn_rna_rne USING btree(idsegment);
CREATE INDEX ON spain.temp_waterbody_unitbv_rn_rna_rne USING btree(seaidsegment);
ALTER TABLE spain.temp_waterbody_unitbv_rn_rna_rne ADD PRIMARY KEY (_uid_);



DROP TABLE IF EXISTS portugal.temp_waterbody_unitbv_rn_rna_rne;
CREATE TABLE portugal.temp_waterbody_unitbv_rn_rna_rne AS (
SELECT 
row_number() over() AS _uid_,
w.*,
st_area(w.geom) AS surface,
rn.seaidsegment,
codesea,
basin,
emu,
distanceseam,
cumnbdam,
wettedsurfacem2,
wettedsurfaceotherm2,
gerem_zone_4 AS sudoe_area,
ccm_wso_id,
name_coast,
basin_name,
delta,
density,
neel,
beel,
nsilver,
bsilver,
neel_pmax_tr,
nsilver_pmax_tr,
neel_wd,
beel_wd,
drought
FROM portugal.waterbody_unitbv w 
JOIN portugal.rn ON rn.idsegment=w.idsegment 
JOIN portugal.rne ON rne.idsegment=w.idsegment 
JOIN portugal.rna ON rna.idsegment=w.idsegment
LEFT JOIN eda_gerem.assoc_dbeel_rivers aa ON rn.seaidsegment= aa.seaidsegment);--5993
CREATE INDEX ON portugal.temp_waterbody_unitbv_rn_rna_rne USING gist(geom);
CREATE INDEX ON portugal.temp_waterbody_unitbv_rn_rna_rne USING btree(idsegment);
CREATE INDEX ON portugal.temp_waterbody_unitbv_rn_rna_rne USING btree(seaidsegment);
ALTER TABLE portugal.temp_waterbody_unitbv_rn_rna_rne ADD PRIMARY KEY (_uid_);

/*
 * CHANGE WATERBODIES #177
 * */

ALTER TABLE portugal.waterbody_unitbv RENAME TO waterbody_unitbvold;
ALTER TABLE spain.waterbody_unitbv RENAME TO waterbody_unitbvold;
ALTER TABLE france.waterbody_unitbv RENAME TO waterbody_unitbvold;
ALTER TABLE france.waterbody_unitbvold ADD COLUMN id_ serial PRIMARY KEY;

DROP TABLE IF EXISTS dbeel_rivers.waterbody_unitbv CASCADE;
CREATE TABLE dbeel_rivers.waterbody_unitbv(
ubv_idwu TEXT PRIMARY KEY,
ubv_idw TEXT,
ubv_idsegment TEXT,
ubv_code TEXT,
ubv_name TEXT,
ubv_sudoang_category TEXT,
ubv_country TEXT);

SELECT addgeometrycolumn('dbeel_rivers','waterbody_unitbv','geom', 3035,'MULTIPOLYGON',3); 
CREATE INDEX indexubvgeom
  ON dbeel_rivers.waterbody_unitbv
  USING gist
  (geom);
 
 -- FRANCE
DROP TABLE IF EXISTS france.waterbody_unitbv;
CREATE TABLE france.waterbody_unitbv (
			nature varchar(27),
			persistance varchar(12),
			salinite varchar(3),
			commentaire varchar(80),
			id_p_eau varchar(80),
			id_c_eau varchar(80),
			id_ent_tr varchar(24),
			lag_id INTEGER,
			CONSTRAINT c_pk_ubv_ubv_idwu primary key (ubv_idwu),
			CONSTRAINT c_fk_ubv_idsegment FOREIGN KEY (ubv_idsegment) references france.rn(idsegment))
			INHERITS (dbeel_rivers.waterbody_unitbv); 
--SELECT DISTINCT nature FROM france.waterbody_unitbvold;
-- SELECT distinct st_geometrytype(geom) FROM france.waterbody_unitbvold;
-- SELECT distinct st_geometrytype(geom) FROM spain.waterbody_unitbvold;
-- SELECT distinct st_geometrytype(geom) FROM portugal.waterbody_unitbvold;
-- SELECT ST_Dimension(geom) FROM france.waterbody_unitbvold;
--SELECT DISTINCT sudoang_category FROM spain.waterbody_unitbvold;

		/*
		 * Some idsegment do not exist in rn table, for some reasons they correspond to basins which have changed names,
		 * those have been remove from the unitbv layer.... I'm checking back the idsegment by a spatial query
		 */
WITH missing_idsegment AS (
SELECT idsegment FROM france.waterbody_unitbvold 
EXCEPT 
SELECT rn.idsegment FROM france.waterbody_unitbvold wu
JOIN france.rn ON rn.idsegment = wu.idsegment),
    the_join AS (
SELECT DISTINCT ON (id_) id_, rn.idsegment FROM france.waterbody_unitbvold wu
JOIN missing_idsegment m ON  m.idsegment=wu.idsegment 
JOIN france.rn ON st_intersects(rn.geom, wu.geom)
ORDER BY id_, rn.geom <-> wu.geom)
UPDATE france.waterbody_unitbvold SET idsegment=the_join.idsegment FROM the_join
WHERE the_join.id_ = waterbody_unitbvold.id_; --102 these touch the idsegment

WITH missing_idsegment AS (
SELECT idsegment FROM france.waterbody_unitbvold 
EXCEPT 
SELECT rn.idsegment FROM france.waterbody_unitbvold wu
JOIN france.rn ON rn.idsegment = wu.idsegment)    
UPDATE france.waterbody_unitbvold SET idsegment=NULL FROM missing_idsegment
WHERE missing_idsegment.idsegment = waterbody_unitbvold.idsegment; --209 segments 1522 waterbodies .... 
-- TODO check for those later


INSERT INTO france.waterbody_unitbv(
			ubv_idwu
			,ubv_idw
			,ubv_idsegment
			,ubv_code
			,ubv_name
			,ubv_sudoang_category
			,ubv_country
			,geom
			,nature
			,persistance
			,salinite
			,commentaire
			,id_p_eau
			,id_c_eau
			,id_ent_tr
			,lag_id)
			SELECT 
			  'FR'||id_ AS ubv_idwu
			, id AS ubv_idw
			, idsegment AS ubv_idsegment
			, code_hydro AS ubv_code
			, coalesce(coalesce(nom_p_eau,nom_c_eau),nom_ent_tr) AS ubv_name
			, 	CASE WHEN nature ='Retenue-barrage' THEN 'reservoir'
				WHEN nature ='Retenue' THEN 'reservoir'
				WHEN nature ='Marais' THEN 'marsh'
				WHEN nature ='Canal' THEN 'canal'
				WHEN nature ='Réservoir-bassin' THEN 'reservoir'
				WHEN nature ='Ecoulement naturel' THEN 'river'
				WHEN nature ='Estuaire' THEN 'estuary'
				WHEN nature ='Lac' THEN 'lake'
				WHEN nature ='Lagune' THEN 'lagoon'
				END AS ubv_sudoang_category
			, code_pays AS ubv_country
			, ST_Multi(geom) AS geom
			, nature
			, persistance
			, salinite
			, commentaire
			, id_p_eau
			, id_c_eau
			, id_ent_tr
			, w_lag_id AS lag_id
			FROM france.waterbody_unitbvold; -- Updated Rows	723697
		
CREATE INDEX indexubvgeom
  ON france.waterbody_unitbv
  USING gist
  (geom);	
 
 -- SPAIN
 
DROP TABLE IF EXISTS spain.waterbody_unitbv;
CREATE TABLE spain.waterbody_unitbv (
			categoria varchar(2),
			perc_rn_notcovered NUMERIC,
			naturalida varchar(20),
			tipona_cod varchar(140),
			dh_cod varchar(5),
			dh_nom varchar(40),
			tipona_nom varchar(140),
			tipocalib varchar(200),
			num_tipoca integer,
			internac varchar(20),
			embalse varchar(100),
			CONSTRAINT c_pk_ubv_ubv_idwu primary key (ubv_idwu),
			CONSTRAINT c_fk_ubv_idsegment FOREIGN KEY (ubv_idsegment) references spain.rn(idsegment))
			INHERITS (dbeel_rivers.waterbody_unitbv); 
		
WITH missing_idsegment AS (
SELECT idsegment FROM spain.waterbody_unitbvold 
EXCEPT 
SELECT rn.idsegment FROM spain.waterbody_unitbvold wu
JOIN spain.rn ON rn.idsegment = wu.idsegment),  
    the_join AS (
SELECT DISTINCT ON (id_) id_, rn.idsegment FROM spain.waterbody_unitbvold wu
JOIN missing_idsegment m ON  m.idsegment=wu.idsegment 
JOIN spain.rn ON st_dwithin(rn.geom, wu.geom,10000)
ORDER BY id_, rn.geom <-> wu.geom)
UPDATE spain.waterbody_unitbvold SET idsegment=the_join.idsegment FROM the_join
WHERE the_join.id_ = waterbody_unitbvold.id_; --22
		
		
 
INSERT INTO spain.waterbody_unitbv(
			ubv_idwu
			,ubv_idw
			,ubv_idsegment
			,ubv_code
			,ubv_name
			,ubv_sudoang_category
			,ubv_country
			,geom
			,categoria
			,perc_rn_notcovered
			,naturalida
			,tipona_cod
			,dh_cod
			,dh_nom
			,tipona_nom
			,tipocalib
			,num_tipoca
			,internac
			,embalse
			)
			SELECT 
			  'SP'||id_ AS ubv_idwu
			, id AS ubv_idw
			, idsegment AS ubv_idsegment
			, cod_masa AS ubv_code
			, nom_masa AS ubv_name
			, sudoang_category AS ubv_sudoang_category
			, 'SP' AS ubv_country
			, ST_force3D(ST_Multi(geom)) AS geom
			, categoria
			, perc_rn_notcovered
			, naturalida
			, tipona_cod
			, dh_cod
			, dh_nom
			, tipona_nom
			, tipocalib
			, num_tipoca
			, internac
			, embalse
			FROM spain.waterbody_unitbvold; -- Updated Rows	18732
		
CREATE INDEX indexubvgeom
  ON spain.waterbody_unitbv
  USING gist
  (geom);
 
-- Portugal

DROP TABLE IF EXISTS portugal.waterbody_unitbv;
CREATE TABLE portugal.waterbody_unitbv (
			categoria TEXT
			,regiao_hid TEXT
			,natur_fm_a TEXT
			,transfront TEXT
			,est_pot_ec TEXT
			,estado_qui TEXT
			,CONSTRAINT c_pk_ubv_ubv_idwu primary key (ubv_idwu)
			,CONSTRAINT c_fk_ubv_idsegment FOREIGN KEY (ubv_idsegment) references portugal.rn(idsegment))
			INHERITS (dbeel_rivers.waterbody_unitbv);  
		
WITH missing_idsegment AS (
SELECT idsegment FROM portugal.waterbody_unitbvold 
EXCEPT 
SELECT rn.idsegment FROM portugal.waterbody_unitbvold wu
JOIN portugal.rn ON rn.idsegment = wu.idsegment),  --346
    the_join AS (
SELECT DISTINCT ON (id_) id_, rn.idsegment FROM portugal.waterbody_unitbvold wu
JOIN missing_idsegment m ON  m.idsegment=wu.idsegment 
JOIN portugal.rn ON st_dwithin(rn.geom, wu.geom,10000)
ORDER BY id_, rn.geom <-> wu.geom)
UPDATE portugal.waterbody_unitbvold SET idsegment=the_join.idsegment FROM the_join
WHERE the_join.id_ = waterbody_unitbvold.id_; --358

INSERT INTO portugal.waterbody_unitbv(
			ubv_idwu
			,ubv_idw
			,ubv_idsegment
			,ubv_code
			,ubv_name
			,ubv_sudoang_category
			,ubv_country
			,geom
			,categoria
			,regiao_hid
			,natur_fm_a
			,transfront
			,est_pot_ec
			,estado_qui

			)
			SELECT 
			  'PT'||id_ AS ubv_idwu
			, id AS ubv_idw
			, idsegment AS ubv_idsegment
			, codigo AS ubv_code
			, nome AS ubv_name
			, sudoang_category AS ubv_sudoang_category
			, 'PT' AS ubv_country
			, ST_force3D(ST_Multi(geom)) AS geom
			,categoria
			,regiao_hid
			,natur_fm_a
			,transfront
			,est_pot_ec
			,estado_qui
			FROM portugal.waterbody_unitbvold; -- Updated Rows	6573
		
CREATE INDEX indexubvgeom
  ON portugal.waterbody_unitbv
  USING gist
  (geom);
  
 
