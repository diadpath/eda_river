------------------------------
---- BASINS OF PILOT BASINS
------------------------------
/*
PT56183	Mondego
SP224290	Oria
SP128132	Ter
FR118671	Adour
SP109916	Guadalquivir
SP118297	Guadiaro
*/
CREATE temporary sequence seq;

----	Create a table of the surface water in the basin: "gt6_basin_surfacewater"

DROP TABLE if exists dbeel_rivers.gt6_basins_surfacewater;
CREATE TABLE dbeel_rivers.gt6_basins_surfacewater AS (
SELECT nextval('seq') AS id, 'Oria' AS basin, nom_masa AS name, categoria AS category, (st_dump(st_union(geom))).geom FROM spain.waterbody_unitbv
WHERE idsegment in (SELECT spain.upstream_segments_rn('SP224290'))
GROUP BY name, category
UNION
SELECT nextval('seq') AS id, 'Ter' AS basin, nom_masa AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM spain.waterbody_unitbv
WHERE idsegment in (SELECT spain.upstream_segments_rn('SP128132'))
GROUP BY name, category
UNION
SELECT nextval('seq') AS id, 'Guadalquivir' AS basin, nom_masa AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM spain.waterbody_unitbv
WHERE idsegment in (SELECT spain.upstream_segments_rn('SP109916'))
GROUP BY name, category
UNION
SELECT nextval('seq') AS id, 'Adour' AS basin, NULL AS name, NULL AS category, (st_dump(st_union(geom))).geom 
FROM france.waterbody_unitbv
WHERE idsegment in (SELECT france.upstream_segments_rn('FR118671'))
UNION
SELECT nextval('seq') AS id, 'Mondego' AS basin, nome AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM portugal.waterbody_unitbv
WHERE idsegment in (SELECT portugal.upstream_segments_rn('PT56183'))
GROUP BY name, category
UNION
SELECT nextval('seq') AS id, 'Mondego' AS basin, nom_masa AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM spain.waterbody_unitbv
WHERE idsegment in (SELECT dbeel_rivers.upstream_segments_rn('PT56183'))
GROUP BY name, category
UNION 
SELECT nextval('seq') AS id, 'Minho' AS basin, nome AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM portugal.waterbody_unitbv
WHERE idsegment in (SELECT portugal.upstream_segments_rn('PT31034'))
GROUP BY name, category
UNION
SELECT nextval('seq') AS id, 'Minho' AS basin, nom_masa AS name, categoria AS category, (st_dump(st_union(geom))).geom 
FROM spain.waterbody_unitbv
WHERE idsegment in (SELECT dbeel_rivers.upstream_segments_rn('PT31034'))
GROUP BY name, category
); 

----	Create a table of the basin: 

ALTER SEQUENCE seq restart with 1;
DROP TABLE if exists dbeel_rivers.gt6_basin;
CREATE TABLE dbeel_rivers.gt6_basin AS (
SELECT nextval('seq') as id, 'Oria' AS basin, (st_dump(st_union(geom))).geom from spain.basinunit_bu
where bu_idsegment in (SELECT spain.upstream_segments_rn('SP224290'))
); --1


INSERT INTO dbeel_rivers.gt6_basin 
SELECT nextval('seq') as id, 'Ter' AS basin, (st_dump(st_union(geom))).geom from spain.basinunit_bu
where bu_idsegment in (SELECT spain.upstream_segments_rn('SP128132'));


INSERT INTO dbeel_rivers.gt6_basin 
SELECT nextval('seq') as id, 'Guadalquivir' AS basin, (st_dump(st_union(geom))).geom from spain.basinunit_bu
where bu_idsegment in (SELECT spain.upstream_segments_rn('SP109916'));


INSERT INTO dbeel_rivers.gt6_basin 
SELECT nextval('seq') as id, 'Adour' AS basin, (st_dump(st_union(geom))).geom from france.basinunit_bu
where bu_idsegment in (SELECT france.upstream_segments_rn('FR118671'));

INSERT INTO dbeel_rivers.gt6_basin 
SELECT nextval('seq') as id, 'Mondego' AS basin, (st_dump(st_union(geom))).geom from dbeel_rivers.basinunit_bu
where bu_idsegment in (SELECT dbeel_rivers.upstream_segments_rn('PT56183'));

INSERT INTO dbeel_rivers.gt6_basin 
SELECT nextval('seq') as id, 'Minho' AS basin, (st_dump(st_union(geom))).geom from dbeel_rivers.basinunit_bu
where bu_idsegment in (SELECT dbeel_rivers.upstream_segments_rn('PT31034'));

INSERT INTO dbeel_rivers.gt6_basin 
SELECT 9 as id, 'Guadiaro' AS basin, (st_dump(st_union(geom))).geom from spain.basinunit_bu
where bu_idsegment in (SELECT spain.upstream_segments_rn('SP118297'));



