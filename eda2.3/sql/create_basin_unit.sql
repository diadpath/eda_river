



 --------------------------------------------------
 -- CORRECTIONS IN FRANCE
 ----------------------------------------------------
ALTER TABLE france.unit_basin RENAME TO unit_basin_archive;
ALTER TABLE spain.unit_basin RENAME TO unit_basin_archive;
ALTER TABLE portugal.unit_basin RENAME TO unit_basin_archive;
-- CORRECTING FRANCE : there are replicated segments FR0 for basins which do not even correspond to FR0
-- THESE BASINS ARE ALL OUTSIDE FROM THE FRENCH TERRITORY EXCEPT ONE
SELECT idsegment FROM france.unit_basin_archive WHERE idsegment='FR1'


--SELECT count(idsegment) AS ct, idsegment FROM  france.unit_basin_archive GROUP BY idsegment hAVING count(idsegment)> 1; --13
-- FR0
--SELECT * FROM france.rn WHERE idsegment='FR0' ; 
-- deleting the basins without segment outside from France with no connection to idsegments
 -- UPDATE france.unit_basin_archive SET idsegment= 'FR2246' WHERE id='3840'; => wrong already exists downstream
--SELECT * FROM france.unit_basin_archive WHERE id IN (3836, 3835,3833,3832,3839, 3834,3837,110120,110252,3838);
DELETE FROM  france.unit_basin_archive WHERE idsegment='FR0' AND id IN (3840, 3836, 3835,3833,3832,3839, 3834,3837,110120,110252,3838, 3831,3830); 
--SELECT * FROM france.unit_basin_archive WHERE idsegment='FR0';

--SELECT count(*) FROM france.unit_basin_archive JOIN france.rn ON rn.idsegment=unit_basin_archive.idsegment; --114492
--SELECT count(*) FROM france.unit_basin_archive --114773

/*
 * CHECKED IN QGIS 208 basins removed at the frontier from France and Portugal 

SELECT * FROM spain.unit_basin_archive LIMIT 10
SELECT spain.unit_basin_archive.idsegment FROM spain.unit_basin_archive
EXCEPT 
SELECT spain.unit_basin_archive.idsegment FROM spain.unit_basin_archive
JOIN spain.rn ON rn.idsegment=unit_basin_archive.idsegment;
SELECT count(idsegment) AS ct, idsegment FROM  spain.unit_basin_archive GROUP BY idsegment hAVING count(idsegment)> 1;

SELECT * FROM portugal.unit_basin_archive LIMIT 10

 */

/*----------------------------------------------------
*
* Harmonizing unit tables*
*SELECT * from france.unit_basin limit 10
*---------------------------------------------------*/


DROP TABLE IF EXISTS dbeel_rivers.basinunit_bu CASCADE;
CREATE TABLE dbeel_rivers.basinunit_bu(
    bu_id serial,
	bu_idsegment TEXT,
	bu_country TEXT,
	bu_code TEXT,
	bu_surfacebvunitm2 NUMERIC,
	bu_perc_rn_notcovered NUMERIC,
	bu_isrn BOOLEAN,
	CONSTRAINT c_pk_id PRIMARY KEY (bu_id),
	CONSTRAINT c_ck_bu_country CHECK (bu_country='PT' OR bu_country='SP' OR bu_country='FR'),
	CONSTRAINT c_uk_bu_idsegment UNIQUE (bu_idsegment)
);

SELECT addgeometrycolumn('dbeel_rivers','basinunit_bu','geom','3035','MULTIPOLYGON',2);
COMMENT ON COLUMN dbeel_rivers.basinunit_bu.bu_isrn IS 'Is the unit basin connected to riversegment';



