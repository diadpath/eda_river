
--DROP TABLE eda_gerem.assoc_dbeel_rivers;
SELECT count(*) FROM eda_gerem.assoc_dbeel_rivers WHERE geom_outlet IS NULL --3239
SELECT * FROM eda_gerem.assoc_dbeel_rivers WHERE geom_outlet IS NULL

-- il y a les Corses
SELECT * FROM eda_gerem.assoc_dbeel_rivers WHERE gerem_zone_3 IS NULL AND emu_name_short='FR_Rhon';


UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(2,2,2) WHERE seaidsegment IN ('FR22471', 'FR19562', 'FR19221', 'FR19208', 'FR19878');


-- inland segments
DELETE FROM eda_gerem.assoc_dbeel_rivers WHERE 
seaidsegment IN ('SP158409', 'SP30471', 'FR25737', 'FR24081', 'FR122067');

DELETE FROM eda_gerem.assoc_dbeel_rivers WHERE 
seaidsegment IN ('FR10326', 'FR11467', 'FR10984')
SELECT * FROM eda_gerem.temp_gerem

ALTER TABLE eda_gerem.temp_gerem 
  ALTER COLUMN geom 
  TYPE Geometry(MultiPolygon, 3035) 
  USING ST_Transform(geom, 3035);
 


WITH seaidsegmentmissing AS (
SELECT seaidsegment FROM
eda_gerem.assoc_dbeel_rivers r JOIN 
eda_gerem.temp_gerem t ON ST_intersects(r.geom_outlet, t.geom) WHERE ZONE='med'
AND gerem_zone_4 IS NULL)
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(2,2,2) FROM seaidsegmentmissing WHERE seaidsegmentmissing.seaidsegment = assoc_dbeel_rivers .seaidsegment;--260

WITH seaidsegmentmissing AS (
SELECT seaidsegment FROM
eda_gerem.assoc_dbeel_rivers r JOIN 
eda_gerem.temp_gerem t ON ST_intersects(r.geom_outlet, t.geom) WHERE ZONE='cant'
AND gerem_zone_4 IS NULL)
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(1,3,3) FROM seaidsegmentmissing WHERE seaidsegmentmissing.seaidsegment =
assoc_dbeel_rivers .seaidsegment;--14


WITH inland AS (
SELECT seaidsegment FROM
eda_gerem.assoc_dbeel_rivers r JOIN 
eda_gerem.temp_gerem t ON ST_intersects(r.geom_outlet, t.geom) WHERE ZONE='DELETE'
)
DELETE FROM eda_gerem.assoc_dbeel_rivers WHERE seaidsegment in
(SELECT  seaidsegment FROM inland);--3

WITH seaidsegmentmissing AS (
SELECT seaidsegment FROM
eda_gerem.assoc_dbeel_rivers r JOIN 
eda_gerem.temp_gerem t ON ST_intersects(r.geom_outlet, t.geom) WHERE ZONE='RhinMeu'
AND gerem_zone_4 IS NULL)
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(5,6,7) FROM seaidsegmentmissing WHERE seaidsegmentmissing.seaidsegment = assoc_dbeel_rivers .seaidsegment;--14

WITH seaidsegmentmissing AS (
SELECT seaidsegment FROM
eda_gerem.assoc_dbeel_rivers r JOIN 
eda_gerem.temp_gerem t ON ST_intersects(r.geom_outlet, t.geom) WHERE ZONE='CHAN'
AND gerem_zone_4 IS NULL)
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(4,5,6) FROM seaidsegmentmissing WHERE seaidsegmentmissing.seaidsegment = assoc_dbeel_rivers .seaidsegment;--14


-- Guadiana ???

UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(3,4,5) WHERE seaidsegment IN ('PT99274');

-- Ebro
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(3,4,4) WHERE seaidsegment IN ('SP173326');

-- Bidasoa
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(1,3,3) WHERE seaidsegment IN ('SP225152');

-- Bidasoa (wrong basin)
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(1,3,3) WHERE seaidsegment ='FR120033'; -- somehow there is something wrong there with the 
--bidassoa. I guess Hilaire hadn't the latest version.
UPDATE eda_gerem.assoc_dbeel_rivers SET (gerem_zone_3, gerem_zone_4, gerem_zone_5) =
(1,3,3) WHERE seaidsegment IN ('SP225152');


