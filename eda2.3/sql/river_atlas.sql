/*
Integrating data from river Altas
*/


ALTER TABLE europe."RiverATLAS_v10_eu" rename to riveratlas_v10_eu;

SELECT type 
FROM geometry_columns 
WHERE f_table_schema = 'europe' 
AND f_table_name = 'riveratlas_v10_eu' 
and f_geometry_column = 'geom';   


 ALTER TABLE  europe.riveratlas_v10_eu
  ALTER COLUMN geom
    TYPE geometry(MULTILINESTRING, 3035)
    USING ST_Transform(geom, 3035);    --41.9 


create index riveratlas_v10_eu_geom_idx on  europe.riveratlas_v10_eu
  USING gist  (geom) ;


CREATE TABLE temp_atlas_vil as select * from europe.riveratlas_v10_eu where main_riv=20440799;
SELECT DropGeometryColumn('temp_atlas_vil','geombuffer');
SELECT AddGeometryColumn ('public','temp_atlas_vil','geombuffer',3035,'POLYGON',2);

UPDATE temp_atlas_vil set geombuffer=ST_BUFFER(geom,500); --772


DROP TABLE IF EXISTS temp_atlas_bas CASCADE;
CREATE TABLE temp_atlas_bas as select * from europe.riveratlas_v10_eu where main_riv=20571119;
--SELECT DropGeometryColumn('temp_atlas_bas','geombuffer');
SELECT AddGeometryColumn ('public','temp_atlas_bas','geombuffer',3035,'POLYGON',2);

UPDATE temp_atlas_bas set geombuffer=ST_BUFFER(geom,500); --772

--exclusion des shreeve 1 et 2
--la requete ci dessous utilise le <-> basés sur les index et bounding box pour ordonner les segments de la jointure
-- test sur une sous table

DROP TABLE temp_atlas_bas_res ;
create table temp_atlas_bas_res AS(
select  r.idsegment,hyriv_id,r.geom,
strahler - ord_stra AS diff_strahler,
st_distance(b.geom,r.geom) AS dist
FROM temp_atlas_bas b
join spain.rn r on st_dwithin(b.geom,r.geom,500)
JOIN spain.rna rr ON r.idsegment=rr.idsegment
WHERE shreeve>2
ORDER BY idsegment, diff_strahler,
b.geom <-> r.geom);--1277


SELECT * FROM  temp_atlas_bas_res WHERE idsegment = 'SP171027';

DROP TABLE IF EXISTS spain.join_atlas_rn CASCADE;
create table spain.join_atlas_rn AS(
select distinct on (idsegment) r.idsegment, hyriv_id,
abs(strahler - ord_stra) AS diff_strahler
FROM europe.riveratlas_v10_eu b
join spain.rn r on st_dwithin(b.geom,r.geom,500)
JOIN spain.rna rr ON r.idsegment=rr.idsegment
WHERE shreeve>2
ORDER BY idsegment, diff_strahler, b.geom <-> r.geom);-- 109806 rows affected, 46s.


-- SELECT * FROM spain.join_atlas_rn limit 10

create view spain.vjoin_atlas_rn As (
SELECT rn.geom as rngeom,rn.idsegment, b.*
FROM spain.join_atlas_rn r
JOIN europe.riveratlas_v10_eu b on r.hyriv_id=b.hyriv_id
JOIN spain.rn on r.idsegment=rn.idsegment);


DROP TABLE IF EXISTS portugal.join_atlas_rn CASCADE;
create table portugal.join_atlas_rn AS(
select distinct on (idsegment) r.idsegment, hyriv_id,
abs(strahler - ord_stra) AS diff_strahler
FROM europe.riveratlas_v10_eu b
join portugal.rn r on st_dwithin(b.geom,r.geom,500)
JOIN portugal.rna rr ON r.idsegment=rr.idsegment
WHERE shreeve>2
ORDER BY idsegment, diff_strahler, b.geom <-> r.geom); --Query returned successfully: 25964 rows affected, 9 secs execution time.
 
DROP TABLE IF EXISTS france.join_atlas_rn CASCADE;
create table france.join_atlas_rn AS(
select distinct on (idsegment) r.idsegment, hyriv_id,
abs(strahler - ord_stra) AS diff_strahler
FROM europe.riveratlas_v10_eu b
join france.rn r on st_dwithin(b.geom,r.geom,500)
JOIN france.rna rr ON r.idsegment=rr.idsegment
WHERE shreeve>2
ORDER BY idsegment, diff_strahler, b.geom <-> r.geom); --Query returned successfully: 43318 14 sec
 





/*
pg_dump -U postgres -f "river_atlas.sql" --table europe.riveratlas_v10_eu eda2.3
pg_dump -U postgres -f "river_atlas_join.sql" --table france.join_atlas_rn --table portugal.join_atlas_rn --table spain.join_atlas_rn  eda2.3
*/
--slp_dg_uav upstream
--slp_dg_cav subbasin

ALTER TABLE dbeel_rivers.rna add column dis_m3_pyr_riveratlas numeric;
ALTER TABLE dbeel_rivers.rna add column dis_m3_pmn_riveratlas numeric;
ALTER TABLE dbeel_rivers.rna add column dis_m3_pmx_riveratlas numeric;



-- update spain
with datafromriveratlas as (
SELECT dis_m3_pyr, dis_m3_pmn, dis_m3_pmx,  idsegment FROM
europe.riveratlas_v10_eu
JOIN spain.join_atlas_rn  On join_atlas_rn.hyriv_id = riveratlas_v10_eu.hyriv_id)
UPDATE spain.rna set (dis_m3_pyr_riveratlas,dis_m3_pmn_riveratlas,dis_m3_pmx_riveratlas) =(dis_m3_pyr, dis_m3_pmn, dis_m3_pmx) 
from datafromriveratlas
where rna.idsegment=datafromriveratlas.idsegment;-- Query returned successfully: 109806 rows affected, 36 secs execution time.


-- Attention in portugal we need to convert from degree to radians before applying atan

with datafromriveratlas as (
SELECT slp_dg_cav, dis_m3_pyr, dis_m3_pmn, dis_m3_pmx , idsegment FROM
europe.riveratlas_v10_eu
JOIN portugal.join_atlas_rn  On join_atlas_rn.hyriv_id = riveratlas_v10_eu.hyriv_id)
UPDATE portugal.rna set (slope,dis_m3_pyr_riveratlas,dis_m3_pmn_riveratlas,dis_m3_pmx_riveratlas) =(atan(radians(slp_dg_cav/10)),dis_m3_pyr, dis_m3_pmn, dis_m3_pmx) 
from datafromriveratlas
where rna.idsegment=datafromriveratlas.idsegment; --Query returned successfully: 25964 rows affected, 13 secs execution time.



--France
with datafromriveratlas as (
SELECT slp_dg_cav, dis_m3_pyr, dis_m3_pmn, dis_m3_pmx , idsegment FROM
europe.riveratlas_v10_eu
JOIN france.join_atlas_rn  On join_atlas_rn.hyriv_id = riveratlas_v10_eu.hyriv_id)
UPDATE france.rna set (dis_m3_pyr_riveratlas,dis_m3_pmn_riveratlas,dis_m3_pmx_riveratlas) =(dis_m3_pyr, dis_m3_pmn, dis_m3_pmx) 
from datafromriveratlas
where rna.idsegment=datafromriveratlas.idsegment; --Query returned successfully: 43318 rows affected, 19 secs execution time.