DROP TABLE IF EXISTS france.basinunit_bu;
CREATE TABLE france.basinunit_bu(
 CONSTRAINT c_pk_bu_id primary key (bu_id),
 CONSTRAINT c_fk_bu_idsegment FOREIGN KEY (bu_idsegment) REFERENCES france.rn(idsegment),
 CONSTRAINT c_uk_bu_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

DROP SEQUENCE IF EXISTS seqbu;
CREATE TEMPORARY SEQUENCE seqbu;
ALTER SEQUENCE seqbu RESTART WITH 1;

------------------------
-- FRANCE
------------------------

-- select only polygons in rn
INSERT INTO france.basinunit_bu
SELECT 
nextval('seqbu') AS bu_id,
rn.idsegment, 
'FR' AS bu_country, 
zonhydro AS bu_code,
round(shape_area::NUMERIC,4) AS bu_surfaceunitm2,
perc_rn_notcovered AS bu_perc_rn_notcovered,
TRUE AS bu_isrn,
unit_basin_archive.geom FROM 
france.unit_basin_archive
JOIN france.rn ON rn.idsegment=unit_basin_archive.idsegment; --114492

--SELECT * FROM france.basinunit_bu ORDER BY bu_id LIMIT 10;

-- This table includes unit basins that are not covered by a idsegment
-- no foreign key
DROP TABLE IF EXISTS france.basinunitout_buo;
CREATE TABLE france.basinunitout_buo(
 CONSTRAINT c_pk_buo_id primary key (bu_id),
 CONSTRAINT c_uk_buo_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

ALTER SEQUENCE seqbu RESTART WITH 200001;
INSERT INTO france.basinunitout_buo
SELECT 
nextval('seqbu') AS bu_id,
sub.idsegment, 
'FR' AS bu_country, 
zonhydro AS bu_code,
round(shape_area::NUMERIC,4) AS bu_surfaceunitm2,
perc_rn_notcovered AS bu_perc_rn_notcovered,
FALSE AS buisrn,
sub.geom FROM (
SELECT * FROM
france.unit_basin_archive
EXCEPT
SELECT unit_basin_archive.* FROM france.unit_basin_archive
JOIN france.rn ON rn.idsegment=unit_basin_archive.idsegment) sub --281;

CREATE INDEX indexbugeom
  ON france.basinunit_bu
  USING gist
  (geom);
 
CREATE INDEX indexbugidsegment
  ON france.basinunit_bu
  USING btree
  (bu_idsegment); 
 
 CREATE INDEX indexbuogeom
  ON france.basinunitout_buo
  USING gist
  (geom);
 

 
 
 
 
 
--------------------
-- SPAIN
------------------
 
 
 
DROP TABLE IF EXISTS spain.basinunit_bu;
CREATE TABLE spain.basinunit_bu(
 CONSTRAINT c_pk_bu_id primary key (bu_id),
 CONSTRAINT c_fk_bu_idsegment FOREIGN KEY (bu_idsegment) REFERENCES spain.rn(idsegment),
 CONSTRAINT c_uk_bu_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

ALTER SEQUENCE seqbu RESTART WITH 300000;

INSERT INTO spain.basinunit_bu
SELECT 
nextval('seqbu') AS bu_id,
rn.idsegment, 
'SP' AS bu_country, 
cod_uni AS bu_code,
round((areactrkm2*10^6)::NUMERIC,4) AS bu_surfaceunitm2,
CASE WHEN perc_rn_notcovered IS NULL THEN 1 ELSE perc_rn_notcovered END AS bu_perc_rn_notcovered,
TRUE AS bu_isrn,
unit_basin_archive.geom FROM 
spain.unit_basin_archive
JOIN spain.rn ON rn.idsegment=unit_basin_archive.idsegment
LEFT JOIN 
(SELECT distinct on (idsegment) * FROM spain.masas_agua_unitbv) AS mmm 
ON mmm.idsegment=rn.idsegment; --325398



DROP TABLE IF EXISTS spain.basinunitout_buo;
CREATE TABLE spain.basinunitout_buo(
 CONSTRAINT c_pk_buo_id primary key (bu_id),
 CONSTRAINT c_uk_buo_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

ALTER SEQUENCE seqbu RESTART WITH 400000;

INSERT INTO spain.basinunitout_buo
SELECT 
nextval('seqbu') AS bu_id,
unit_basin_archive.idsegment, 
'SP' AS bu_country, 
cod_uni AS bu_code,
round((areactrkm2*10^6)::NUMERIC,4) AS bu_surfaceunitm2,
CASE WHEN perc_rn_notcovered IS NULL THEN 1 ELSE perc_rn_notcovered END AS bu_perc_rn_notcovered,
FALSE AS bu_isrn,
unit_basin_archive.geom FROM 
(SELECT spain.unit_basin_archive.* FROM spain.unit_basin_archive
EXCEPT 
SELECT spain.unit_basin_archive.* FROM spain.unit_basin_archive
JOIN spain.rn ON rn.idsegment=unit_basin_archive.idsegment
) unit_basin_archive
LEFT JOIN 
(SELECT distinct on (idsegment) * FROM spain.masas_agua_unitbv) AS mmm 
ON mmm.idsegment=unit_basin_archive.idsegment; --2505

CREATE INDEX indexbugeom
  ON spain.basinunit_bu
  USING gist
  (geom);
 
CREATE INDEX indexbugidsegment
  ON spain.basinunit_bu
  USING btree
  (bu_idsegment); 
 
 CREATE INDEX indexbuogeom
  ON spain.basinunitout_buo
  USING gist
  (geom);
--------------------
-- Portugal
--------------------
DROP TABLE IF EXISTS portugal.basinunit_bu;
CREATE TABLE portugal.basinunit_bu(
 CONSTRAINT c_pk_bu_id primary key (bu_id),
 CONSTRAINT c_fk_bu_idsegment FOREIGN KEY (bu_idsegment) REFERENCES portugal.rn(idsegment),
 CONSTRAINT c_uk_bu_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

ALTER SEQUENCE seqbu RESTART WITH 500000;

INSERT INTO portugal.basinunit_bu
SELECT 
nextval('seqbu') AS bu_id,
rn.idsegment, 
'PT' AS bu_country, 
"order" AS bu_code,
round((area*10^6)::NUMERIC,4) AS bu_surfaceunitm2,
CASE WHEN perc_rn_notcovered IS NULL THEN 1 ELSE round(perc_rn_notcovered::numeric,2) END AS bu_perc_rn_notcovered,
TRUE AS bu_isrn,
unit_basin_archive.geom FROM 
portugal.unit_basin_archive
JOIN portugal.rn ON rn.idsegment=unit_basin_archive.idsegment;
 --74571

DROP TABLE IF EXISTS portugal.basinunitout_buo;
CREATE TABLE portugal.basinunitout_buo(
 CONSTRAINT c_pk_buo_id primary key (bu_id),
 CONSTRAINT c_uk_buo_idsegment UNIQUE (bu_idsegment)
) inherits (dbeel_rivers.basinunit_bu);

ALTER SEQUENCE seqbu RESTART WITH 600000;

-- insert missing basins but REMOVE BASINS OUTIDE PORTUGAL

CREATE INDEX indexbugeom
  ON portugal.basinunit_bu
  USING gist
  (geom);
 
CREATE INDEX indexbugidsegment
  ON  portugal.basinunit_bu
  USING btree
  (bu_idsegment); 

WITH missing AS(
SELECT portugal.unit_basin_archive.* FROM portugal.unit_basin_archive
EXCEPT 
SELECT portugal.unit_basin_archive.* FROM portugal.unit_basin_archive
JOIN portugal.rn ON rn.idsegment=unit_basin_archive.idsegment),

joined_basin AS (
SELECT st_union(st_transform(atagua_bacias_bacias_snirh_pc.geom,3035)) geom FROM
portugal.atagua_bacias_bacias_snirh_pc 
),

missing_inside AS (
SELECT missing.* FROM missing 
JOIN joined_basin ON 
st_intersects(joined_basin.geom,missing.geom))

INSERT INTO portugal.basinunitout_buo
SELECT 
nextval('seqbu') AS bu_id,
unit_basin_archive.idsegment, 
'PT' AS bu_country, 
"order" AS bu_code,
round((area*10^6)::NUMERIC,4) AS bu_surfaceunitm2,
CASE WHEN perc_rn_notcovered IS NULL THEN 1 ELSE round(perc_rn_notcovered::numeric,2) END AS bu_perc_rn_notcovered,
FALSE AS bu_isrn,
unit_basin_archive.geom FROM 
missing_inside AS  unit_basin_archive
; --4074


 
 CREATE INDEX indexbuogeom
  ON portugal.basinunitout_buo
  USING gist
  (geom);




SELECT count(*) FROM dbeel_rivers.basinunit_bu 
SELECT count(bu_id) AS ct, bu_id FROM  dbeel_rivers.basinunit_bu  GROUP BY bu_id hAVING count(bu_id)> 1;

 --------------------------------------------------
 -- HARMONIZING TO NEW RIVER WIDTH
 ----------------------------------------------------


with recalculated as (
	SELECT 
	rna.idsegment,
	round((riverwidthm * lengthm * coalesce(bu_perc_rn_notcovered,1))::numeric,2) as wettedsurfacem2
	FROM france.rna 
	JOIN france.rn on rn.idsegment=rna.idsegment
	LEFT JOIN
	france.basinunit_bu bu on rna.idsegment=bu.bu_idsegment
)
UPDATE france.rna set (wettedsurfacem2)= (recalculated.wettedsurfacem2)
FROM recalculated
where recalculated.idsegment=rna.idsegment; --114556


with recalculated as (
	SELECT 
	rna.idsegment,
	round((riverwidthm * lengthm * coalesce(bu_perc_rn_notcovered,1))::numeric,2) as wettedsurfacem2
	FROM spain.rna 
	JOIN spain.rn on rn.idsegment=rna.idsegment
	LEFT JOIN
	spain.basinunit_bu bu on rna.idsegment=bu.bu_idsegment
)
UPDATE spain.rna set (wettedsurfacem2)= (recalculated.wettedsurfacem2)
FROM recalculated
where recalculated.idsegment=rna.idsegment; --325399


with recalculated as (
	SELECT 
	rna.idsegment,
	round((riverwidthm * lengthm * coalesce(bu_perc_rn_notcovered,1))::numeric,2) as wettedsurfacem2
	FROM portugal.rna 
	JOIN portugal.rn on rn.idsegment=rna.idsegment
	LEFT JOIN
	portugal.basinunit_bu bu on rna.idsegment=bu.bu_idsegment
)
UPDATE portugal.rna set (wettedsurfacem2)= (recalculated.wettedsurfacem2)
FROM recalculated
where recalculated.idsegment=rna.idsegment;--75057








-----------------------------------
-- Hilaire tables ???
------------------------------------

drop table if exists dbeel_rivers.basins;
--créer les polygones avec trous
create table dbeel_rivers.basins as (
	SELECT seaidsegment, ST_union(b.geom) As geom
FROM dbeel_rivers.rn join dbeel_rivers.basinunit_bu b on b.bu_idsegment=idsegment
where seaidsegment is not null GROUP BY seaidsegment
);


--retire les trous
drop table if exists dbeel_rivers.basins2;
create table dbeel_rivers.basins2 as (
	SELECT seaidsegment, ST_union(ST_MakePolygon(geom)) As geom
FROM (
    SELECT seaidsegment, ST_ExteriorRing((ST_Dump(geom)).geom) As geom
    FROM dbeel_rivers.basins
    ) s
where seaidsegment is not null GROUP BY seaidsegment
);

------------------------
-- check error unit basin in postgis
-------------------------
SELECT bu_id, count(*) FROM dbeel_rivers.basinunit_bu 
GROUP BY bu_id
HAVING count(*)>1

SELECT *, count(*) FROM spain.basinunit_bu 
GROUP BY bu_id
HAVING count(*)>1

WITH the_union as(
SELECT *  FROM portugal.basinunit_bu 
UNION 
SELECT * FROM portugal.basinunitout_buo)
SELECT bu_id , count(*) FROM the_union
GROUP BY bu_id
HAVING count(*)>1; --0

WITH the_union as(
SELECT *  FROM spain.basinunit_bu 
UNION 
SELECT * FROM spain.basinunitout_buo)
SELECT bu_id , count(*) FROM the_union
GROUP BY bu_id
HAVING count(*)>1; -- > corrected OK

SELECT *  FROM spain.basinunit_bu  WHERE bu_id=400000
SELECT *  FROM spain.basinunitout_buo  WHERE bu_id=400000


SELECT * FROM portugal.basinunitout_buo LIMIT 10



UPDATE spain.basinunitout_buo
SET bu_id=bu_id+1000000; --2505

UPDATE portugal.basinunit_bu 
SET bu_id=bu_id+2000000;--74570

UPDATE portugal.basinunitout_buo 
SET bu_id=bu_id+2000000; --4074


ALTER TABLE  france.surface_hydrographique_bdtopo_unitrht RENAME TO waterbody_unitbv;
ALTER TABLE spain.masas_agua_unitbv RENAME TO waterbody_unitbv;
ALTER TABLE portugal.wisewaterbody_unitbv RENAME TO waterbody_unitbv;