/*DROP TABLE IF EXISTS eda_gerem.coastline;
CREATE TABLE eda_gerem.coastline AS (
WITH adr AS (
SELECT st_x(geom_outlet) x, st_y(geom_outlet) y, *  FROM eda_gerem.assoc_dbeel_rivers WHERE 
gerem_zone_4=2 
EXCEPT 
SELECT st_x(geom_outlet) x, st_y(geom_outlet) y, assoc_dbeel_rivers.*  FROM eda_gerem.assoc_dbeel_rivers 
JOIN eda_gerem.temp_gerem t ON ST_intersects(geom_outlet, t.geom)
WHERE gerem_zone_4=2 AND "zone"='iles_medit'
)
SELECT 2 AS gerem_zone_4,  st_makepolygon(ST_ExteriorRing(st_dump(geom_outlet).geom)) AS geom 
FROM adr GROUP BY gerem_zone_4);*/


SELECT
  nextval('seq') AS id,
  st_boundary((st_dump(the_geom)).geom) AS geom
  FROM europe.limiteeurope
  WHERE name IN ('France', 'Spain', 'Portugal')

CREATE TEMPORARY SEQUENCE seq;


DROP TABLE IF EXISTS eda_gerem.coastline;
ALTER SEQUENCE seq RESTART WITH 1;
CREATE TABLE eda_gerem.coastline AS (
SELECT
  nextval('seq') AS id,
  st_boundary((st_dump(the_geom)).geom) AS geom
  FROM europe.limiteeurope
  WHERE name IN ('France', 'Spain', 'Portugal')
);--110


ALTER TABLE eda_gerem.coastline ADD CONSTRAINT c_pk_id PRIMARY KEY (id);

ALTER TABLE eda_gerem.coastline ADD COLUMN name text;

UPDATE  eda_gerem.coastline SET name='portugal' WHERE id=79;
UPDATE  eda_gerem.coastline SET name='spain' WHERE id=109;
UPDATE  eda_gerem.coastline SET name='france' WHERE id=44;


/*
CREATE TABLE eda_gerem.coastline3 AS (
SELECT 
nextval('seq') AS id,
'portugal' AS country,
(st_dump(
st_difference(a.geom, b.geom))).geom AS geom
FROM  (SELECT * FROM eda_gerem.coastline  WHERE name='portugal')a,
      (SELECT * FROM  eda_gerem.coastline WHERE name='spain') b 
UNION 
SELECT
nextval('seq') AS id,
'spain'::TEXT AS country,
(st_dump(st_difference(
st_difference(b.geom, a.geom), c.geom))).geom AS geom
FROM  (SELECT * FROM eda_gerem.coastline  WHERE name='portugal')a,
      (SELECT * FROM  eda_gerem.coastline WHERE name='spain') b,
      (SELECT * FROM  eda_gerem.coastline WHERE name='france') c
UNION    
SELECT
nextval('seq') AS id,
'france' AS country,
(st_dump(
st_difference(a.geom, b.geom))).geom AS geom
FROM  (SELECT * FROM eda_gerem.coastline  WHERE name='france')a,
      (SELECT * FROM  eda_gerem.coastline WHERE name='spain') b ); --9   
   */

 /*ALTER TABLE eda_gerem.coastline3 ADD CONSTRAINT c_pk_id3 PRIMARY KEY (id);

UPDATE eda_gerem.coastline2 SET id=6 WHERE id=1;

INSERT INTO eda_gerem.coastline2(id,geom)
SELECT id, geom FROM eda_gerem.coastline3 WHERE id IN (1,2,5);

DELETE FROM eda_gerem.coastline2 WHERE id=6;*/


SELECT * FROM eda_gerem.coastline2


UPDATE eda_gerem.coastline2 SET geom=st_simplify(geom,500) ;

SELECT id, name_coast, st_Azimuth(st_startpoint(geom),st_endpoint(geom)) FROM eda_gerem.coastline2