SELECT max(id) FROM dbeel_rivers.gt6_basin
---
-- EDA2.2.1
----

ALTER TABLE rht.devalaison ADD COLUMN idsegment TEXT;
UPDATE rht.devalaison SET idsegment = 'FR'||id_drain

-- CREATE TABLE FOR DUMP in public
-- RECREATE CONSTRAINTS AND COMMENTS, CHANGE NAMES
-- RECREATE INDEX

DROP TABLE IF EXISTS fieldsilver_fi;
CREATE TABLE fieldsilver_fi AS
SELECT 
id AS fi_id,
site AS fi_site,
idsegment AS fi_idsegment,
annee AS fi_year,
estim_eda AS fi_nilvereda221,
surface_reelle_ha*10000 AS fi_surfacefieldm2,
surface_rht_ha*10000 AS fi_surfacerht221m2,
nb_eda_corr AS fi_nbeda221corr,
size_str_eda fi_sizestreda221,
effectif_compte AS fi_countfield,
effectif_estime  AS fi_estimfield,
geom
FROM rht.devalaison; --54
SELECT max(fi_id) FROM fieldsilver_fi;
CREATE SEQUENCE IF NOT EXISTS fieldsilver_fi_id_seq  MINVALUE 55 OWNED BY fieldsilver_fi.fi_id;
ALTER TABLE fieldsilver_fi ADD 	CONSTRAINT c_pk_fieldsilver_fi_id PRIMARY KEY (fi_id);
ALTER TABLE fieldsilver_fi ADD 	CONSTRAINT c_uk_fi_year UNIQUE (fi_site, fi_year);
ALTER TABLE fieldsilver_fi ADD 	CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 2154));
COMMENT ON TABLE rht.devalaison IS 'The objective is to estimate downstream migration from year N 
which occurs during winter N-N+1 ';

-- Column comments

COMMENT ON COLUMN fieldsilver_fi.fi_year IS 'Corresponds to Y : Y+1 for the downstream migration season';

/*
cd f:/eda/base/eda2.2.1/
pg_dump -U postgres -f "fieldsilver_fi.sql" --table fieldsilver_fi eda2.2
psql -U postgres -f "fieldsilver_fi.sql" eda2.3
psql -U postgres -c "ALTER TABLE fieldsilver_fi set schema france;" eda2.3
*/

SELECT * FROM france.fieldsilver_fi;


/*----------------------------------------
 * With this code, I collect all idsegments upstream of actual silver counts and calculate their production
 *--------------------------------------------*/

DROP TABLE IF EXISTS france.temp_upstreamsegments;
CREATE TABLE france.temp_upstreamsegments (idsegment TEXT);
-- DROP TABLE IF EXISTS france.fieldsilverupstream;
CREATE TABLE france.fieldsilverupstream (
 idsegmentdownstream TEXT, 
 fi_id INTEGER , 
 idsegment TEXT,  
 psilver NUMERIC, 
 density NUMERIC, 
 wettedsurfacem2 NUMERIC, 
 wettedsurfaceotherm2 NUMERIC, 
 drought TEXT);

/*
 * This script requires the table fieldsilverupstream
 */

DO $$
DECLARE
rec RECORD;
theidsegment TEXT;
thesite TEXT;
theid INTEGER;
nb INTEGER;
BEGIN
DROP TABLE IF EXISTS france.temp_upstreamsegments;
CREATE TABLE france.temp_upstreamsegments (idsegment TEXT);
FOR rec in SELECT DISTINCT ON (fi_idsegment) * from france.fieldsilver_fi
LOOP
BEGIN
theidsegment:=rec.fi_idsegment;
thesite:=rec.fi_site;
theid:=rec.fi_id;
DELETE FROM france.temp_upstreamsegments; 
--  1 populate the upstreamsegment table
INSERT INTO france.temp_upstreamsegments SELECT france.upstream_segments_rn(theidsegment);
SELECT count(*) FROM france.temp_upstreamsegments INTO nb;
RAISE NOTICE 'Site % Nb segment %', thesite, nb;
-- using a join insert into 
WITH upstreamsegments AS (
	SELECT * FROM france.temp_upstreamsegments
),
tabletoinsert AS (
SELECT theidsegment AS idsegmentdownstream, theid  AS fi_id, 
 rna.idsegment, psilver, density, wettedsurfacem2, wettedsurfaceotherm2, drought  
FROM upstreamsegments 
JOIN france.rne ON rne.idsegment = upstreamsegments.idsegment
JOIN france.rna ON rna.idsegment= rne.idsegment)
INSERT INTO france.fieldsilverupstream 
(idsegmentdownstream, fi_id, idsegment, psilver, density, wettedsurfacem2, wettedsurfaceotherm2, drought)
SELECT * FROM tabletoinsert;
END;
END LOOP;
END;
$$ LANGUAGE 'plpgsql'