UPDATE eda_gerem.coastline2 SET geom=st_reverse(geom) WHERE id =133;
UPDATE eda_gerem.coastline2 SET geom=st_reverse(geom) WHERE id =136;
UPDATE eda_gerem.coastline2 SET geom=st_reverse(geom) WHERE id =138;

--  code changed there
ALTER TABLE eda_gerem.coastline2 ADD column name_coast TEXT UNIQUE;
UPDATE eda_gerem.coastline2 SET name_coast='Portugal' WHERE id =1;
UPDATE eda_gerem.coastline2 SET name_coast='Atl_IB' WHERE id =5;
UPDATE eda_gerem.coastline2 SET id =3 WHERE id =5;
UPDATE eda_gerem.coastline2 SET id =5 WHERE id =136;
UPDATE eda_gerem.coastline2 SET id =6 WHERE id =138;
UPDATE eda_gerem.coastline2 SET name_coast='Cant' WHERE id =2;
UPDATE eda_gerem.coastline2 SET name_coast='France' WHERE id =140;
UPDATE eda_gerem.coastline2 SET  name_coast='Med_SP' WHERE id =136;
UPDATE eda_gerem.coastline2 SET  name_coast='Med_FR' WHERE id =138;

INSERT INTO  eda_gerem.coastline2 (id, geom, name_coast) 
SELECT
1 AS id,
st_linemerge(st_union(geom)) AS geom,
'Atlantic_ib' AS name
FROM eda_gerem.coastline2 WHERE id IN (133,137,134);
DELETE FROM eda_gerem.coastline2 WHERE id IN (133,137,134);--3



SELECT * FROM eda_gerem.coastline2 WHERE id = 140;

ALTER TABLE  eda_gerem.assoc_dbeel_rivers ADD COLUMN dist_from_gibraltar_km NUMERIC;
ALTER TABLE  eda_gerem.assoc_dbeel_rivers ADD COLUMN name_coast text;
UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = NULL;


WITH calculate_coastal_dist AS (
SELECT 
seaidsegment,
ST_LineLocatePoint(coastline2.geom, st_closestpoint(coastline2.geom,geom_outlet))*st_length(coastline2.geom)/1000 AS dist,
coastline2.name_coast
FROM  eda_gerem.coastline2
  JOIN  eda_gerem.assoc_dbeel_rivers 
  ON st_dwithin(coastline2.geom,assoc_dbeel_rivers.geom,50000)
)

UPDATE eda_gerem.assoc_dbeel_rivers SET (dist_from_gibraltar_km, name_coast) = (dist,calculate_coastal_dist.name_coast) FROM 
calculate_coastal_dist
WHERE calculate_coastal_dist.seaidsegment = assoc_dbeel_rivers.seaidsegment; --2726 4m


-- the distance to gibraltar includes some on the mediterranean line, I will remove it from med and add it to atlantic


UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = 226 + dist_from_gibraltar_km 
WHERE name_coast='Portugal'; --465


WITH existing_length As(
	SELECT st_length(geom)/1000 + 226 AS additional_length FROM eda_gerem.coastline2 WHERE name_coast='Portugal'
)

UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  + additional_length
FROM  existing_length 
WHERE name_coast='Atl_IB'; --70


UPDATE eda_gerem.assoc_dbeel_rivers SET (name_coast,dist_from_gibraltar_km) = ('Med_SP',1100) WHERE seaidsegment= 'SP322526'; --1

REINDEX TABLE eda_gerem.assoc_dbeel_rivers;
VACUUM ANALYSE eda_gerem.assoc_dbeel_rivers;


SELECT st_srid(geom) FROM eda_gerem.assoc_dbeel_rivers WHERE seaidsegment= 'SP322526'; 


WITH existing_length As(
	SELECT sum(st_length(geom))/1000 + 226 AS additional_length 
	FROM eda_gerem.coastline2 
	WHERE name_coast IN ('Portugal','Atl_IB')
)
UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  + additional_length
FROM  existing_length 
WHERE name_coast='Cant'; --477

WITH existing_length As(
	SELECT sum(st_length(geom))/1000 + 226 AS additional_length 
	FROM eda_gerem.coastline2 
	WHERE name_coast IN ('Portugal','Atl_IB','Cant')
)
UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  + additional_length
FROM  existing_length 
WHERE name_coast='France'; --477

UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = -226 + dist_from_gibraltar_km 
WHERE name_coast='Med_SP'; --823


WITH existing_length As(
	SELECT st_length(geom)/1000 - 226 AS additional_length FROM eda_gerem.coastline2 WHERE name_coast='Med_SP'
)

UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  + additional_length
FROM  existing_length 
WHERE name_coast='Med_FR'; --238


SELECT * FROM eda_gerem.assoc_dbeel_rivers, eda_gerem.temp_gerem tg   WHERE st_intersects(geom_outlet ,tg.geom)
AND ZONE='iles_medit'

WITH gibraltar AS (
	SELECT
	st_transform(st_setsrid(st_point(-5.9 , 35.96), 4326),3035) AS point_gib
	),
medit_island AS (
	SELECT seaidsegment,geom_outlet FROM eda_gerem.assoc_dbeel_rivers, eda_gerem.temp_gerem tg   
	WHERE st_intersects(geom_outlet ,tg.geom)
	AND ZONE='iles_medit'),
distance_from_gibraltar AS (
	SELECT
	seaidsegment,
	st_distance(point_gib,geom_outlet)/1000 AS dist
	FROM gibraltar, medit_island)
UPDATE eda_gerem.assoc_dbeel_rivers SET  dist_from_gibraltar_km=dist 
FROM distance_from_gibraltar
WHERE 
distance_from_gibraltar.seaidsegment= assoc_dbeel_rivers.seaidsegment; --466


UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = 


WITH
inland_france_points AS (
	SELECT seaidsegment,geom_outlet, ccm_wso_id FROM eda_gerem.assoc_dbeel_rivers, eda_gerem.temp_gerem tg   
	WHERE st_intersects(geom_outlet ,tg.geom)
	AND ZONE='RhinMeu')
UPDATE eda_gerem.assoc_dbeel_rivers SET  dist_from_gibraltar_km=NULL
FROM inland_france_points
WHERE assoc_dbeel_rivers.seaidsegment=
inland_france_points.seaidsegment; --50



WITH calculate_coastal_dist AS (
SELECT 
seaidsegment,
ST_LineLocatePoint(coastline2.geom, st_closestpoint(coastline2.geom,geom_outlet))*st_length(coastline2.geom)/1000 AS dist,
coastline2.name_coast
FROM  eda_gerem.coastline2
  JOIN  eda_gerem.assoc_dbeel_rivers 
  ON st_dwithin(coastline2.geom,assoc_dbeel_rivers.geom,500000)
  WHERE dist_from_gibraltar_km IS NULL
)

UPDATE eda_gerem.assoc_dbeel_rivers SET (dist_from_gibraltar_km, name_coast) = (dist,calculate_coastal_dist.name_coast) FROM 
calculate_coastal_dist
WHERE calculate_coastal_dist.seaidsegment = assoc_dbeel_rivers.seaidsegment; --52 4m


WITH existing_length As(
	SELECT sum(st_length(geom))/1000 + 226 AS additional_length 
	FROM eda_gerem.coastline2 
	WHERE name_coast IN ('Portugal','Atl_IB','Cant')
)
UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  + additional_length
FROM  existing_length 
WHERE name_coast='France'
AND  dist_from_gibraltar_km < 2300; --18+84


-- error while correcting North




 UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  - 2315
FROM  
 eda_gerem.temp_gerem tg   
WHERE st_intersects(geom_outlet ,tg.geom)
  AND ZONE='erreur2'
; --50



UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = dist_from_gibraltar_km  +2184
FROM  
 eda_gerem.temp_gerem tg   
WHERE st_intersects(geom_outlet ,tg.geom)
	AND ZONE='erreur'
 AND  name_coast='France'; --50
 
 
 SELECT min(dist_from_gibraltar_km) FROM eda_gerem.assoc_dbeel_rivers WHERE  dist_from_gibraltar_km<0
 
 UPDATE eda_gerem.assoc_dbeel_rivers SET dist_from_gibraltar_km = -dist_from_gibraltar_km
 WHERE dist_from_gibraltar_km<0
 WHERE name_coast LIKE ''
 
/*
 * 
 * CREATE SHAPEFILE FOR MARIA KORTA
 */ 
 
DROP TABLE IF EXISTS eda_gerem.zone_sudoe;
CREATE TABLE eda_gerem.zone_sudoe AS (
SELECT 
gerem_zone_4,
st_union(geom) AS geom
FROM eda_gerem.assoc_dbeel_rivers
GROUP by gerem_zone_4
);--7

DELETE FROM eda_gerem.zone_sudoe WHERE gerem_zone_4 IS NULL;
ALTER TABLE eda_gerem.zone_sudoe ADD CONSTRAINT c_pk_gerem_zone_4 PRIMARY KEY (gerem_zone_4);
ALTER TABLE eda_gerem.zone_sudoe ADD COLUMN ID TEXT;
UPDATE eda_gerem.zone_sudoe SET ID='RhinMeu' WHERE gerem_zone_4 = 6;
UPDATE eda_gerem.zone_sudoe SET ID='CHAN' WHERE gerem_zone_4 = 5;
UPDATE eda_gerem.zone_sudoe SET ID='ATL_IB' WHERE gerem_zone_4 = 4;
UPDATE eda_gerem.zone_sudoe SET ID='CANT' WHERE gerem_zone_4 = 3;
UPDATE eda_gerem.zone_sudoe SET ID='MED' WHERE gerem_zone_4 = 2;
UPDATE eda_gerem.zone_sudoe SET ID='ATL_F' WHERE gerem_zone_4 = 1;
ALTER TABLE eda_gerem.zone_sudoe ADD COLUMN gt3 boolean DEFAULT TRUE;
UPDATE eda_gerem.zone_sudoe SET gt3 = FALSE WHERE gerem_zone_4 IN (5,6);
-- fill in missing parts

SELECT * FROM eda_gerem.assoc_dbeel_rivers adr LIMIT 10
ALTER TABLE eda_gerem.assoc_dbeel_rivers  ADD COLUMN ID TEXT;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='RhinMeu' WHERE gerem_zone_4 = 6;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='CHAN' WHERE gerem_zone_4 = 5;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='ATL_IB' WHERE gerem_zone_4 = 4;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='CANT' WHERE gerem_zone_4 = 3;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='MED' WHERE gerem_zone_4 = 2;
UPDATE eda_gerem.assoc_dbeel_rivers  SET ID='ATL_F' WHERE gerem_zone_4 = 1; --3222
ALTER TABLE eda_gerem.assoc_dbeel_rivers ADD COLUMN gt3 boolean DEFAULT TRUE;
UPDATE eda_gerem.assoc_dbeel_rivers SET gt3 = FALSE WHERE gerem_zone_4 IN (5,6);
/*
WITH myupdate as(
SELECT
gerem_zone_4,
ST_ExteriorRing((ST_Dump(geom)).geom) AS geom FROM 
eda_gerem.assoc_dbeel_rivers)
UPDATE eda_gerem.zone_sudoe
SET geom = myupdate.geom FROM 
myupdate WHERE myupdate.gerem_zone_4=assoc_dbeel_rivers.gerem_zone_4;



*
 * 
 * Test pour virer les trous.... marche pas
 *
CREATE TABLE eda_gerem.zone_sudoe1 AS(
WITH rings AS (
  SELECT gerem_zone_4, (ST_DumpRings((st_dump(geom)).geom)).geom
    FROM eda_gerem.assoc_dbeel_rivers
)
SELECT gerem_zone_4,ST_BuildArea(ST_Collect(geom)) geom
from rings
GROUP BY gerem_zone_4);

*/
*/


SELECT st_geometrytype(geom) FROM  eda_gerem.assoc_dbeel_rivers;


CREATE TABLE dbeel_rivers.rn_rivermouth AS SELECT * FROM eda_gerem.assoc_dbeel_rivers;
--ALTER TABLE dbeel_rivers.rnrivermouth RENAME TO  rn_rivermouth;
CREATE UNIQUE INDEX seaidsegment_pk ON dbeel_rivers.rn_rivermouth USING btree (seaidsegment);
ALTER TABLE dbeel_rivers.rn_rivermouth ADD CONSTRAINT rivermouth_seaidsegment_pk PRIMARY KEY (seaidsegment);
-- not possible to set foreign keys as nothing is in rn....

